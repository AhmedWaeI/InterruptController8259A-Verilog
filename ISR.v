module ISR (
   input   wire   [2:0]   priority_rotate,
   input   wire   [7:0]   interrupt_special_mask,
   input   wire   [7:0]   interrupt,
   input   wire			  reset,
   input   wire           latch_in_service,
   input   wire   [7:0]   end_of_interrupt,

   output  reg    [7:0]   in_service_register,
   output  reg    [7:0]   highest_level_in_service
);
   wire [7:0] next_in_service_register;
   assign next_in_service_register = (in_service_register & ~end_of_interrupt) | (latch_in_service == 1'b1 ? interrupt : 8'b00000000); //updating the next_in_service_register by considering both the
                                                                                                                                    // clearing of ended interrupts and the conditional inclusion of new 
                                                                                                                                    //interrupts based on the latch signal
   always @(reset)
    if (reset)
        in_service_register <= 8'b00000000;                 // If _the reset signal is asserted, it sets in_service_register to 8'b00000000
    else
        in_service_register <= next_in_service_register;    //f the reset signal is not asserted, it sets in_service_register to the value of next_in_service_register
   
    reg [7:0] next_highest_level_in_service;
    reg [7:0]  rotated;
    reg [7:0]  resolve_priority;

	always@(*) begin      // rotate right 
      case(priority_rotate)
            3'b000: rotated = { next_highest_level_in_service[0], next_highest_level_in_service[7:1] };
            3'b001: rotated = { next_highest_level_in_service[1:0], next_highest_level_in_service[7:2] };
            3'b010: rotated = { next_highest_level_in_service[2:0], next_highest_level_in_service[7:3] };
            3'b011: rotated = { next_highest_level_in_service[3:0], next_highest_level_in_service[7:4] };
            3'b100: rotated = { next_highest_level_in_service[4:0], next_highest_level_in_service[7:5] };
            3'b101: rotated = { next_highest_level_in_service[5:0], next_highest_level_in_service[7:6] };
            3'b110: rotated = { next_highest_level_in_service[6:0], next_highest_level_in_service[7] };
            default: rotated = next_highest_level_in_service;
      endcase
   end
    
    
    always@(*) begin
        if(next_highest_level_in_service[0] == 1'b1)
			resolve_priority = 8'b00000001;
		else if (next_highest_level_in_service[1] == 1'b1)
			resolve_priority = 8'b00000010;
		else if (next_highest_level_in_service[2] == 1'b1)
			resolve_priority = 8'b00000100;
		else if (next_highest_level_in_service[3] == 1'b1)
			resolve_priority = 8'b00001000;
		else if (next_highest_level_in_service[4] == 1'b1)
			resolve_priority = 8'b00010000;
		else if (next_highest_level_in_service[5] == 1'b1)
			resolve_priority = 8'b00100000;
		else if (next_highest_level_in_service[6] == 1'b1)
			resolve_priority = 8'b01000000;
		else if (next_highest_level_in_service[7] == 1'b1)
			resolve_priority = 8'b10000000;
		else
			resolve_priority = 8'b00000000;
        
    end







always@(*)  // rotate left 
    begin
      case(priority_rotate)
            3'b000: rotated = { next_highest_level_in_service[6:0], next_highest_level_in_service[7] };
            3'b001: rotated = { next_highest_level_in_service[5:0], next_highest_level_in_service[7:6] };
            3'b010: rotated = { next_highest_level_in_service[4:0], next_highest_level_in_service[7:5] };
            3'b011: rotated = { next_highest_level_in_service[3:0], next_highest_level_in_service[7:4] };
            3'b100: rotated = { next_highest_level_in_service[2:0], next_highest_level_in_service[7:3] };
            3'b101: rotated = { next_highest_level_in_service[1:0], next_highest_level_in_service[7:2] };
            3'b110: rotated = { next_highest_level_in_service[0], next_highest_level_in_service[7:1] };
            3'b111: rotated = next_highest_level_in_service;
            default: rotated = next_highest_level_in_service;
        endcase
    end 





	always @(*) begin
		next_highest_level_in_service = next_in_service_register & ~interrupt_special_mask;
		next_highest_level_in_service = rotated;
		next_highest_level_in_service = resolve_priority;
		next_highest_level_in_service = rotated;
	end


    
endmodule