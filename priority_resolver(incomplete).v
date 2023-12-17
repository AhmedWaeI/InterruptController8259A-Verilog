module PriorityResolver (
    input wire [7:0] IRR,  // Interrupt Request Register
    input wire [7:0] IMR,  // Interrupt Mask Register
    input wire [3:0] OCW,  // Operation Control Words OCW2 (L2, L1, L0) and OCW3 (ESMM, SMM)
    output reg [7:0] ISR   // Interrupt Service Register
);

    reg [7:0] masked_IRR;      // Masked Interrupt Request Register
    reg [7:0] masked_priority; // Masked priority register
    reg highest_priority;

    // Register to store the last serviced priority for rotation
    reg [2:0] last_serviced_priority = 3'b000;

    reg eoi_issued; // Temporary variable to store OCW[3]

    always @* begin
        // Apply masking based on OCW1 and IMR
        masked_IRR = IRR & ~IMR & ~{3'b0, OCW[2:0]};

        // Logic to determine the highest priority bit in the masked IRR
        masked_priority = masked_IRR & (masked_IRR ^ (masked_IRR - 1));
        highest_priority = masked_priority != 8'b0000_0000 ? $clog2(masked_priority) : 0;

        // Fully Nested Mode
        if (OCW[2:0] == 3'b000) begin
            // Check if highest priority interrupt is acknowledged
            if (highest_priority != 0) begin
                // Strobing the highest priority into the ISR during INTA pulse or as required
                ISR[highest_priority] <= 1;

                // Mask lower priority interrupts until EOI (not implemented)
                ISR <= ISR & ((1 << highest_priority) - 1);

                // Store OCW[3] value in temporary variable
                eoi_issued = OCW[3];

                // Check if EOI is issued (for illustration purposes)
                if (eoi_issued == 1'b1) begin
                    // Clear ISR bit after EOI command (basic illustration)
                    ISR[highest_priority] <= 0;
                end
            end
        end else begin
            // Rotation Mode
            // Check if any interrupt is pending and needs rotation
            if (highest_priority != 0 && highest_priority != last_serviced_priority) begin
                last_serviced_priority <= highest_priority;
                ISR <= {ISR[highest_priority], ISR[7:1]};
            end
        end
    end
     
endmodule
