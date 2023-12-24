module PriorityResolver_TB;

  reg mode;
  reg [7:0] interrupt_mask;
  reg [7:0] highest_level_in_service;
  reg [7:0] interrupt_request_register;
  reg [7:0] in_service_register;

  wire [7:0] interrupt;

  PriorityResolver dut (
    .mode(mode),
    .interrupt_mask(interrupt_mask),
    .highest_level_in_service(highest_level_in_service),
    .interrupt_request_register(interrupt_request_register),
    .in_service_register(in_service_register),
    .interrupt(interrupt)
  );


 initial
   begin

    // Test case 2
     #100
    mode = 1;
  interrupt_mask = 8'b0000000;
    highest_level_in_service = 8'b00000100;
   interrupt_request_register = 8'b10010001;
   in_service_register = 8'b00000000;
    #10; // Allow some time for computation
    $display("At time %t, interrupt (Case 2) = %b", $time, interrupt);
       #100
    mode = 1;
  interrupt_mask = 8'b0000000;
    highest_level_in_service = 8'b00000001;
   interrupt_request_register = 8'b10010001;
   in_service_register = 8'b00000000;
    #10; // Allow some time for computation
    $display("At time %t, interrupt (Case 2) = %b", $time, interrupt);
     
  end

endmodule
