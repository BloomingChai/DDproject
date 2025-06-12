module display_control(
    input wire clk_25MHz,           // 25MHz pixel clock
    input wire rst_n,               // Active low reset
    input wire [9:0] pixel_x,       // Current pixel X position
    input wire [9:0] pixel_y,       // Current pixel Y position
    input wire video_on,            // Video display enable
    input wire [15:0] score,        // Game score
    input wire game_over,           // Game over flag
    input wire [2:0] next_piece,    // Next piece type
    input wire [199:0] board_row,   // Game board state (20 rows x 10 columns flattened)
    input wire [3:0] current_x,     // Current piece X position
    input wire [4:0] current_y,     // Current piece Y position
    input wire [2:0] current_piece, // Current piece type
    input wire [1:0] current_rotation, // Current piece rotation
    output reg [11:0] pixel_rgb     // RGB value for current pixel
);

// Display parameters
parameter BOARD_X = 240;  // Board position X
parameter BOARD_Y = 40;   // Board position Y
parameter BLOCK_SIZE = 20; // Size of each block in pixels
parameter BOARD_WIDTH = 10;
parameter BOARD_HEIGHT = 20;

// Color definitions
parameter COLOR_BLACK = 12'h000;
parameter COLOR_WHITE = 12'hFFF;
parameter COLOR_RED = 12'hF00;
parameter COLOR_GREEN = 12'h0F0;
parameter COLOR_BLUE = 12'h00F;
parameter COLOR_CYAN = 12'h0FF;
parameter COLOR_MAGENTA = 12'hF0F;
parameter COLOR_YELLOW = 12'hFF0;

// Internal signals
wire [9:0] board_x;
wire [9:0] board_y;
wire [9:0] block_x;
wire [9:0] block_y;
reg [11:0] piece_color;
wire in_board_area;
wire in_next_piece_area;
wire in_score_area;

// Convert board_row input to 2D array for easier access
reg [BOARD_WIDTH-1:0] board [BOARD_HEIGHT-1:0];
integer i;

always @* begin
    for (i = 0; i < BOARD_HEIGHT; i = i + 1) begin
        board[i] = board_row[i*BOARD_WIDTH +: BOARD_WIDTH];
    end
end

// Calculate relative coordinates
assign board_x = pixel_x - BOARD_X;
assign board_y = pixel_y - BOARD_Y;
assign block_x = board_x / BLOCK_SIZE;
assign block_y = board_y / BLOCK_SIZE;

// Define display areas
assign in_board_area = (pixel_x >= BOARD_X) && 
                      (pixel_x < BOARD_X + BOARD_WIDTH * BLOCK_SIZE) &&
                      (pixel_y >= BOARD_Y) && 
                      (pixel_y < BOARD_Y + BOARD_HEIGHT * BLOCK_SIZE);

assign in_next_piece_area = (pixel_x >= BOARD_X + BOARD_WIDTH * BLOCK_SIZE + 20) &&
                           (pixel_x < BOARD_X + BOARD_WIDTH * BLOCK_SIZE + 100) &&
                           (pixel_y >= BOARD_Y) &&
                           (pixel_y < BOARD_Y + 80);

assign in_score_area = (pixel_x >= BOARD_X + BOARD_WIDTH * BLOCK_SIZE + 20) &&
                      (pixel_x < BOARD_X + BOARD_WIDTH * BLOCK_SIZE + 100) &&
                      (pixel_y >= BOARD_Y + 100) &&
                      (pixel_y < BOARD_Y + 140);

// Piece color selection based on piece type
always @* begin
    case(current_piece)
        3'd0: piece_color = COLOR_CYAN;    // I piece
        3'd1: piece_color = COLOR_BLUE;    // J piece
        3'd2: piece_color = COLOR_MAGENTA; // L piece
        3'd3: piece_color = COLOR_YELLOW;  // O piece
        3'd4: piece_color = COLOR_GREEN;   // S piece
        3'd5: piece_color = COLOR_RED;     // T piece
        3'd6: piece_color = COLOR_WHITE;   // Z piece
        default: piece_color = COLOR_WHITE;
    endcase
end

// Main display logic
always @* begin
    if (!video_on)
        pixel_rgb = COLOR_BLACK;
    else if (in_board_area) begin
        // Check if current pixel is within a block
        if (board[block_y][block_x])
            pixel_rgb = piece_color;
        else if ((block_x == current_x || block_x == current_x + 1) &&
                 (block_y == current_y || block_y == current_y + 1))
            pixel_rgb = piece_color;
        else
            pixel_rgb = COLOR_BLACK;
    end
    else if (in_next_piece_area) begin
        // Display next piece preview
        pixel_rgb = COLOR_BLUE;
    end
    else if (in_score_area) begin
        // Display score
        pixel_rgb = COLOR_GREEN;
    end
    else
        pixel_rgb = COLOR_BLACK;
end

endmodule 