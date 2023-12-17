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

    reg [2:0] priority_wire;
	
    always @* begin
        case(masked_priority)
            8'b00000001: priority_wire = 3'b000;
            8'b00000010: priority_wire = 3'b001;
            8'b00000100: priority_wire = 3'b010;
            8'b00001000: priority_wire = 3'b011;
            8'b00010000: priority_wire = 3'b100;
            8'b00100000: priority_wire = 3'b101;
            8'b01000000: priority_wire = 3'b110;
            8'b10000000: priority_wire = 3'b111;
            default: priority_wire = 3'b111; // Set a default value
        endcase
    end

    assign highest_priority = priority_wire;

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
              begin
                isr <= 8'b0;
                isr[highest_priority] <= 1'b1;
              end
        end
    end

endmodule
