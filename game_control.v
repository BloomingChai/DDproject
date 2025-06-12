module game_control(
    input wire clk,              // System clock
    input wire rst_n,            // Active low reset
    input wire [7:0] keycode,    // PS/2 keyboard code
    input wire key_valid,        // PS/2 keyboard data valid
    input wire collision,        // Collision detection input
    output reg [15:0] score,     // Game score
    output reg game_over,        // Game over flag
    output reg [2:0] next_piece, // Next piece type
    output reg [3:0] current_x_out,    // Current piece X position
    output reg [4:0] current_y_out,    // Current piece Y position
    output reg [2:0] current_piece_out, // Current piece type
    output reg [1:0] current_rotation_out, // Current piece rotation
    output reg place_piece_out   // Signal to place the current piece
);

// Game parameters
parameter BOARD_WIDTH = 10;
parameter BOARD_HEIGHT = 20;
parameter MOVE_INTERVAL = 25000000; // Movement speed (0.25s at 100MHz)

// Piece types
parameter I_PIECE = 3'd0;
parameter J_PIECE = 3'd1;
parameter L_PIECE = 3'd2;
parameter O_PIECE = 3'd3;
parameter S_PIECE = 3'd4;
parameter T_PIECE = 3'd5;
parameter Z_PIECE = 3'd6;

// PS/2 keycodes
parameter KEY_LEFT = 8'h6B;    // Left arrow
parameter KEY_RIGHT = 8'h74;   // Right arrow
parameter KEY_DOWN = 8'h72;    // Down arrow
parameter KEY_UP = 8'h75;      // Up arrow (rotate)
parameter KEY_SPACE = 8'h29;   // Space (drop)

// Game states
parameter INIT = 2'b00;
parameter PLAY = 2'b01;
parameter LINE_CLEAR = 2'b10;
parameter GAME_OVER = 2'b11;

// Internal registers
reg [1:0] state;
reg [3:0] current_x;
reg [4:0] current_y;
reg [2:0] current_piece;
reg [1:0] current_rotation;
reg [24:0] move_counter;
reg [7:0] lfsr;
reg [3:0] lines_cleared;
reg [3:0] drop_x;
reg [4:0] drop_y;
reg dropping;

// Game state control
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= INIT;
        score <= 16'd0;
        game_over <= 1'b0;
        current_x <= BOARD_WIDTH/2 - 1;
        current_y <= 0;
        current_piece <= 3'd0;
        current_rotation <= 2'd0;
        move_counter <= 25'd0;
        lfsr <= 8'b10101010;
        next_piece <= 3'd0;
        place_piece_out <= 1'b0;
        lines_cleared <= 4'd0;
        dropping <= 1'b0;
        drop_x <= 0;
        drop_y <= 0;
    end
    else begin
        // Update output signals
        current_x_out <= current_x;
        current_y_out <= current_y;
        current_piece_out <= current_piece;
        current_rotation_out <= current_rotation;
        place_piece_out <= 1'b0;

        case (state)
            INIT: begin
                current_piece <= next_piece;
                next_piece <= lfsr[2:0];
                lfsr <= {lfsr[6:0], lfsr[7] ^ lfsr[5]};
                current_x <= BOARD_WIDTH/2 - 1;
                current_y <= 0;
                current_rotation <= 2'd0;
                dropping <= 1'b0;
                
                if (collision) begin
                    state <= GAME_OVER;
                    game_over <= 1'b1;
                end
                else begin
                    state <= PLAY;
                end
            end

            PLAY: begin
                if (key_valid && !dropping) begin
                    case (keycode)
                        KEY_LEFT: begin
                            if (!collision) current_x <= current_x - 1;
                        end
                        KEY_RIGHT: begin
                            if (!collision) current_x <= current_x + 1;
                        end
                        KEY_DOWN: begin
                            if (!collision) current_y <= current_y + 1;
                        end
                        KEY_UP: begin
                            if (!collision) current_rotation <= current_rotation + 1;
                        end
                        KEY_SPACE: begin
                            dropping <= 1'b1;
                            drop_x <= current_x;
                            drop_y <= current_y;
                        end
                    endcase
                end

                if (dropping) begin
                    if (!collision) begin
                        current_y <= current_y + 1;
                    end
                    else begin
                        dropping <= 1'b0;
                        place_piece_out <= 1'b1;
                        state <= LINE_CLEAR;
                    end
                end
                else begin
                    move_counter <= move_counter + 1;
                    if (move_counter >= MOVE_INTERVAL) begin
                        move_counter <= 0;
                        if (!collision)
                            current_y <= current_y + 1;
                        else begin
                            place_piece_out <= 1'b1;
                            state <= LINE_CLEAR;
                        end
                    end
                end
            end

            LINE_CLEAR: begin
                if (lines_cleared > 0) begin
                    case (lines_cleared)
                        4'd1: score <= score + 16'd100;
                        4'd2: score <= score + 16'd300;
                        4'd3: score <= score + 16'd500;
                        4'd4: score <= score + 16'd800;
                        default: score <= score;
                    endcase
                end
                lines_cleared <= 0;
                state <= INIT;
            end

            GAME_OVER: begin
                // Wait for reset
            end
        endcase
    end
end

endmodule 