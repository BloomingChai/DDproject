module ps2_keyboard(
    input wire clk,           // System clock
    input wire rst_n,         // Active low reset
    input wire ps2_clk,       // PS/2 clock
    input wire ps2_data,      // PS/2 data
    output reg [7:0] keycode, // Output keycode
    output reg key_valid      // Keycode valid signal
);

// PS/2 protocol states
parameter IDLE = 2'b00;
parameter RECEIVE = 2'b01;
parameter CHECK_PARITY = 2'b10;
parameter COMPLETE = 2'b11;

// Internal registers
reg [1:0] state;
reg [3:0] count;
reg [10:0] shift_reg;
reg ps2_clk_sync1, ps2_clk_sync2;
wire ps2_clk_negedge;

// Synchronize PS/2 clock to prevent metastability
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ps2_clk_sync1 <= 1'b1;
        ps2_clk_sync2 <= 1'b1;
    end
    else begin
        ps2_clk_sync1 <= ps2_clk;
        ps2_clk_sync2 <= ps2_clk_sync1;
    end
end

// Detect PS/2 clock falling edge
assign ps2_clk_negedge = ps2_clk_sync2 & ~ps2_clk_sync1;

// PS/2 receiver state machine
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        count <= 4'd0;
        shift_reg <= 11'd0;
        keycode <= 8'd0;
        key_valid <= 1'b0;
    end
    else begin
        key_valid <= 1'b0; // Default state

        case (state)
            IDLE: begin
                if (ps2_clk_negedge && !ps2_data) begin // Start bit detected
                    state <= RECEIVE;
                    count <= 4'd0;
                    shift_reg <= 11'd0;
                end
            end

            RECEIVE: begin
                if (ps2_clk_negedge) begin
                    shift_reg <= {ps2_data, shift_reg[10:1]};
                    count <= count + 1'b1;
                    if (count == 4'd8)
                        state <= CHECK_PARITY;
                end
            end

            CHECK_PARITY: begin
                if (ps2_clk_negedge) begin
                    shift_reg <= {ps2_data, shift_reg[10:1]};
                    state <= COMPLETE;
                end
            end

            COMPLETE: begin
                if (ps2_clk_negedge) begin
                    if (ps2_data) begin // Stop bit
                        keycode <= shift_reg[8:1];
                        key_valid <= 1'b1;
                    end
                    state <= IDLE;
                end
            end

            default: state <= IDLE;
        endcase
    end
end

endmodule 