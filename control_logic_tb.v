`timescale 1ns/1ps

module Control_Logic_tb;

  // Inputs
  reg [7:0] internal_data_bus;
  reg ICW_1, ICW_2_4, OCW_1, OCW_2, OCW_3, read;
  reg [2:0] casc_in;
  reg slave_program_n, interrupt_acknowledge_n;
  reg [7:0] interrupt, highest_level_in_service;
reg call_address_interval_4_or_8_config;
  // Outputs
  wire [2:0] casc_out;
  wire casc_io, slave_program_or_enable_buffer;
  wire interrupt_to_cpu;
  wire [7:0] control_logic_data;
  wire level_or_edge_toriggered_config;
  wire enable_read_register, read_register_isr_or_irr;
  wire [7:0] interrupt_mask, end_of_interrupt;
  wire [2:0] priority_rotate;
  wire freeze, latch_in_service;
  wire [7:0] clear_interrupt_request;
 // wire set_icw4_config, buffered_mode_config, auto_eoi_config,single_or_cascade_config;
 // reg call_address_interval_4_or_8_config;
	reg single_or_cascade_config;
	reg set_icw4_config;
	reg [7:0] cascade_device_config;
	wire buffered_mode_config;
	wire buffered_master_or_slave_config;
	wire auto_eoi_config;
  // Instantiate the module
  Control_Logic uut (
    .internal_data_bus(internal_data_bus),
    .ICW_1(ICW_1),
    .ICW_2_4(ICW_2_4),
    .OCW_1(OCW_1),
    .OCW_2(OCW_2),
    .OCW_3(OCW_3),
    .read(read),
    .casc_in(casc_in),
    .casc_out(casc_out),
    .casc_io(casc_io),
    .slave_program_n(slave_program_n),
    .slave_program_or_enable_buffer(slave_program_or_enable_buffer),
    .interrupt_acknowledge_n(interrupt_acknowledge_n),
    .interrupt_to_cpu(interrupt_to_cpu),
    .control_logic_data(control_logic_data),
    .level_or_edge_toriggered_config(level_or_edge_toriggered_config),
    .enable_read_register(enable_read_register),
    .read_register_isr_or_irr(read_register_isr_or_irr),
    .interrupt(interrupt),
    .highest_level_in_service(highest_level_in_service),
    .interrupt_mask(interrupt_mask),
    .end_of_interrupt(end_of_interrupt),
    .priority_rotate(priority_rotate),
    .freeze(freeze),
    .latch_in_service(latch_in_service),
    .clear_interrupt_request(clear_interrupt_request)
  );

  // Clock generation
  reg clk;
  initial begin
    clk = 0;
    // Provide a clock to the module
    forever #5 clk = ~clk;
  end

  // Testbench stimulus
  initial begin
    // Initialize inputs
    $dumpfile("dump.vcd");
    $dumpvars;
    internal_data_bus = 8'b0;
    ICW_1 = 1'b0;
    ICW_2_4 = 1'b0;
    OCW_1 = 1'b0;
    OCW_2 = 1'b0;
    OCW_3 = 1'b0;
    read = 1'b0;
    casc_in = 3'b000;
    slave_program_n = 1'b0;
    interrupt_acknowledge_n = 1'b0;
    interrupt = 8'b00000000;
    highest_level_in_service = 8'b00000000;

     $display("Testcase 1: level(0)/edge(1)");
    ICW_1 = 1'b1;
    internal_data_bus = 8'h08;//level_or_edge_toriggered_config=1
    #10;
    $display("Testcase 2: interval_8(0)/interval_4(1)");
    ICW_1 = 1'b1;
    internal_data_bus = 8'h0C; //call_address_interval_4_or_8_config=1
    #10;
    $display("Testcase 3: cascade(0)/single(1)");
    ICW_1 = 1'b1;
    internal_data_bus = 8'h0E;//single_or_cascade_config=1
    #10;
    $display("Testcase 4: ICW4_Notneeded(0)/ICW4_needed(1)");
    ICW_1 = 1'b1;
    internal_data_bus = 8'h0F;//set_icw4_config=1
    #10;
    $display("Testcase 5: buffered mode slave(0)/buffered mode master(1)");
   ICW_2_4 = 1'b1;
    internal_data_bus = 8'h04;//buffered_mode_config=1
    #10;
    $display("Testcase 6: EOI(0)/AEOI(1)");
    ICW_2_4 = 1'b1;
    internal_data_bus = 8'h02;//auto_eoi_config=1
    #10;
    
   
    OCW_1 = 1'b1;
    #10;
    OCW_2= 1'b1;
    #10;
    OCW_3 = 1'b1;
    #10;
    read = 1'b1;
    $finish;
  end/*
    // Add more test cases
    #10;
    interrupt_acknowledge_n = 1'b1;
    #10;
    interrupt = 8'b11000000;
    #10;
    highest_level_in_service = 8'b00010000;

    // Add a delay for simulation termination
    #1000;
    $stop;
  end*/

  // Display statements for observing outputs
  /*always @(*) begin
    $display("level(0)/edge(1)=%b, interval_8(0)/interval_4(1)=%b, cascade(0)/single(1)=%b, ICW4_Notneeded(0)/ICW4_needed(1)=%b, buffered mode slave(0)/buffered mode master(1)=%b, EOI(0)/AEOI(1)=%b", level_or_edge_toriggered_config,call_address_interval_4_or_8_config,single_or_cascade_config,set_icw4_config,buffered_mode_config,auto_eoi_config);
  end*/
endmodule
