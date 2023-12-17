module PriorityResolver (
    input wire clk,
    input wire reset,
    input wire [7:0] irr,
    input wire [7:0] imr,
    input wire [3:0] ocw,
    input wire inta,
    input wire eoi,
    output reg [7:0] isr,
    output wire [2:0] highest_priority
);

    reg [7:0] masked_irr;
    reg [7:0] masked_priority;
    reg [2:0] last_serviced_priority;
    reg rotation_enabled;
    reg eoi_received;
    reg [2:0] automatic_priority;

    assign highest_priority = ($clog2(masked_priority + 1)) ? ($clog2(masked_priority + 1) - 1) : 3'd0;

    always @* begin
        masked_irr = irr & ~imr & ~{3'b0, ocw[2:0]};
        masked_priority = masked_irr;
        
        rotation_enabled = ocw[2];
        eoi_received = eoi;

        if (ocw == 3'b000) begin
            if (masked_priority != 8'b0 && inta)
                last_serviced_priority = highest_priority;
            
            if (eoi && masked_priority != 8'b0)
                isr[last_serviced_priority] <= 1'b0;
        end else begin
            if (rotation_enabled && eoi_received && ocw == 3'b001 && inta) begin
                automatic_priority <= (last_serviced_priority + 1) % 8;
                // Service the highest pending interrupt in rotation mode
                if (masked_priority[automatic_priority] && automatic_priority != last_serviced_priority) begin
                    last_serviced_priority <= automatic_priority;
                    isr[last_serviced_priority] <= 1'b1;
                end
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if (!reset) begin
            last_serviced_priority <= 0;
            isr <= 8'b0;
        end else begin
            if (ocw == 3'b000 && masked_priority != 8'b0)
                isr[highest_priority] <= 1'b1;
        end
    end

endmodule
