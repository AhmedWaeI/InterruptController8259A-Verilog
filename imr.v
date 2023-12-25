module IMRModule (
  input wire [7:0] mask_vector,//OCW1 data.
  output wire [7:0] IMR_output
);

  reg [7:0] imr_register;

  always @* 
  begin
    imr_register = mask_vector
  end

  assign IMR_output = imr_register;

endmodule
/*we can add modes as special mask */
