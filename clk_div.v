module clk_div(
    input wire clk_100MHz,    // 100MHz input clock
    input wire rst_n,         // Active low reset
    output reg clk_25MHz      // 25MHz output clock
);

// Counter for clock division
reg [1:0] count;

// Clock division logic
always @(posedge clk_100MHz or negedge rst_n) begin
    if (!rst_n) begin
        count <= 2'd0;
        clk_25MHz <= 1'b0;
    end
    else begin
        if (count == 2'd1) begin
            clk_25MHz <= ~clk_25MHz;
            count <= 2'd0;
        end
        else begin
            count <= count + 1'b1;
        end
    end
end

endmodule 