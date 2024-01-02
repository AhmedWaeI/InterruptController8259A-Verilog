module ISR (
   input   wire   [2:0]   priority_rotate,
   input   wire   [7:0]   interrupt_special_mask,
   input   wire   [7:0]   interrupt,   //from priority register  
   input   wire			  reset,//remove 
   input   wire           latch_in_service, //flag from contol logic to indicate the start of interrupt
   input   wire   [7:0]   end_of_interrupt, // flag from contol logic to indicate the end of interrupt

   output  reg    [7:0]   in_service_register, // given to priority register
   output  reg    [7:0]   highest_level_in_service // given to data bus 
);
   wire [7:0] next_in_service_register;

   assign next_in_service_register = (in_service_register & ~end_of_interrupt) 
                                        | (latch_in_service == 1'b1 ? interrupt : 8'b00000000); //updating the next_in_service_register by considering both the
                                                                                                                                    // clearing of ended interrupts and the conditional inclusion of new 
                                                                                                                                    //interrupts based on the latch signal
   always @(reset)
    if (reset)
        in_service_register <= 8'b00000000;                 // If _the reset signal is asserted, it sets in_service_register to 8'b00000000
    else
        in_service_register <= next_in_service_register;    //f the reset signal is not asserted, it sets in_service_register to the value of next_in_service_register
   
    reg [7:0] next_highest_level_in_service;
   
    always @(*) begin
		next_highest_level_in_service = next_in_service_register & ~interrupt_special_mask;  // interrupt special mask contains active intrupts equals zero and non active equal one 
		next_highest_level_in_service =next_in_service_register >> priority_rotate;
	end

    always @(*)
		if (reset)
			highest_level_in_service <= 8'b00000000;
		else
			highest_level_in_service <= next_highest_level_in_service;
    
endmodule
