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
		 $dumpfile("dump.vcd");
         $dumpvars;
    // Test case 2
     #100
        mode = 0;
        interrupt_mask = 8'b0000000;
        highest_level_in_service = 8'b00000001;
        interrupt_request_register = 8'b10010001;
        in_service_register = 8'b00000000;
        #10; // Allow some time for computation
        $display("At time %t, interrupt (Case 2) = %b", $time, interrupt);
        #100
        mode = 0;
        interrupt_mask = 8'b0000000;
        highest_level_in_service = 8'b00010000;
        interrupt_request_register = 8'b10010110;
        in_service_register = 8'b00000000;
        #10; // Allow some time for computation
        $display("At time %t, interrupt (Case 2) = %b", $time, interrupt);
        #100
        mode = 0;
        interrupt_mask = 8'b0000000;
        highest_level_in_service = 8'b10000000;
        interrupt_request_register = 8'b10010100;
        in_service_register = 8'b00000000;
        #100; // Allow some time for computation
        $display("At time %t, interrupt (Case 2) = %b", $time, interrupt);
        mode = 0;
        interrupt_mask = 8'b0000000;
        highest_level_in_service = 8'b10000000;
        interrupt_request_register = 8'b11000000;
        in_service_register = 8'b00000000;
        #100; // Allow some time for computation
        $display("At time %t, interrupt (Case 2) = %b", $time, interrupt);
        mode = 0;
        interrupt_mask = 8'b0000000;
        highest_level_in_service = 8'b00000010;
        interrupt_request_register = 8'b10000000;
        in_service_register = 8'b00000000;
        #100; // Allow some time for computation
        $display("At time %t, interrupt (Case 2) = %b", $time, interrupt);
        mode = 0;
        interrupt_mask = 8'b0000000;
        highest_level_in_service = 8'b00000010;
        interrupt_request_register = 8'b00000000;
        in_service_register = 8'b00000000;
        #100; // Allow some time for computation
        $display("At time %t, interrupt (Case 2) = %b", $time, interrupt);
    end

endmodule