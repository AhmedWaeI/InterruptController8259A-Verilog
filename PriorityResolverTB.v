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
    // Test case 1
    mode = 0;
    interrupt_mask = 8'b0000000;
    highest_level_in_service = 8'b00000000;
    interrupt_request_register = 8'b11110100;
    in_service_register = 8'b00000000;
    #10; // Allow some time for computation
    $display("At time %t, interrupt (Case 1) = %b", $time, interrupt);

    // Test case 2
    mode = 1;
  interrupt_mask = 8'b0000000;
    highest_level_in_service = 8'b00000000;
   interrupt_request_register = 8'b00000100;
   in_service_register = 8'b00000000;
    #2; // Allow some time for computation
    $display("At time %t, interrupt (Case 2) = %b", $time, interrupt);
  end

endmodule
