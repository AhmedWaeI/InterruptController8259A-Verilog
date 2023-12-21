module IMRModule(rst, mask_vector, active_interrupts, imr_output);
  input wire rst;
  input wire [7:0] mask_vector;
  input wire [7:0] active_interrupts;
  output wire [7:0] imr_output;

  reg [7:0] imr_register;

  always @(posedge rst) begin
    if (rst) begin
      imr_register <= 8'b11111111;
    end else begin
      imr_register <= mask_vector & ~active_interrupts;
    end
  end

  assign imr_output = imr_register;

endmodule
