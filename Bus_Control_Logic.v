
// 8259A_Bus_Control_Logic
// implements the data bus buffering and read/write control logic for the 8259A PIC

module Bus_Control_Logic (
    input wire reset,

    input wire CS, //chip select active low
    input wire RD, //read enable(indicates a read operation is requested.)
    input wire WR, //write enable(indicates a write operation is requested.)
    input wire address, //A0 of read/write Logic (Address bus signal that specifies the address for read/write operations.)
    input wire[7:0]   data_bus_in, // 8-bit data bus input signal that carries the data to be written.

    // Internal Bus
     inout wire   [7:0]   internal_data_bus, //for data bus buffer output( 8-bit internal data bus that buffers the data being written or read.)
    output  wire write_initial_command_word_1, //Output signal indicating a write operation for initializing command word 1.
    output  wire write_initial_command_word_2, //Output signal indicating a write operation for initializing command words 2.
    output  wire write_initial_command_word_3, //Output signal indicating a write operation for initializing command words 3.
    output  wire write_initial_command_word_4, //Output signal indicating a write operation for initializing command words 4.
    output  wire write_operation_control_word_1, //Output signal indicating a write operation for operation control word 1.
    output  wire write_operation_control_word_2, //Output signal indicating a write operation for operation control word 2.
    output  wire write_operation_control_word_3, //Output signal indicating a write operation for operation control word 3.
    output  wire read //Output signal indicating a read operation.de
);

    assign internal_bus = (~WR & ~CS) ? data_bus_in : internal_data_bus;
    assign data_bus_buffer_out = (~RD & ~CS) ? internal_data_bus : 8'bzzzzzzzz;
    
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
