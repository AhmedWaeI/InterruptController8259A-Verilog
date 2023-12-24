
// 8259A_Bus_Control_Logic
// implements the data bus buffering and read/write control logic for the 8259A PIC

module Bus_Control_Logic (
    input wire reset,

    input wire CS_bar, //chip select active low
    input wire RD_bar, //read enable(indicates a read operation is requested.)
    input wire WR_bar, //write enable(indicates a write operation is requested.)
    input wire A0, //A0 of read/write Logic (Address bus signal that specifies the address for read/write operations.)
     input wire [7:0] data_bus_buffer_in,, // 8-bit data bus input signal that carries the data to be written.

    // Internal Bus
     inout wire   [7:0]   internal_bus,
    
    output wire [7:0] data_bus_buffer_out,  //for data bus buffer output( 8-bit internal data bus that buffers the data being written or read.)
    output  wire ICW_1, //Output signal indicating a write operation for initializing command word 1.
    output  wire ICW_2, //Output signal indicating a write operation for initializing command words 2.
    output  wire ICW_3, //Output signal indicating a write operation for initializing command words 3.
    output  wire ICW_4, //Output signal indicating a write operation for initializing command words 4.
    output  wire OCW_1, //Output signal indicating a write operation for operation control word 1.
    output  wire OCW_2, //Output signal indicating a write operation for operation control word 2.
    output  wire OCW_3, //Output signal indicating a write operation for operation control word 3.
    output  wire read //Output signal indicating a read operation
);

    assign internal_bus = (~WR_bar & ~CS_bar) ? data_bus_buffer_in : internal_data_bus;
    assign data_bus_buffer_out = (~RD_bar & ~CS_bar) ? internal_bus : 8'bzzzzzzzz;
    
    // Generate write request flags
    assign ICW_1   = ~WR_bar & ~A0 & internal_bus[4];
    assign ICW_2 = ~WR_bar & A0;
    assign ICW_3 = ~WR_bar & ~A0 & ~internal_bus[4] & ~internal_bus[1];
    assign ICW_4 = ~WR_bar & A0;
    assign OCW_1 = ~WR_bar & A0;
    assign OCW_2 = ~WR_bar & ~A0 & ~internal_bus[4] & ~internal_bus[3];
    assign OCW_3 = ~WR_bar & ~A0 & ~internal_bus[4] & internal_bus[3];

    //
    // Read Control (when read enabledand chip selected)
    //
    assign read = ~RD_bar  & ~CS_bar; //read if chip selected and read enabled

endmodule
