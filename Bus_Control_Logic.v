
// 8259A_Bus_Control_Logic
// implements the data bus buffering and read/write control logic for the 8259A PIC

module Bus_Control_Logic (
    input   logic           clock,
    input   logic           reset,

    input   logic           CS, //chip select active low
    input   logic           RD, //read enable(indicates a read operation is requested.)
    input   logic           WR, //write enable(indicates a write operation is requested.)
    input   logic           address, //A0 of read/write Logic (Address bus signal that specifies the address for read/write operations.)
    input   logic   [7:0]   data_bus_in, // 8-bit data bus input signal that carries the data to be written.

    // Internal Bus
    output  logic   [7:0]   internal_data_bus, //for data bus buffer output( 8-bit internal data bus that buffers the data being written or read.)
    output  logic           write_initial_command_word_1, //Output signal indicating a write operation for initializing command word 1.
    output  logic           write_initial_command_word_2, //Output signal indicating a write operation for initializing command words 2.
    output  logic           write_initial_command_word_3, //Output signal indicating a write operation for initializing command words 3.
    output  logic           write_initial_command_word_4, //Output signal indicating a write operation for initializing command words 4.
    output  logic           write_operation_control_word_1, //Output signal indicating a write operation for operation control word 1.
    output  logic           write_operation_control_word_2, //Output signal indicating a write operation for operation control word 2.
    output  logic           write_operation_control_word_3, //Output signal indicating a write operation for operation control word 3.
    output  logic           read //Output signal indicating a read operation.de
);

    //
    // Internal Signals
    //
    logic   prev_WR; //active high previous write enable (Internal signal that stores the previous state of the write enable signal.)
    logic   write_flag; // Internal signal indicating a rising edge transition of the write enable signal.
    logic   stable_address; //Internal signal that stores the stable value of the address signal.

    //
    // Write Control
    //
    always @(posedge reset) begin
        if (reset) //upon reset clear the internal data bus
            internal_data_bus <= 8'b00000000;
        else if (~WR & ~CS) //if write enabled and chip selected set to 8259A buffer the input data
            internal_data_bus <= data_bus_in;
        else //hold the value of internal data bus if not write enable and not chip selected (no buffering)
            internal_data_bus <= internal_data_bus;
    end

    always @( posedge reset) begin
        if (reset)
            prev_WR <= 1'b1; //means WR not enabled if there is reset
        else if (CS)
            prev_WR <= 1'b1; //means WR not enabled if 8259A not chip selected
        else
            prev_WR <= WR;
    end
    assign write_flag = ~prev_WR & WR; 
//The write_flag signal is a logical AND of the negation of prev_WR and WR. It becomes active (high) when 
//there is a rising edge transition on the WR signal.
    always @(posedge reset) begin
        if (reset)
            stable_address <= 1'b0;
        else
            stable_address <= address;
    end

    // Generate write request flags
    assign write_initial_command_word_1   = write_flag & ~stable_address & internal_data_bus[4];
    assign write_initial_command_word_2 = write_flag & stable_address;
    assign write_initial_command_word_3 = write_flag & ~stable_address & ~internal_data_bus[4] & ~internal_data_bus[1];
    assign write_initial_command_word_4 = write_flag & stable_address;
    assign write_operation_control_word_1 = write_flag & stable_address;
    assign write_operation_control_word_2 = write_flag & ~stable_address & ~internal_data_bus[4] & ~internal_data_bus[3];
    assign write_operation_control_word_3 = write_flag & ~stable_address & ~internal_data_bus[4] & internal_data_bus[3];

    //
    // Read Control (when read enabledand chip selected)
    //
    assign read = ~RD  & ~CS; //read if chip selected and read enabled

endmodule
