module tetromino(
    input wire [2:0] piece_type,     // Type of tetromino (0-6)
    input wire [1:0] rotation,       // Current rotation (0-3)
    input wire [3:0] block_x,        // X position to check
    input wire [4:0] block_y,        // Y position to check
    output wire block_active         // Whether the block is active at the given position
);

// Piece definitions (4x4 grid for each rotation)
reg [15:0] piece_I [0:3];
reg [15:0] piece_J [0:3];
reg [15:0] piece_L [0:3];
reg [15:0] piece_O [0:3];
reg [15:0] piece_S [0:3];
reg [15:0] piece_T [0:3];
reg [15:0] piece_Z [0:3];

// Initialize piece shapes
initial begin
    // I piece
    piece_I[0] = 16'b0000111100000000;
    piece_I[1] = 16'b0010001000100010;
    piece_I[2] = 16'b0000000011110000;
    piece_I[3] = 16'b0100010001000100;

    // J piece
    piece_J[0] = 16'b1000111000000000;
    piece_J[1] = 16'b0110001000100000;
    piece_J[2] = 16'b0000111000010000;
    piece_J[3] = 16'b0100010001100000;

    // L piece
    piece_L[0] = 16'b0010111000000000;
    piece_L[1] = 16'b0100010001100000;
    piece_L[2] = 16'b0000111010000000;
    piece_L[3] = 16'b1100010001000000;

    // O piece
    piece_O[0] = 16'b0110011000000000;
    piece_O[1] = 16'b0110011000000000;
    piece_O[2] = 16'b0110011000000000;
    piece_O[3] = 16'b0110011000000000;

    // S piece
    piece_S[0] = 16'b0110110000000000;
    piece_S[1] = 16'b0100011000100000;
    piece_S[2] = 16'b0000011011000000;
    piece_S[3] = 16'b1000110001000000;

    // T piece
    piece_T[0] = 16'b0100111000000000;
    piece_T[1] = 16'b0100011001000000;
    piece_T[2] = 16'b0000111001000000;
    piece_T[3] = 16'b0100110001000000;

    // Z piece
    piece_Z[0] = 16'b1100011000000000;
    piece_Z[1] = 16'b0010011001000000;
    piece_Z[2] = 16'b0000110001100000;
    piece_Z[3] = 16'b0100110010000000;
end

// Calculate block position in the 4x4 grid
wire [3:0] local_x = block_x[1:0];
wire [3:0] local_y = block_y[1:0];
wire [3:0] grid_pos = local_y * 4 + local_x;

// Select the appropriate piece shape based on type and rotation
reg [15:0] current_piece;
always @(*) begin
    case (piece_type)
        3'd0: current_piece = piece_I[rotation];
        3'd1: current_piece = piece_J[rotation];
        3'd2: current_piece = piece_L[rotation];
        3'd3: current_piece = piece_O[rotation];
        3'd4: current_piece = piece_S[rotation];
        3'd5: current_piece = piece_T[rotation];
        3'd6: current_piece = piece_Z[rotation];
        default: current_piece = 16'h0000;
    endcase
end

// Check if the block is active at the given position
assign block_active = current_piece[15 - grid_pos];

endmodule 