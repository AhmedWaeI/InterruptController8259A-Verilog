module Bus_Control_Logic_TB;

    // Inputs
    reg CS_bar;
    reg RD_bar;
    reg WR_bar;
    reg A0;
    reg [7:0] data_bus_buffer_in;

    // Outputs
    wire [7:0] data_bus_buffer_out;
    wire ICW_1;
    wire ICW_2;
    wire ICW_3;
    wire ICW_4;
    wire OCW_1;
    wire OCW_2;
    wire OCW_3;
    wire read;

    // Instantiate the module under test
    Bus_Control_Logic dut (
        .CS_bar(CS_bar),
        .RD_bar(RD_bar),
        .WR_bar(WR_bar),
        .A0(A0),
        .data_bus_buffer_in(data_bus_buffer_in),
        .internal_bus(),
        .data_bus_buffer_out(data_bus_buffer_out),
        .ICW_1(ICW_1),
        .ICW_2(ICW_2),
        .ICW_3(ICW_3),
        .ICW_4(ICW_4),
        .OCW_1(OCW_1),
        .OCW_2(OCW_2),
        .OCW_3(OCW_3),
        .read(read)
    );

    // Clock
    reg clk = 0;
    always #5 clk = ~clk;

    // Testbench logic
    initial begin
        // Initialize inputs
      $dumpfile("dump.vcd"); $dumpvars;
        CS_bar = 0;
        RD_bar = 0;
        WR_bar = 0;
        A0 = 0;
        data_bus_buffer_in = 8'b00000000;

        // Wait for some time for stable signals
        #10;

        // Testcase 1: Write operation
        $display("Testcase 1: Write operation");
        CS_bar = 1;
        RD_bar = 0;
        WR_bar = 1;
        A0 = 1;
        data_bus_buffer_in = 8'b10101010;

        // Wait for some time to observe outputs
        #10;

        // Testcase 2: Read operation
        $display("Testcase 2: Read operation");
        CS_bar = 1;
        RD_bar = 1;
        WR_bar = 0;
        A0 = 0;
        data_bus_buffer_in = 8'b00000000;

        // Wait for some time to observe outputs
        #10;

        // End simulation
        $finish;
    end

endmodule
