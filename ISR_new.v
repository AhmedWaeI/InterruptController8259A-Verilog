module ISR (
   input   wire           mode, // 1=automatic , 0=end of interrupt
   input   wire   [2:0]   modes_of_end_of_interrupt, // comes from ocw2 D7-D5
   input   wire   [7:0]   interrupt_special_mask,
   input   wire   [7:0]   highest_priority_interrupt,   //from priority register  
   input   wire           acknowledge, //flag from contol logic to indicate the start of interrupt //latch in service
   input   wire   [7:0]   end_of_interrupt, // flag from contol logic to indicate the end of interrupt
   input   wire   [2:0]   specific_level_clear, //comes from ocw2 L0-L2

   output  reg    [7:0]   in_service_register, // given to priority register
   output  reg    [7:0]   last_serviced // given to data bus & priority register
);
   reg [7:0] next_in_service_register;
    always@* begin
       next_in_service_register = (acknowledge == 1'b1 ? highest_priority_interrupt : 8'b00000000); 
        in_service_register = next_in_service_register;    
   end
    reg [7:0] next_last_serviced;
   
    always @* begin
		if(mode==1'b1 && acknowledge==1'b0) begin //automatic eoi command
			in_service_register=(in_service_register & ~end_of_interrupt);
			next_last_serviced = highest_priority_interrupt & ~interrupt_special_mask;
			end

		if(mode==1'b1 && acknowledge==1'b0)begin

			if(modes_of_end_of_interrupt==3'b001)begin  //non specific eoi command

			  if(interrupt_special_mask==8'b00000000)begin
				in_service_register=(in_service_register & ~end_of_interrupt);
				next_last_serviced = highest_priority_interrupt & ~interrupt_special_mask;
			  end

			  else begin
				in_service_register=in_service_register;
				next_last_serviced=highest_priority_interrupt & ~interrupt_special_mask;
			  end

			end

			if(modes_of_end_of_interrupt==3'b011)begin //specific eoi command
			  case (specific_level_clear) 
                3'b000: in_service_register = in_service_register & 8'b11111110;   
                3'b001: in_service_register = in_service_register & 8'b11111101; 
                3'b010: in_service_register = in_service_register & 8'b11111011; 
                3'b011: in_service_register = in_service_register & 8'b11110111; 
                3'b100: in_service_register = in_service_register & 8'b11101111; 
                3'b101: in_service_register = in_service_register & 8'b11011111; 
                3'b110: in_service_register = in_service_register & 8'b10111111; 
                3'b111: in_service_register = in_service_register & 8'b01111111; 
			  endcase
			  next_last_serviced=in_service_register;

		end
	end
	end

    always @* begin
			last_serviced = next_last_serviced;
    end
    
endmodule