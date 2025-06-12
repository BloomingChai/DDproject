# 时钟信号约束
create_clock -period 10.000 -name clk_100mhz [get_ports clk]
set_property PACKAGE_PIN AC18 [get_ports clk]
set_property IOSTANDARD LVCMOS18 [get_ports clk]

# 复位信号约束
set_property PACKAGE_PIN W13 [get_ports rst_n]
set_property IOSTANDARD LVCMOS18 [get_ports rst_n]

# VGA 红色信号端口约束（vga_red）
set_property PACKAGE_PIN N21 [get_ports vga_red[0]]
set_property PACKAGE_PIN N22 [get_ports vga_red[1]]
set_property PACKAGE_PIN R21 [get_ports vga_red[2]]
set_property PACKAGE_PIN P21 [get_ports vga_red[3]]
set_property IOSTANDARD LVCMOS33 [get_ports vga_red[*]]

# VGA 绿色信号端口约束（vga_green）
set_property PACKAGE_PIN R22 [get_ports vga_green[0]]
set_property PACKAGE_PIN R23 [get_ports vga_green[1]]
set_property PACKAGE_PIN T24 [get_ports vga_green[2]]
set_property PACKAGE_PIN T25 [get_ports vga_green[3]]
set_property IOSTANDARD LVCMOS33 [get_ports vga_green[*]]

# VGA 蓝色信号端口约束（vga_blue）
set_property PACKAGE_PIN T20 [get_ports vga_blue[0]]
set_property PACKAGE_PIN R20 [get_ports vga_blue[1]]
set_property PACKAGE_PIN T22 [get_ports vga_blue[2]]
set_property PACKAGE_PIN T23 [get_ports vga_blue[3]]
set_property IOSTANDARD LVCMOS33 [get_ports vga_blue[*]]

# VGA 同步信号约束
set_property PACKAGE_PIN M22 [get_ports vga_hsync]
set_property PACKAGE_PIN M21 [get_ports vga_vsync]
set_property IOSTANDARD LVCMOS33 [get_ports vga_hsync]
set_property IOSTANDARD LVCMOS33 [get_ports vga_vsync]

# LED 灯信号约束
set_property PACKAGE_PIN AF24 [get_ports led[0]]
set_property PACKAGE_PIN AE21 [get_ports led[1]]
set_property PACKAGE_PIN Y22  [get_ports led[2]]
set_property PACKAGE_PIN Y23  [get_ports led[3]]
set_property PACKAGE_PIN AA23 [get_ports led[4]]
set_property PACKAGE_PIN Y25  [get_ports led[5]]
set_property PACKAGE_PIN AB26 [get_ports led[6]]
set_property PACKAGE_PIN W23  [get_ports led[7]]
set_property IOSTANDARD LVCMOS33 [get_ports led[*]]

# 数码管段选信号约束（seg_data）
set_property PACKAGE_PIN AB22 [get_ports seg_data[0]]
set_property PACKAGE_PIN AD24 [get_ports seg_data[1]]
set_property PACKAGE_PIN AD23 [get_ports seg_data[2]]
set_property PACKAGE_PIN Y21  [get_ports seg_data[3]]
set_property PACKAGE_PIN W20  [get_ports seg_data[4]]
set_property PACKAGE_PIN AC24 [get_ports seg_data[5]]
set_property PACKAGE_PIN AC23 [get_ports seg_data[6]]
set_property PACKAGE_PIN AA22 [get_ports seg_data[7]]
set_property IOSTANDARD LVCMOS33 [get_ports seg_data[*]]

# 数码管位选信号约束（seg_sel）
set_property PACKAGE_PIN AD21 [get_ports seg_sel[0]]
set_property PACKAGE_PIN AC21 [get_ports seg_sel[1]]
set_property PACKAGE_PIN AB21 [get_ports seg_sel[2]]
set_property PACKAGE_PIN AC22 [get_ports seg_sel[3]]
set_property IOSTANDARD LVCMOS33 [get_ports seg_sel[*]]

# PS/2 接口约束
set_property PACKAGE_PIN N18 [get_ports ps2_clk]
set_property PACKAGE_PIN M19 [get_ports ps2_data]
set_property IOSTANDARD LVCMOS33 [get_ports ps2_clk]
set_property IOSTANDARD LVCMOS33 [get_ports ps2_data]
# set_property PULLUP true [get_ports ps2_clk]
# set_property PULLUP true [get_ports ps2_data]
