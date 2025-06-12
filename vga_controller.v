module vga_controller(
    input wire clk_25MHz,     // 25MHz pixel clock
    input wire rst_n,         // Active low reset
    output wire hsync,        // Horizontal sync
    output wire vsync,        // Vertical sync
    output wire video_on,     // Display area enable
    output wire [9:0] pixel_x, // Current pixel X position
    output wire [9:0] pixel_y  // Current pixel Y position
);

// VGA 640x480@60Hz timing parameters
parameter H_DISPLAY = 640;    // Horizontal display area
parameter H_FRONT = 16;       // Front porch
parameter H_SYNC = 96;        // Sync pulse
parameter H_BACK = 48;        // Back porch
parameter H_TOTAL = 800;      // Total horizontal pixels

parameter V_DISPLAY = 480;    // Vertical display area
parameter V_FRONT = 10;       // Front porch
parameter V_SYNC = 2;         // Sync pulse
parameter V_BACK = 33;        // Back porch
parameter V_TOTAL = 525;      // Total vertical lines

// Counters for horizontal and vertical timing
reg [9:0] h_count;
reg [9:0] v_count;

// Horizontal counter
always @(posedge clk_25MHz or negedge rst_n) begin
    if (!rst_n)
        h_count <= 10'd0;
    else if (h_count == H_TOTAL - 1)
        h_count <= 10'd0;
    else
        h_count <= h_count + 1'b1;
end

// Vertical counter
always @(posedge clk_25MHz or negedge rst_n) begin
    if (!rst_n)
        v_count <= 10'd0;
    else if (h_count == H_TOTAL - 1) begin
        if (v_count == V_TOTAL - 1)
            v_count <= 10'd0;
        else
            v_count <= v_count + 1'b1;
    end
end

// Generate sync signals and video_on
assign hsync = (h_count < H_SYNC) ? 1'b0 : 1'b1;
assign vsync = (v_count < V_SYNC) ? 1'b0 : 1'b1;
assign video_on = (h_count >= H_SYNC + H_BACK) && 
                 (h_count < H_SYNC + H_BACK + H_DISPLAY) &&
                 (v_count >= V_SYNC + V_BACK) && 
                 (v_count < V_SYNC + V_BACK + V_DISPLAY);

// Generate pixel coordinates
assign pixel_x = video_on ? (h_count - (H_SYNC + H_BACK)) : 10'd0;
assign pixel_y = video_on ? (v_count - (V_SYNC + V_BACK)) : 10'd0;

endmodule 