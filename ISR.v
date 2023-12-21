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

	function [7:0] resolve_priority;                     //this function determines the priority level of the set bits in the request vector, 
		input [7:0] request;                             //with higher priority assigned to lower bit positions. The output is an 8-bit binary value representing the priority
		if (request[0] == 1'b1)
			resolve_priority = 8'b00000001;
		else if (request[1] == 1'b1)
			resolve_priority = 8'b00000010;
		else if (request[2] == 1'b1)
			resolve_priority = 8'b00000100;
		else if (request[3] == 1'b1)
			resolve_priority = 8'b00001000;
		else if (request[4] == 1'b1)
			resolve_priority = 8'b00010000;
		else if (request[5] == 1'b1)
			resolve_priority = 8'b00100000;
		else if (request[6] == 1'b1)
			resolve_priority = 8'b01000000;
		else if (request[7] == 1'b1)
			resolve_priority = 8'b10000000;
		else
			resolve_priority = 8'b00000000;
	endfunction    
    


	always @(*) begin
		next_highest_level_in_service = next_in_service_register & ~interrupt_special_mask;
		next_highest_level_in_service = KF8259_Common_Package_rotate_right(next_highest_level_in_service, priority_rotate);
		next_highest_level_in_service = KF8259_Common_Package_resolv_priority(next_highest_level_in_service);
		next_highest_level_in_service = KF8259_Common_Package_rotate_left(next_highest_level_in_service, priority_rotate);
	end


    
endmodule