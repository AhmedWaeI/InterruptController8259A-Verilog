module Interrupt_Request(
    input wire Level_OR_Edge_trigger, //flag which shows the value of the bit[3] in ICW1
    input wire [7:0] Interrupt_Request_Pins, //input/output devices 
    output reg [7:0] Interrupt_Request_Reg   
);

    reg [7:0] last_Int_Req_Pin_value;
   
    genvar ir_bit_no;
    generate
        for ( ir_bit_no = 0; ir_bit_no <= 7; ir_bit_no = ir_bit_no + 1) begin
           always @(Interrupt_Request_Pins) begin
               if(Level_OR_Edge_trigger == 1'b0) begin   //edge trigger mode is on
                    if ((~last_Int_Req_Pin_value[ir_bit_no] )& Interrupt_Request_Pins[ir_bit_no]) begin
                        Interrupt_Request_Reg[ir_bit_no] <= Interrupt_Request_Pins[ir_bit_no];
                    end else begin
                       last_Int_Req_Pin_value[ir_bit_no] <= Interrupt_Request_Pins[ir_bit_no];
                        Interrupt_Request_Reg[ir_bit_no] <= 1'b0;
                    end
                end

               if(Level_OR_Edge_trigger == 1'b1) begin  // level trigger mode is on
                    if (Interrupt_Request_Pins[ir_bit_no] == 1'b1 || Interrupt_Request_Pins[ir_bit_no] == 1'b0) begin
                        Interrupt_Request_Reg[ir_bit_no] <= Interrupt_Request_Pins[ir_bit_no];
                    end else begin
                        Interrupt_Request_Reg[ir_bit_no] <= Interrupt_Request_Reg[ir_bit_no];
                    end
                end
            end
        end
    endgenerate
endmodule
