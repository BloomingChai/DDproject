module tetris_top(
    input wire clk,                  // 100MHz clock
    input wire rst_n,                // Active low reset
    input wire ps2_clk,              // PS/2 clock
    input wire ps2_data,             // PS/2 data
    output wire [3:0] vga_red,       // VGA red channel
    output wire [3:0] vga_green,     // VGA green channel
    output wire [3:0] vga_blue,      // VGA blue channel
    output wire vga_hsync,           // VGA horizontal sync
    output wire vga_vsync,           // VGA vertical sync
    output reg [7:0] led,            // LED display
    output reg [7:0] seg_data,       // Seven segment display data
    output reg [3:0] seg_sel         // Seven segment display select (4-bit)
);

// Internal signals
wire clk_25MHz;        // 25MHz pixel clock
wire [7:0] keycode;    // PS/2 keyboard code
wire key_valid;        // PS/2 keyboard data valid
wire [9:0] pixel_x;    // Current pixel X position
wire [9:0] pixel_y;    // Current pixel Y position
wire video_on;         // Video display enable
wire [11:0] pixel_rgb; // RGB value for current pixel
wire [15:0] score;     // Game score
wire game_over;        // Game over flag
wire [2:0] next_piece; // Next piece type

// Game state signals
wire [199:0] board_state;  // Flattened game board state (20 rows x 10 columns)
wire [3:0] current_x;      // Current piece X position
wire [4:0] current_y;      // Current piece Y position
wire [2:0] current_piece;  // Current piece type
wire [1:0] current_rotation; // Current piece rotation
wire place_piece;          // Signal to place the current piece
wire collision;            // Collision detection signal

// Clock divider instantiation
clk_div clk_div_inst (
    .clk_100MHz(clk),
    .rst_n(rst_n),
    .clk_25MHz(clk_25MHz)
);

// VGA controller instantiation
vga_controller vga_ctrl (
    .clk_25MHz(clk_25MHz),
    .rst_n(rst_n),
    .hsync(vga_hsync),
    .vsync(vga_vsync),
    .video_on(video_on),
    .pixel_x(pixel_x),
    .pixel_y(pixel_y)
);

// PS/2 keyboard controller instantiation
ps2_keyboard ps2_ctrl (
    .clk(clk),
    .rst_n(rst_n),
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),
    .keycode(keycode),
    .key_valid(key_valid)
);

// Game area instantiation
game_area game_area_inst (
    .clk(clk),
    .rst_n(rst_n),
    .current_x(current_x),
    .current_y(current_y),
    .current_piece(current_piece),
    .current_rotation(current_rotation),
    .place_piece(place_piece),
    .collision(collision),
    .board_state(board_state)
);

// Game controller instantiation
game_control game_ctrl (
    .clk(clk),
    .rst_n(rst_n),
    .keycode(keycode),
    .key_valid(key_valid),
    .collision(collision),
    .score(score),
    .game_over(game_over),
    .next_piece(next_piece),
    .current_x_out(current_x),
    .current_y_out(current_y),
    .current_piece_out(current_piece),
    .current_rotation_out(current_rotation),
    .place_piece_out(place_piece)
);

// Display controller instantiation
display_control display_ctrl (
    .clk_25MHz(clk_25MHz),
    .rst_n(rst_n),
    .pixel_x(pixel_x),
    .pixel_y(pixel_y),
    .video_on(video_on),
    .score(score),
    .game_over(game_over),
    .next_piece(next_piece),
    .board_row(board_state),
    .current_x(current_x),
    .current_y(current_y),
    .current_piece(current_piece),
    .current_rotation(current_rotation),
    .pixel_rgb(pixel_rgb)
);

// Output RGB values when video_on is active
assign vga_red = video_on ? pixel_rgb[11:8] : 4'b0000;
assign vga_green = video_on ? pixel_rgb[7:4] : 4'b0000;
assign vga_blue = video_on ? pixel_rgb[3:0] : 4'b0000;

// Seven segment display decoder
function [7:0] hex_to_7seg;
    input [3:0] hex;
    begin
        case(hex)
            4'h0: hex_to_7seg = 8'b11000000; // 0
            4'h1: hex_to_7seg = 8'b11111001; // 1
            4'h2: hex_to_7seg = 8'b10100100; // 2
            4'h3: hex_to_7seg = 8'b10110000; // 3
            4'h4: hex_to_7seg = 8'b10011001; // 4
            4'h5: hex_to_7seg = 8'b10010010; // 5
            4'h6: hex_to_7seg = 8'b10000010; // 6
            4'h7: hex_to_7seg = 8'b11111000; // 7
            4'h8: hex_to_7seg = 8'b10000000; // 8
            4'h9: hex_to_7seg = 8'b10010000; // 9
            4'ha: hex_to_7seg = 8'b10001000; // A
            4'hb: hex_to_7seg = 8'b10000011; // b
            4'hc: hex_to_7seg = 8'b11000110; // C
            4'hd: hex_to_7seg = 8'b10100001; // d
            4'he: hex_to_7seg = 8'b10000110; // E
            4'hf: hex_to_7seg = 8'b10001110; // F
            default: hex_to_7seg = 8'b11111111; // All off
        endcase
    end
endfunction

// LED display logic - show game status
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        led <= 8'h00;
    else begin
        // LED[7]: Game over indicator
        // LED[6:4]: Current piece type
        // LED[3:1]: Next piece type
        // LED[0]: Active game indicator
        led <= {game_over, current_piece, next_piece, ~game_over};
    end
end

// Seven segment display refresh counter
reg [17:0] refresh_counter;  // 减小计数器位宽，因为只需要4个数码管
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        refresh_counter <= 18'd0;
    else
        refresh_counter <= refresh_counter + 1;
end

// Seven segment display control - show score (4 digits)
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        seg_sel <= 4'b1111;
        seg_data <= 8'hff;
    end
    else begin
        case (refresh_counter[17:16])  // 使用2位选择4个数码管
            2'b00: begin
                seg_sel <= 4'b1110;  // 选择最右边的数码管
                seg_data <= hex_to_7seg(score[3:0]);  // 个位
            end
            2'b01: begin
                seg_sel <= 4'b1101;  // 选择右数第二个数码管
                seg_data <= hex_to_7seg(score[7:4]);  // 十位
            end
            2'b10: begin
                seg_sel <= 4'b1011;  // 选择右数第三个数码管
                seg_data <= hex_to_7seg(score[11:8]); // 百位
            end
            2'b11: begin
                seg_sel <= 4'b0111;  // 选择最左边的数码管
                if (game_over)
                    seg_data <= 8'b10001100; // 显示"O"表示游戏结束
                else
                    seg_data <= hex_to_7seg(score[15:12]); // 千位
            end
        endcase
    end
end

endmodule 