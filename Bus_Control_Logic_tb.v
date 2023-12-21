module Bus_Control_Logic_TB;

    // Inputs
    reg clock;
    reg reset;
    reg CS;
    reg RD;
    reg WR;
    reg address;
    reg [7:0] data_bus_in;

    // Outputs
    wire [7:0] internal_data_bus;
    wire write_initial_command_word_1;
    wire write_initial_command_word_2_4;
    wire write_operation_control_word_1;
    wire write_operation_control_word_2;
    wire write_operation_control_word_3;
    wire read;

    // Instantiate the module under test
    Bus_Control_Logic uut (
        .clock(clock),
        .reset(reset),
        .CS(CS),
        .RD(RD),
        .WR(WR),
        .address(address),
        .data_bus_in(data_bus_in),
        .internal_data_bus(internal_data_bus),
        .write_initial_command_word_1(write_initial_command_word_1),
        .write_initial_command_word_2_4(write_initial_command_word_2_4),
        .write_operation_control_word_1(write_operation_control_word_1),
        .write_operation_control_word_2(write_operation_control_word_2),
        .write_operation_control_word_3(write_operation_control_word_3),
        .read(read)
    );

    // Clock generator
    always #5 clock = ~clock;

    // Stimulus
    initial begin
        // Initialize inputs
        clock = 0;
        reset = 1;
        CS = 0;
        RD = 0;
        WR = 0;
        address = 0;
        data_bus_in = 8'b00000000;

        // Wait for reset to be released
        #10 reset = 0;

        // Test case 1: Write operation for initializing command word 1
        WR = 1;
        address = 0;
        data_bus_in = 8'b00010000;
        #10;

        // Test case 2: Write operation for initializing command words 2 to 4
        WR = 1;
        address = 1;
        data_bus_in = 8'b00001101;
        #10;

        // Test case 3: Write operation for operation control word 1
        WR = 1;
        address = 1;
        data_bus_in = 8'b00000111;
        #10;

        // Test case 4: Write operation for operation control word 2
        WR = 1;
        address = 0;
        data_bus_in = 8'b00000001;
        #10;

        // Test case 5: Write operation for operation control word 3
        WR = 1;
        address = 0;
        data_bus_in = 8'b00000011;
        #10;

        // Test case 6: Read operation
        RD = 1;
        CS = 1;
        #10;

        // Finish simulation
        $finish;
    end
endmodule
