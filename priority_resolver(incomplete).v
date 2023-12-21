module rotate_right (
    input [7:0] source,
    input [2:0] rotate,
    output reg [7:0] rotate_right_output
);

    always @* begin
        case(rotate)
            3'b000: rotate_right_output = { source[0], source[7:1] };
            3'b001: rotate_right_output = { source[1:0], source[7:2] };
            3'b010: rotate_right_output = { source[2:0], source[7:3] };
            3'b011: rotate_right_output = { source[3:0], source[7:4] };
            3'b100: rotate_right_output = { source[4:0], source[7:5] };
            3'b101: rotate_right_output = { source[5:0], source[7:6] };
            3'b110: rotate_right_output = { source[6:0], source[7] };
            default: rotate_right_output = source;
        endcase
    end

endmodule

module resolv_priority(
    input [7:0] request,
    output reg [7:0] resolv_priority
);

    always @* begin
        if (request[0] == 1'b1) resolv_priority = 8'b00000001;
        else if (request[1] == 1'b1) resolv_priority = 8'b00000010;
        else if (request[2] == 1'b1) resolv_priority = 8'b00000100;
        else if (request[3] == 1'b1) resolv_priority = 8'b00001000;
        else if (request[4] == 1'b1) resolv_priority = 8'b00010000;
        else if (request[5] == 1'b1) resolv_priority = 8'b00100000;
        else if (request[6] == 1'b1) resolv_priority = 8'b01000000;
        else if (request[7] == 1'b1) resolv_priority = 8'b10000000;
        else resolv_priority = 8'b00000000;
    end

endmodule


module PriorityResolver (
  // Inputs from control logic
  input   [2:0]   priority_rotate,
  input   [7:0]   interrupt_mask,
  input   [7:0]   interrupt_special_mask,
  input           special_fully_nest_config,
  input   [7:0]   highest_level_in_service,

  // Inputs
  input   [7:0]   interrupt_request_register,
  input   [7:0]   in_service_register,

  // Outputs
  output  [7:0]   interrupt
);
  // Masked flags
  reg   [7:0]   masked_interrupt_request;
  reg   [7:0]   masked_in_service;

  // Resolve priority
  reg   [7:0]   rotated_request;
  reg   [7:0]   rotated_highest_level_in_service;
  reg   [7:0]   rotated_in_service;
  reg   [7:0]   priority_mask;
  reg   [7:0]   rotated_interrupt;
  reg   [7:0]   resolv_priority;
  rotate_left_right m

  // Rotate and resolve priority logic
  always@(*) begin
    masked_interrupt_request = interrupt_request_register & ~interrupt_mask;
    masked_in_service = in_service_register & ~interrupt_special_mask;
    rotate_right m(masked_interrupt_request,priority_rotate,rotated_request)
    rotate_right n(highest_level_in_service,priority_rotate,rotated_highest_level_in_service)
    
    if (special_fully_nest_config == 1'b1)
      rotated_in_service = {masked_in_service[7-priority_rotate:0],masked_in_service[7:7-priority_rotate]} & ~rotated_highest_level_in_service | {rotated_highest_level_in_service[6:0], 1'b0};
    else
      rotated_in_service = {masked_in_service[7-priority_rotate:0],masked_in_service[7:7-priority_rotate]};
  end

  always@(*) begin
    if      (rotated_in_service[0] == 1'b1) priority_mask = 8'b00000000;
    else if (rotated_in_service[1] == 1'b1) priority_mask = 8'b00000001;
    else if (rotated_in_service[2] == 1'b1) priority_mask = 8'b00000011;
    else if (rotated_in_service[3] == 1'b1) priority_mask = 8'b00000111;
    else if (rotated_in_service[4] == 1'b1) priority_mask = 8'b00001111;
    else if (rotated_in_service[5] == 1'b1) priority_mask = 8'b00011111;
    else if (rotated_in_service[6] == 1'b1) priority_mask = 8'b00111111;
    else if (rotated_in_service[7] == 1'b1) priority_mask = 8'b01111111;
    else                                   priority_mask = 8'b11111111;
  end

  always@(*) begin
    if      (rotated_request[0] == 1'b1) resolv_priority = 8'b00000001;
    else if (rotated_request[1] == 1'b1) resolv_priority = 8'b00000010;
    else if (rotated_request[2] == 1'b1) resolv_priority = 8'b00000100;
    else if (rotated_request[3] == 1'b1) resolv_priority = 8'b00001000;
    else if (rotated_request[4] == 1'b1) resolv_priority = 8'b00010000;
    else if (rotated_request[5] == 1'b1) resolv_priority = 8'b00100000;
    else if (rotated_request[6] == 1'b1) resolv_priority = 8'b01000000;
    else if (rotated_request[7] == 1'b1) resolv_priority = 8'b10000000;
    else                                resolv_priority = 8'b00000000;
  end

  
  assign rotated_interrupt =  resolv_priority & priority_mask;
  assign interrupt = {rotated_interrupt[priority_rotate:7],rotated_interrupt[7:priority_rotate+1]}; 

endmodule
