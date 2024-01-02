module PriorityResolver (
  // Inputs from control logic
  input      mode,
  input   [7:0]   interrupt_mask,
  input   [7:0]   interrupt_special_mask,
  input           special_fully_nest_config,
  input   [7:0]   highest_level_in_service,

  // Inputs
  input   [7:0]   interrupt_request_register,
  input   [7:0]   in_service_register,

  // Outputs
  output reg  [7:0]   interrupt
);
  // Masked flags
  reg   [7:0]   masked_interrupt_request;
  reg   [7:0]   masked_in_service;

  // Resolve priority
  reg   [7:0]   rotated_request;
  reg   [7:0]   rotated_highest_level_in_service;
  reg   [7:0]   rotated_in_service;
  reg   [7:0]   priority_mask;
  reg  [7:0]  rotated_interrupt;
  reg   [7:0]   resolv_priority;

  // Rotate and resolve priority logic
  always @(*) begin
    masked_interrupt_request = interrupt_request_register & ~interrupt_mask;
    masked_in_service = in_service_register & ~interrupt_special_mask;

    case (mode)
      1'b0: begin // Automatic Rotation
        rotated_request = masked_interrupt_request << 1 | masked_interrupt_request >> 7;
        rotated_highest_level_in_service = highest_level_in_service << 1 | highest_level_in_service >> 7;
        rotated_in_service = masked_in_service << 1 | masked_in_service >> 7;
      end

      1'b1: begin // Fully Nested
        if (special_fully_nest_config == 1'b1)
          rotated_in_service = (rotated_in_service & ~rotated_highest_level_in_service) | {rotated_highest_level_in_service[6:0], 1'b0};
      end

      default: begin // Default case
        // Handle default case, if needed
      end
    endcase
  end

  always @(*) begin
    // Priority Mask Logic
    case (rotated_in_service)
      8'b00000001: priority_mask = 8'b00000000;
      8'b00000011: priority_mask = 8'b00000001;
      8'b00000111: priority_mask = 8'b00000011;
      8'b00001111: priority_mask = 8'b00000111;
      8'b00011111: priority_mask = 8'b00001111;
      8'b00111111: priority_mask = 8'b00011111;
      8'b01111111: priority_mask = 8'b00111111;
      8'b11111111: priority_mask = 8'b01111111;
      default:      priority_mask = 8'b11111111;
    endcase

    // Resolved Priority Logic
    case (rotated_request)
      8'b00000001: resolv_priority = 8'b00000001;
      8'b00000010: resolv_priority = 8'b00000010;
      8'b00000100: resolv_priority = 8'b00000100;
      8'b00001000: resolv_priority = 8'b00001000;
      8'b00010000: resolv_priority = 8'b00010000;
      8'b00100000: resolv_priority = 8'b00100000;
      8'b01000000: resolv_priority = 8'b01000000;
      8'b10000000: resolv_priority = 8'b10000000;
      default:      resolv_priority = 8'b00000000;
    endcase

    // Assign Rotated Interrupt
     rotated_interrupt = resolv_priority & priority_mask;

    // Output Interrupt based on priority rotation
    case (mode)
      1'b0: interrupt = { rotated_interrupt[6:0], rotated_interrupt[7] }; // Automatic Rotation
      1'b1: interrupt = rotated_interrupt; // Fully Nested
      default: interrupt = rotated_interrupt; // Default case (same as Fully Nested)
    endcase
  end

endmodule
