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

  // Registers for command words
  reg [7:0] icw1, icw2, icw3, icw4; // Initialization Command Words
  reg [7:0] ocw1, ocw2, ocw3;       // Operation Command Words

  // Internal signals
  reg [1:0] command_state;
  reg [1:0] next_command_state;

  // Clocked process for state machine
  always @(posedge CLK or negedge RESET) begin
    if (!RESET)
      command_state <= CMD_READY;
    else
      command_state <= next_command_state;
  end

  // State machine
  always @(ICW1_RECEIVED, ICW2_RECEIVED, command_state, DATA_IN) begin
    case (command_state)
      CMD_READY:
        if (ICW1_RECEIVED)begin
             next_command_state = WRITE_ICW2;
        end
         
      WRITE_ICW2:
        if (ICW2_RECEIVED) begin
          icw2 <= DATA_IN;
          if (SNGL == 1'b1)
            next_command_state = WRITE_ICW3;
          else if (ICW4 == 1'b1)
            next_command_state = WRITE_ICW4;
          else
            next_command_state = CMD_READY;
        end

      WRITE_ICW3:
         begin
          icw3 <= DATA_IN;
          if (ICW4 == 1'b1)
            next_command_state = WRITE_ICW4;
          else
            next_command_state = CMD_READY;
        end

      WRITE_ICW4:
         begin
          icw4 <= DATA_IN;
          next_command_state = CMD_READY;
        end
      default:
        next_command_state = CMD_READY;
    endcase
  end

  // Handling OCW_RECEIVED signals
  always @(posedge CLK, negedge RESET) begin
    if (!RESET) begin
      // Reset conditions or initializations can be added here if needed
    end
    else begin
      if(OCW1_RECEIVED) begin
        ocw1 <= Data_IN;
        IMR <= DATA_IN;
      end
      else if (OCW2_RECEIVED) begin
        ocw2 <= Data_IN;
      end
      else if (OCW3_RECEIVED) begin
        ocw3 <= Data_IN;
      end
    end
  end

  // Commented Assignments for better understanding
  // ICW1
  assign wire LTIM = icw1[3]; // 1: level triggered mode, 0: edge triggered mode
  assign wire ICW4 = icw1[0]; // 1: ICW4 is needed 
  assign wire SNGL = icw1[1]; // 1: ICW3 is needed

  // ICW2
  assign wire [4:0] T7_T3 = icw2[7:3]; // 5 most significant bits of the vector address register found in ICW2

  // ICW4
  assign wire SFNM = icw4[4]; // 1: special fully nested mode is programmed
  assign wire AEOI = icw4[1]; // 1: automatic end of interrupt mode is programmed
  assign wire BUF = icw4[3];  // 1: buffered mode is programmed
  assign wire M_S = icw4[2];  // If buffered mode is selected: 1 for master, 0 for slave; else no function

  // OCW3
  assign wire Read_command[1:0] = ocw3[1:0];       // 01: READ IR register, 11: READ IS register on the next read cycle
  assign wire Special_Mask_Mode[1:0] = ocw3[6:5]; // 01: reset special mask, 11: set special mask
  assign wire POLL = ocw3[2];                     // 1: poll, 0: no poll

endmodule
