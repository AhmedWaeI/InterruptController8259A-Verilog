// Enumerations for command 
typedef enum logic [1:0] {
  CMD_READY = 2'b00,
  WRITE_ICW2 = 2'b01,
  WRITE_ICW3 = 2'b10,
  WRITE_ICW4 = 2'b11
} command_state_t;

module ControlLogic (
  input wire CLK,
  input wire RESET,
  input wire RD,            // Read control signal
  input wire WR,            // Write control signal
  input wire ICW1_RECEIVED,
  input wire ICW2_RECEIVED,
  input wire OCW1_RECEIVED,  
  input wire OCW2_RECEIVED,
  input wire OCW3_RECEIVED,
  input wire [7:0] DATA_IN,  // Data bus from other blocks
  output wire [7:0] IV,      // Interrupt Vector
  output wire [1:0] CAS,     // Cascade Signals
  output wire EOI,           // End of Interrupt
  output reg IMR[7:0]        // Interrupt Mask Register
);
