// Code your design here
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
 reg	[7:0] rotatedmask;
 reg	[7:0] rotatedirr;
 reg	[7:0] rotatedmaskedirr;
  reg	[7:0] rotatedmaskedirr2;
  reg [2:0] rotationvalue; 

 always@(*)
  begin
   masked_interrupt_request=interrupt_request_register& ~interrupt_mask;
   inservicemask=masked_interrupt_request;
   rotatedmask=interrupt_mask;
  end
 always@(*)
  begin  
 	 rotatedirr=interrupt_request_register;
  end
 always@(*)
   begin
     if(highest_level_in_service[0]==1)
       begin
         rotatedirr=(interrupt_request_register>>1) | (interrupt_request_register<<7);
        rotatedmaskedirr= (interrupt_mask >> 1) | (interrupt_mask<<7);
        rotatedmaskedirr=rotatedirr&~rotatedmaskedirr;
         rotationvalue=1;
       end
         if(highest_level_in_service[1]==1)
       begin
         rotatedirr=(interrupt_request_register>>2) | (interrupt_request_register<<6);
         rotatedmaskedirr= (interrupt_mask >> 2) | (interrupt_mask<<6);
        rotatedmaskedirr=rotatedirr&~rotatedmaskedirr;
         rotationvalue=2;
       end
         if(highest_level_in_service[2]==1)
       begin
         rotatedirr=(interrupt_request_register>>3) | (interrupt_request_register<<5);
         rotatedmaskedirr= (interrupt_mask >> 3) | (interrupt_mask<<5);
        rotatedmaskedirr=rotatedirr&~rotatedmaskedirr;
         rotationvalue=3;
       end
         if(highest_level_in_service[3]==1)
       begin
         rotatedirr=(interrupt_request_register>>4) | (interrupt_request_register<<4);
         rotatedmaskedirr= (interrupt_mask >> 4) | (interrupt_mask<<4);
        rotatedmaskedirr=rotatedirr&~rotatedmaskedirr;
         rotationvalue=4;
       end
         if(highest_level_in_service[4]==1)
       begin
         rotatedirr=(interrupt_request_register>>5) | (interrupt_request_register<<3);
         rotatedmaskedirr= (interrupt_mask >> 5) | (interrupt_mask<<3);
        rotatedmaskedirr=rotatedirr&~rotatedmaskedirr;
         rotationvalue=5;
       end
         if(highest_level_in_service[5]==1)
       begin
         rotatedirr=(interrupt_request_register>>6) | (interrupt_request_register<<2);
         rotatedmaskedirr= (interrupt_mask >> 6) | (interrupt_mask<<2);
        rotatedmaskedirr=rotatedirr&~rotatedmaskedirr;
         rotationvalue=6;
       end
         if(highest_level_in_service[6]==1)
       begin
         rotatedirr=(interrupt_request_register>>7) | (interrupt_request_register<<1);
        rotatedmaskedirr= (interrupt_mask >> 1) | (interrupt_mask<<7);
        rotatedmaskedirr=rotatedirr&~rotatedmaskedirr;
         rotationvalue=7;
       end
         if(highest_level_in_service[7]==1)
       begin
         rotatedirr=interrupt_request_register; 
        rotatedmaskedirr= interrupt_mask; 
        rotatedmaskedirr=rotatedirr&~rotatedmaskedirr;
         rotationvalue=0;
       end
     if(highest_level_in_service==0)
       begin
         rotatedmaskedirr=masked_interrupt_request;
         rotationvalue=0;
       end
   end
  always@(*)
    begin
      rotatedmaskedirr2=rotatedmaskedirr;
    end
  
 always@(masked_interrupt_request)
  begin
   if(in_service_register==0)
    begin
     if(mode==0 )
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
        if(inservicemask==0)
          begin
            interrupt=128;
          end
        
      end
    end
    
  end
  
  
  always@(rotatedmaskedirr)
  begin

   if(in_service_register==0)
    begin
     if(mode==1)
      begin
       if(rotatedmaskedirr2[0]==1) begin 
         interrupt= (1<<rotationvalue) |(1>>(8-rotationvalue)) ; 
        rotatedmaskedirr2=rotatedmaskedirr2&1;
   
       end
       if(rotatedmaskedirr2[1]==1) begin 
         interrupt= (2<<rotationvalue) |(2>>(8-rotationvalue)) ; 
        rotatedmaskedirr2=rotatedmaskedirr2&2;
       end
       if(rotatedmaskedirr2[2]==1) begin 
         interrupt= (4<<rotationvalue) |(4>>(8-rotationvalue)) ; 
        rotatedmaskedirr2=rotatedmaskedirr2&4;      
         
       end
       if(rotatedmaskedirr2[3]==1) begin 
         interrupt= (8<<rotationvalue) |(8>>(8-rotationvalue)) ; 
        rotatedmaskedirr2=rotatedmaskedirr2&8;

       end
       if(rotatedmaskedirr2[4]==1) begin 
        interrupt= (16<<rotationvalue) |(16>>(8-rotationvalue)) ; 
        rotatedmaskedirr2=rotatedmaskedirr2&16;

       end
       if(rotatedmaskedirr2[5]==1) begin 
         interrupt= (32<<rotationvalue) |(32>>(8-rotationvalue)) ; 
        rotatedmaskedirr2=rotatedmaskedirr2&32;

       end
       if(rotatedmaskedirr2[6]==1) begin 
         interrupt= (64<<rotationvalue) |(64>>(8-rotationvalue)) ; 
        rotatedmaskedirr2=rotatedmaskedirr2&64;

       end
       if(rotatedmaskedirr2[7]==1) begin 
         interrupt= (128<<rotationvalue) |(128>>(8-rotationvalue)) ; 
        rotatedmaskedirr2=rotatedmaskedirr2&128;
       end
        if(rotatedmaskedirr2==0)
          begin
            interrupt=128;
          end
      end
    end    
  end


endmodule
