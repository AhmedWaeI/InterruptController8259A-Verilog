module IMRModule (
  input wire [7:0] mask_vector,
  input wire [7:0] active_interrupts,
  output wire [7:0] imr_output
);

  reg [7:0] imr_register;

  always @* begin
    imr_register = mask_vector & ~active_interrupts;
  end

  assign imr_output = imr_register;

endmodule
