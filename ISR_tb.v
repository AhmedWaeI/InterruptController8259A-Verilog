module ISR_tb;

  // Signals
  reg mode;
  reg [2:0] modes_of_end_of_interrupt;
  reg [7:0] interrupt_special_mask;
  reg [7:0] highest_priority_interrupt;
  reg acknowledge;
  reg [7:0] end_of_interrupt;
  reg [3:0] specific_level_clear;

  wire [7:0] in_service_register;
  wire [7:0] last_serviced;

  // Instantiate ISR module
  ISR isr_module (
    .mode(mode),
    .modes_of_end_of_interrupt(modes_of_end_of_interrupt),
    .interrupt_special_mask(interrupt_special_mask),
    .highest_priority_interrupt(highest_priority_interrupt),
    .acknowledge(acknowledge),
    .end_of_interrupt(end_of_interrupt),
    .specific_level_clear(specific_level_clear),
    .in_service_register(in_service_register),
    .last_serviced(last_serviced)
  );

  // Continuous printing for Test Case 1
  always @(in_service_register or last_serviced) begin
    $display("Test Case 1: Automatic EOI");
    $display("in_service_register = %b", in_service_register);
    $display("last_serviced = %b", last_serviced);
    $display("\n");
  end

  // Initial Stimulus
  initial begin
    // Test case 1: Automatic EOI
    mode = 1;
    acknowledge = 1;
    highest_priority_interrupt = 8'b00100000;
    end_of_interrupt = 8'b00100000;
    interrupt_special_mask = 8'b00000000; // Define interrupt_special_mask
    #10;
    acknowledge = 0;
    #10;

  end

endmodule
