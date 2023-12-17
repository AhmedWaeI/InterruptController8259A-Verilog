module PriorityResolver (
    input wire clk,
    input wire reset,
    input wire [7:0] irr,
    input wire [7:0] imr,
    input wire [3:0] ocw,
    input wire inta,
    input wire eoi, // Wire input
    output reg [7:0] isr, // Reg output
    output wire [2:0] highest_priority
);

    // Internal registers
    reg [7:0] masked_irr;
    reg [7:0] masked_priority;
    reg [2:0] last_serviced_priority = 0; // Initialize to zero
    reg rotation_enabled;
    reg eoi_received; // Reg for processing eoi
	reg [7:0] mask;

    // Combinational logic
    assign highest_priority = $clog2(masked_priority);

    // Always @* block for state updates
    always @* begin
        masked_irr = irr & ~imr & ~{3'b0, ocw[2:0]};
        // Option 1: Using a temporary variable (preferred for clarity)
      
        mask = {8'b1111_1111} << (8 - masked_irr);
        masked_priority = masked_irr & mask;
        rotation_enabled = ocw[2] == 1'b1;
        eoi_received = eoi ? 1'b1 : 1'b0;

        // Fully Nested Mode logic
        if (ocw[2:0] == 3'b000) begin
            if (masked_priority != 8'b0000_0000 && highest_priority >= last_serviced_priority) begin
                last_serviced_priority = highest_priority;
            end
        end else begin
            // Rotation Mode logic
            if (rotation_enabled) begin
                if (ocw[1:0] == 2'b01 && eoi_received) begin
                    last_serviced_priority <= (last_serviced_priority + 1) % 8; // Adjusted assignment to use '<='
                end else if (ocw[1:0] == 2'b00) begin
                    last_serviced_priority <= (last_serviced_priority + 1) % 8; // Adjusted assignment to use '<='
                end
            end
        end

        // ISR manipulation based on EOI and service completion
        if (eoi && ocw[2:0] == 3'b000) begin
            // Clear the serviced bit upon EOI in fully nested mode
            isr[highest_priority] <= 1'b0; // Changed '=' to '<=' for sequential logic
        end else if (masked_priority[last_serviced_priority] == 1'b0 && ocw[2:0] == 3'b000) begin
            // Clear the ISR bit if the last serviced interrupt is no longer pending in fully nested mode
            isr[last_serviced_priority] <= 1'b0; // Changed '=' to '<=' for sequential logic
        end

        // Set highest priority bit in ISR during INTA (fully nested mode)
        if (ocw[2:0] == 3'b000 && masked_priority != 8'b0000_0000 && inta) begin
            isr[highest_priority] <= 1'b1; // Changed '=' to '<=' for sequential logic
        end
    end

    // Positive edge triggered logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            last_serviced_priority <= 0;
            eoi_received <= 0;
            isr <= 8'b0; // Initialize ISR to all zeros
        end else begin
            // Strobe highest priority bit into ISR (fully nested mode)
            if (ocw[2:0] == 3'b000 && masked_priority != 8'b0000_0000 && inta) begin
                isr[highest_priority] <= 1'b1;
            end
        end
    end

endmodule
