module pic8259A_tb;

  reg chip_select_n;
  reg read_enable_n;
  reg write_enable_n;
  reg [7:0] address;
  reg [7:0] data_bus_in;
  wire [7:0] data_bus_out;
  wire data_bus_io;
  reg [2:0] cascade_in;
  reg slave_program_n;
  reg interrupt_acknowledge_n;
  reg [7:0] interrupt_request;

  // Instantiate pic8259A DUT
  pic8259A dut(
    .chip_select_n(chip_select_n),
    .read_enable_n(read_enable_n),
    .write_enable_n(write_enable_n),
    .address(address),
    .data_bus_in(data_bus_in),
    .data_bus_out(data_bus_out),
    .data_bus_io(data_bus_io),
    .cascade_in(cascade_in),
    .cascade_out(),
    .cascade_io(),
    .slave_program_n(slave_program_n),
    .buffer_enable(),
    .slave_program_or_enable_buffer(),
    .interrupt_acknowledge_n(interrupt_acknowledge_n),
    .interrupt_to_cpu(),
    .interrupt_request(interrupt_request)
  );

  initial begin
    chip_select_n = 1'b1;
    read_enable_n = 1'b1;
    write_enable_n = 1'b1;
    address = 8'b00000000;
    data_bus_in = 8'b00000000;
    cascade_in = 3'b000;
    slave_program_n = 1'b1;
    interrupt_acknowledge_n = 1'b1;
    interrupt_request = 8'b00000000;

    // Reset
    #10;
    chip_select_n = 1'b0;
    write_enable_n = 1'b1;
    data_bus_in = 8'b00010001; // ICW1
    #10;
    data_bus_in = 8'h20; // ICW2
    #10;
    data_bus_in = 8'b0000_0000; // ICW3
    #10;
    data_bus_in = 8'b0000_1000; // ICW4
    #10;
    chip_select_n = 1'b1;
    #10;

    // Enable IRQ0
    chip_select_n = 1'b0;
    write_enable_n = 1'b0;
    address = 8'b00000000;
    data_bus_in = 8'b11111110; // Enable IRQ0
    #10;
    chip_select_n = 1'b1;
    #10;

    // Generate interrupt
    interrupt_request = 8'b00000001; // Assert IRQ0
    // Wait for interrupt to be acknowledged
    @(posedge interrupt_acknowledge_n);

    // Read interrupt vector
    chip_select_n = 1'b0;
    read_enable_n = 1'b0;
    #10;

    // Acknowledge interrupt
    interrupt_acknowledge_n = 1'b0;
    #10;
    interrupt_acknowledge_n = 1'b1;

    // Clear interrupt
    interrupt_request = 8'b00000000;

    // Additional test case: Simulate multiple interrupt requests
    #10;
    interrupt_request = 8'b00000111; // Assuming IRQ0, IRQ1, and IRQ2 are asserted
    #10;
    // Clear interrupt_request for other test cases

    // Additional test case: Test handling of cascade mode
    chip_select_n = 1'b0;
    write_enable_n = 1'b0;
    address = 8'h10; // Assuming OCW3 address for cascade mode configuration
    data_bus_in = 8'b00000100; // Enable cascade mode
    #10;
    write_enable_n = 1'b0;
    address = 8'h11; // Assuming OCW3 address for master device configuration
    data_bus_in = 8'b00000001; // Set master device ID
    
    #1000;
    $finish;
  end

  initial begin
    $monitor("T=%0t interrupt_acknowledge_n=%b interrupt_request=%b", $time, interrupt_acknowledge_n, interrupt_request);
  end

endmodule
