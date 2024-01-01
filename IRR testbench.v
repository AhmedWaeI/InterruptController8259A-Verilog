module Interrupt_Request_tb;

  reg Level_OR_Edge_trigger;
  reg [7:0] Interrupt_Request_Pins;
  wire [7:0] Interrupt_Request_Reg;

  // Instantiate the Interrupt_Request module
  Interrupt_Request uut (
    .Level_OR_Edge_trigger(Level_OR_Edge_trigger),
    .Interrupt_Request_Pins(Interrupt_Request_Pins),
    .Interrupt_Request_Reg(Interrupt_Request_Reg)
  );

  // Stimulus
  initial begin
        $dumpfile("dump.vcd");
    $dumpvars;
    // Test case 1: Edge-triggered, 
    Level_OR_Edge_trigger = 0;
    Interrupt_Request_Pins = 8'b10000001;
    #10;
    $display("Test Case 1: Interrupt_Request_Reg = %b", Interrupt_Request_Reg);
    #10  
    // Test case 2: Level-triggered, 
    Level_OR_Edge_trigger = 1;
    Interrupt_Request_Pins = 8'b11001111;
    #10;
    $display("Test Case 2: Interrupt_Request_Reg = %b", Interrupt_Request_Reg);

    
// Test case 3: Level-triggered,
    Level_OR_Edge_trigger = 1;
    Interrupt_Request_Pins = 8'b11010011;
    #10;
    $display("Test Case 3: Interrupt_Request_Reg = %b", Interrupt_Request_Reg);

    // Add more test cases as needed

    // Terminate simulation
    $finish;
  end

endmodule
