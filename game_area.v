module game_area(
    input wire clk,                    // System clock
    input wire rst_n,                  // Active low reset
    input wire [3:0] current_x,        // Current piece X position
    input wire [4:0] current_y,        // Current piece Y position
    input wire [2:0] current_piece,    // Current piece type
    input wire [1:0] current_rotation, // Current piece rotation
    input wire place_piece,            // Signal to place the current piece
    output reg collision,              // Collision detection output
    output reg [199:0] board_state    // Game board state (20 rows x 10 columns flattened)
);

// Game board parameters
parameter BOARD_WIDTH = 10;
parameter BOARD_HEIGHT = 20;

// Internal game board state
reg [BOARD_WIDTH-1:0] board [BOARD_HEIGHT-1:0];

// Internal registers for loops and temporary storage
reg [3:0] block_check_x;
reg [4:0] block_check_y;
reg [3:0] check_x;
reg [4:0] check_y;
reg collision_found;
reg [4:0] write_pos;
reg [4:0] read_pos;
reg [BOARD_HEIGHT-1:0] full_lines;
integer i;

// Convert 2D board to flattened output
always @* begin
    for (i = 0; i < BOARD_HEIGHT; i = i + 1) begin
        board_state[i*BOARD_WIDTH +: BOARD_WIDTH] = board[i];
    end
end

// Tetromino instance for collision detection
wire block_active;
tetromino tetromino_inst (
    .piece_type(current_piece),
    .rotation(current_rotation),
    .block_x(block_check_x),
    .block_y(block_check_y),
    .block_active(block_active)
);

// Collision detection logic
always @* begin
    collision = 1'b0;
    collision_found = 1'b0;
    
    for (check_y = 0; check_y < 4; check_y = check_y + 1) begin
        for (check_x = 0; check_x < 4; check_x = check_x + 1) begin
            block_check_x = check_x;
            block_check_y = check_y;
            
            if (block_active) begin
                if (current_x + check_x >= BOARD_WIDTH ||
                    current_y + check_y >= BOARD_HEIGHT ||
                    (current_y + check_y < BOARD_HEIGHT &&
                     board[current_y + check_y][current_x + check_x])) begin
                    collision_found = 1'b1;
                end
            end
        end
    end
    
    collision = collision_found;
end

// Place piece on the board and handle line clearing
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // Clear the board
        for (i = 0; i < BOARD_HEIGHT; i = i + 1) begin
            board[i] <= {BOARD_WIDTH{1'b0}};
        end
    end
    else if (place_piece) begin
        // Place the current piece on the board
        for (i = 0; i < 4; i = i + 1) begin
            block_check_x = 0;
            block_check_y = i[4:0];
            
            if (block_active && current_x + 0 < BOARD_WIDTH && current_y + i < BOARD_HEIGHT)
                board[current_y + i][current_x + 0] <= 1'b1;
                
            block_check_x = 1;
            if (block_active && current_x + 1 < BOARD_WIDTH && current_y + i < BOARD_HEIGHT)
                board[current_y + i][current_x + 1] <= 1'b1;
                
            block_check_x = 2;
            if (block_active && current_x + 2 < BOARD_WIDTH && current_y + i < BOARD_HEIGHT)
                board[current_y + i][current_x + 2] <= 1'b1;
                
            block_check_x = 3;
            if (block_active && current_x + 3 < BOARD_WIDTH && current_y + i < BOARD_HEIGHT)
                board[current_y + i][current_x + 3] <= 1'b1;
        end
        
        // Check and clear completed lines
        // First pass: identify full lines
        for (i = 0; i < BOARD_HEIGHT; i = i + 1) begin
            full_lines[i] = &board[i];
        end
        
        // Second pass: move lines down
        write_pos = BOARD_HEIGHT - 1;
        for (read_pos = BOARD_HEIGHT - 1; read_pos > 0; read_pos = read_pos - 1) begin
            if (!full_lines[read_pos]) begin
                board[write_pos] <= board[read_pos];
                write_pos = write_pos - 1;
            end
        end
        
        // Third pass: clear top lines
        for (i = 0; i <= write_pos; i = i + 1) begin
            board[i] <= {BOARD_WIDTH{1'b0}};
        end
    end
end

endmodule 