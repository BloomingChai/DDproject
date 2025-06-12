`timescale 1ns/1ps

module tetris_tb();

// Test signals
reg clk;
reg rst_n;
reg ps2_clk;
reg ps2_data;
wire [3:0] vga_red;
wire [3:0] vga_green;
wire [3:0] vga_blue;
wire vga_hsync;
wire vga_vsync;
wire [7:0] led;
wire [7:0] seg_data;
wire [7:0] seg_sel;

// Internal test signals
reg [7:0] test_keycode;
reg test_key_valid;
integer i;

// Instantiate the tetris_top module
tetris_top tetris_inst (
    .clk(clk),
    .rst_n(rst_n),
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),
    .vga_red(vga_red),
    .vga_green(vga_green),
    .vga_blue(vga_blue),
    .vga_hsync(vga_hsync),
    .vga_vsync(vga_vsync),
    .led(led),
    .seg_data(seg_data),
    .seg_sel(seg_sel)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz clock
end

// Test stimulus
initial begin
    // Initialize signals
    rst_n = 1;
    ps2_clk = 0;
    ps2_data = 0;
    test_keycode = 8'h00;
    test_key_valid = 0;

    // Reset sequence
    #100 rst_n = 0;
    #100 rst_n = 1;

    // Wait for initialization
    #1000;

    // Test Case 1: Basic Movement
    $display("Test Case 1: Testing Basic Movement");
    test_movement();

    // Test Case 2: Piece Rotation
    $display("Test Case 2: Testing Piece Rotation");
    test_rotation();

    // Test Case 3: Line Clearing
    $display("Test Case 3: Testing Line Clearing");
    test_line_clear();

    // Test Case 4: Game Over Detection
    $display("Test Case 4: Testing Game Over");
    test_game_over();

    // End simulation
    #1000;
    $display("All tests completed");
    $finish;
end

// Task to simulate keyboard input
task send_key;
    input [7:0] key;
    begin
        @(posedge clk);
        test_keycode = key;
        test_key_valid = 1;
        @(posedge clk);
        test_key_valid = 0;
        #1000; // Wait for movement to complete
    end
endtask

// Task to test basic movement
task test_movement;
    begin
        // Test left movement
        $display("Testing left movement");
        repeat(2) begin
            send_key(8'h6B); // LEFT key
        end

        // Test right movement
        $display("Testing right movement");
        repeat(2) begin
            send_key(8'h74); // RIGHT key
        end

        // Test down movement
        $display("Testing down movement");
        repeat(2) begin
            send_key(8'h72); // DOWN key
        end

        // Test hard drop
        $display("Testing hard drop");
        send_key(8'h29); // SPACE key
    end
endtask

// Task to test piece rotation
task test_rotation;
    begin
        $display("Testing piece rotation");
        repeat(4) begin
            send_key(8'h75); // UP key for rotation
            #2000; // Wait between rotations
        end
    end
endtask

// Task to test line clearing
task test_line_clear;
    begin
        $display("Setting up line clear test");
        // Fill up lines by dropping pieces
        repeat(10) begin
            send_key(8'h29); // SPACE for hard drop
            #5000; // Wait between drops
        end
        
        // Check if lines were cleared
        if (tetris_inst.game_ctrl.score > 0)
            $display("Line clear test passed: Score increased");
        else
            $display("Line clear test failed: No lines cleared");
    end
endtask

// Task to test game over condition
task test_game_over;
    begin
        $display("Testing game over condition");
        // Fill board to trigger game over
        repeat(20) begin
            send_key(8'h29); // SPACE for hard drop
            #2000;
        end
        
        if (tetris_inst.game_ctrl.game_over)
            $display("Game over test passed");
        else
            $display("Game over test failed");
    end
endtask

// Monitor game state changes
always @(posedge clk) begin
    if (tetris_inst.game_ctrl.state == 2'b11) // GAME_OVER state
        $display("Game Over detected at time %t", $time);
    
    if (tetris_inst.game_ctrl.place_piece_out)
        $display("Piece placed at time %t", $time);
        
    if (tetris_inst.game_ctrl.score > 0)
        $display("Score updated to %d at time %t", tetris_inst.game_ctrl.score, $time);
end

// Monitor collisions
always @(posedge clk) begin
    if (tetris_inst.game_area_inst.collision)
        $display("Collision detected at time %t", $time);
end

// Generate VCD file for waveform viewing
initial begin
    $dumpfile("tetris_sim.vcd");
    $dumpvars(0, tetris_tb);
end

endmodule 