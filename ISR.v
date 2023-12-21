module ISR (
   input   wire   [2:0]   priority_rotate,
   input   wire   [7:0]   interrupt_special_mask,
   input   wire   [7:0]   interrupt,
   input	  wire					reset,
   input   wire           latch_in_service,
   input   wire   [7:0]   end_of_interrupt,

   output  reg    [7:0]   in_service_register,
    output reg   [7:0]   highest_level_in_service
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
   

    
endmodule