`timescale 1ns/1ns
`include "vga_test_pattern_top.v"

module testbench();

    reg clock;
    wire [2:0]i_pattern = 3'b010;

    wire   o_VGA_hsync;
    wire   o_VGA_vsync;
    wire   o_VGA_red_0;
    wire   o_VGA_red_1;
    wire   o_VGA_red_2;
    wire o_VGA_green_0;
    wire o_VGA_green_1;
    wire o_VGA_green_2;
    wire  o_VGA_blue_0;
    wire  o_VGA_blue_1;
    wire  o_VGA_blue_2;

vga_test_pattern_top i11
(
    //Main Clock
    .i_clk(clock),
    .i_pattern(i_pattern),
    //VGA
    .o_VGA_hsync(o_VGA_hsync),
    .o_VGA_vsync(o_VGA_vsync),
    .o_VGA_red_0(o_VGA_red_0),
    .o_VGA_red_1(o_VGA_red_1),
    .o_VGA_red_2(o_VGA_red_2),
    .o_VGA_green_0(o_VGA_green_0),
    .o_VGA_green_1(o_VGA_green_1),
    .o_VGA_green_2(o_VGA_green_2),
    .o_VGA_blue_0(o_VGA_blue_0),
    .o_VGA_blue_1(o_VGA_blue_1),
    .o_VGA_blue_2(o_VGA_blue_2)
);

initial
begin
    clock = 1'b0;
    forever #1 clock = ~clock;
end

initial
    $monitor($time, "clock = %b", clock);

initial
begin
    $dumpfile("a.vcd");
    $dumpvars(0, testbench);
end

initial
begin
    #5000 $finish;
end

endmodule
