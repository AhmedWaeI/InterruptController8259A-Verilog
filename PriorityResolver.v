module PriorityResolver (
 // Inputs from control logic
 input   mode,
 input  [7:0]  interrupt_mask,
 input  [7:0]  highest_level_in_service,
 input  [7:0]  interrupt_request_register,
 input  [7:0]  in_service_register,

 // Outputs
 output reg [7:0]  interrupt
);
  
 reg  [7:0] masked_interrupt_request;
 reg	[7:0] inservicemask;
 reg	[7:0] bottle;
 reg	[7:0] rotatedmask;
 reg	[7:0] rotatedirr;
  
 always@(*)
  begin
   masked_interrupt_request=interrupt_request_register& ~interrupt_mask;
   inservicemask=masked_interrupt_request;
 	 bottle=interrupt_request_register;
   rotatedmask=masked_interrupt_request;
  end
 always@(*)
  begin  
 	 rotatedirr=masked_interrupt_request;
  end
  
  

  
 always@(masked_interrupt_request)
  begin
   if(in_service_register==0)
    begin
     if(mode==0 || mode==1)
      begin
        
       if(inservicemask[0]==1) begin 
        interrupt=1; 
        inservicemask=inservicemask&1;
       end
       if(inservicemask[1]==1) begin 
        interrupt=2; 
        inservicemask=inservicemask&2;
       end
       if(inservicemask[2]==1) begin 
        interrupt=4; 
        inservicemask=inservicemask&4;
       end
       if(inservicemask[3]==1) begin 
        interrupt=8; 
        inservicemask=inservicemask&8;
       end
       if(inservicemask[4]==1) begin 
        interrupt=16; 
        inservicemask=inservicemask&16;
       end
       if(inservicemask[5]==1) begin 
        interrupt=32; 
        inservicemask=inservicemask&32;
       end
       if(inservicemask[6]==1) begin 
        interrupt=64; 
        inservicemask=inservicemask&64;
       end
       if(inservicemask[7]==1) begin 
        interrupt=128; 
        inservicemask=inservicemask&128;
       end     
        
      end
    end
    
  end
  
  
  always@(masked_interrupt_request)
  begin
    rotatedirr=inservicemask;
    bottle=inservicemask;
   if(in_service_register==0)
    begin
     if(mode==1)
      begin
       if(inservicemask[0]==1) begin 
        interrupt=1; 
        inservicemask=inservicemask&1;
        bottle= (bottle >> 1) | (bottle<<7);
        rotatedmask=rotatedmask>>1 | rotatedmask<<7;
        rotatedirr=bottle;
       end
       if(inservicemask[1]==1) begin 
        interrupt=2; 
        inservicemask=inservicemask&2;
        bottle=bottle >> 2 | bottle<<6;
        rotatedmask=rotatedmask>>2 | rotatedmask<<6;
        rotatedirr=bottle;
       end
       if(inservicemask[2]==1) begin 
        interrupt=4; 
        inservicemask=inservicemask&4;
        bottle=inservicemask >> 3 | inservicemask<<5;
        rotatedmask=rotatedmask>>3 | rotatedmask<<5;
        rotatedirr=bottle;
       end
       if(inservicemask[3]==1) begin 
        interrupt=8; 
        inservicemask=inservicemask&8;
        bottle=bottle >> 4 | bottle<<4;
        rotatedmask=rotatedmask>>4 | rotatedmask<<4;
        rotatedirr=bottle;
       end
       if(inservicemask[4]==1) begin 
        interrupt=16; 
        inservicemask=inservicemask&16;
        bottle = bottle >> 5 | bottle<<3;
        rotatedmask=rotatedmask>>5 | rotatedmask<<3;
        rotatedirr=bottle;
       end
       if(inservicemask[5]==1) begin 
        interrupt=32; 
        inservicemask=inservicemask&32;
        bottle=bottle >> 6 | bottle<<2;
        rotatedmask=rotatedmask>>6 | rotatedmask<<2;
        rotatedirr=bottle;
       end
       if(inservicemask[6]==1) begin 
        interrupt=64; 
        inservicemask=inservicemask&64;
        bottle=bottle >> 7 | bottle<<1;
        rotatedmask=rotatedmask>>7 | rotatedmask<<1;
        rotatedirr=bottle;
       end
       if(inservicemask[7]==1) begin 
        interrupt=128; 
        inservicemask=inservicemask&128;
        bottle=bottle;
        rotatedmask=rotatedmask;
        rotatedirr=bottle;
       end
        
        
      end
    end    
  end
 always@(*)
  begin
    if(mode==1)
    inservicemask=rotatedirr;
    interrupt=rotatedirr;
  end

endmodule
