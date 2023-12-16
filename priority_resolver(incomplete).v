// Code your design here
module Priority_Resolver (
 
  input [7:0] interrupt_mask,

  
  // Inputs  
  input [7:0] interrupt_request_register,
  input [7:0] in_service_register,
  input mode,
  // Outputs
  output [7:0] interrupt
);


  wire [7:0] masked_interrupt_request;
  parameter anothermode_irr=interrupt_request_register;

  assign masked_interrupt_request = interrupt_request_register & ~interrupt_mask;
  if(mode==0)
    begin
      
    always(interrupt_request_register)
      begin
        if(masked_interrupt_request[0]==1'b)
          interrupt=8'b1;
        if(masked_interrupt_request[1]==1'b)
          2:interrupt=8'b10;
        if(masked_interrupt_request[2]==1'b)
          2:interrupt=8'b100;
        if(masked_interrupt_request[3]==1'b)
          2:interrupt=8'b1000;
        if(masked_interrupt_request[4]==1'b)
          2:interrupt=8'b10000;
        if(masked_interrupt_request[5]==1'b)
          2:interrupt=8'b100000;
        if(masked_interrupt_request[6]==1'b)
          2:interrupt=8'b1000000;
        if(masked_interrupt_request[7]==1'b)
          2:interrupt=8'b10000000;
      end
    end
  else
    begin
      always(interrupt_request_register)
        begin
          if(masked_interrupt_request[0]==1'b)
            begin
              anothermode_irr={anothermode_irr[0], anothermode_irr[7:1]};
              masked_interrupt_request=anothermode_irr & ~interrupt_mask;
              interrupt=8'b1;
            end
          if(masked_interrupt_request[1]==1'b)
            begin
              anothermode_irr={anothermode_irr[0], anothermode_irr[7:1]};
              masked_interrupt_request=anothermode_irr & ~interrupt_mask;
              interrupt=8'b10;
            end
          if(masked_interrupt_request[2]==1'b)
            begin
              anothermode_irr={anothermode_irr[0], anothermode_irr[7:1]};
              masked_interrupt_request=anothermode_irr & ~interrupt_mask;
              interrupt=8'b100;
            end
          if(masked_interrupt_request[3]==1'b)
            begin
              anothermode_irr={anothermode_irr[0], anothermode_irr[7:1]};
              masked_interrupt_request=anothermode_irr & ~interrupt_mask;
              interrupt=8'b1000;
            end
          if(masked_interrupt_request[4]==1'b)
            begin
              anothermode_irr={anothermode_irr[0], anothermode_irr[7:1]};
              masked_interrupt_request=anothermode_irr & ~interrupt_mask;
              interrupt=8'b10000;
            end
          if(masked_interrupt_request[5]==1'b)
            begin
              anothermode_irr={anothermode_irr[0], anothermode_irr[7:1]};
              masked_interrupt_request=anothermode_irr & ~interrupt_mask;
              interrupt=8'b100000;
            end
          if(masked_interrupt_request[6]==1'b)
            begin
              anothermode_irr={anothermode_irr[0], anothermode_irr[7:1]};
              masked_interrupt_request=anothermode_irr & ~interrupt_mask;
              interrupt=8'10000000;
            end
          if(masked_interrupt_request[7]==1'b)
            begin
              anothermode_irr={anothermode_irr[0], anothermode_irr[7:1]};
              masked_interrupt_request=anothermode_irr & ~interrupt_mask;
              interrupt=8'b10000000;
            end
        end
    end
endmodule
