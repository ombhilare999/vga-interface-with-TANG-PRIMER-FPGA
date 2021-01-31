////////////////////////////////////////////////////////////////////////////////
//   Module Name: vga_test_pattern_top.v
//  Dependencies: 25 MHz Clock.
//          Info: Take input a clock and produces Hsync and Vsync Control Signals
//                with 3 bit depth video out.
////////////////////////////////////////////////////////////////////////////////

`include "vga_sync_pulse.v"
`include "vga_sync_porch.v"
`include "test_pattern_gen.v"
`include  "sync_count.v"

module vga_test_pattern_top
(
    //Main Clock
    input i_clk,

    //VGA
    output   o_VGA_hsync,
    output   o_VGA_vsync,
    output   o_VGA_red_0,
    output   o_VGA_red_1,
    output   o_VGA_red_2,
    output o_VGA_green_0,
    output o_VGA_green_1,
    output o_VGA_green_2,
    output  o_VGA_blue_0,
    output  o_VGA_blue_1,
    output  o_VGA_blue_2
);

    //Parameter Needed:
    parameter VIDEO_WIDTH =    3;
    parameter TOTAL_COLS  =  800;
    parameter TOTAL_ROWS  =  525;
    parameter ACTIVE_COLS =  640;
    parameter ACTIVE_ROWS =  480;  

    // Common VGA Signals
    wire w_hsync_vga, wire_vsync_vga;
    wire w_hsync_tp, w_vsync_tp;
    wire w_hsync_porch, w_vsync_porch;
    wire [VIDEO_WIDTH-1:0]   w_red_TP,   w_red_Porch;
    wire [VIDEO_WIDTH-1:0] w_green_TP, w_green_Porch;
    wire [VIDEO_WIDTH-1:0]  w_blue_TP,  w_blue_Porch;

    //////////////////////////////////////////////////////////////////////////////////////
    // Creating Instants of VGA modules
    //////////////////////////////////////////////////////////////////////////////////////

    vga_sync_pulse i1
    (
        .i_clk(i_clk),
        .o_hsync(w_hsync_vga),
        .o_vsync(w_vsync_vga),
        .o_col_count(),
        .o_row_count()
    );

    test_pattern_gen i2
    (
        .i_clk(i_clk),
        .i_pattern(),
        .i_hsync(w_hsync_vga),
        .i_vsync(w_vsync_vga),
        .o_hsync(w_hsync_tp),
        .o_vsync(w_vsync_tp),
        .o_red_video(w_red_TP),
        .o_green_video(w_green_TP),
        .o_blue_video(w_blue_TP)
    );

    vga_sync_porch i4
    (
        .i_clk(i_clk),
        .i_hsync(w_hsync_tp),
        .i_vsync(w_vsync_tp),
        .i_red_video(w_red_TP),
        .i_green_video(w_green_TP),
        .i_blue_video(w_blue_TP),
        .o_hsync(w_hsync_porch),
        .o_vsync(w_vsync_porch),
        .o_red_video(w_red_Porch),
        .o_green_video(w_green_Porch),
        .o_blue_video(w_blue_Porch)
    );

    assign   o_VGA_hsync = w_hsync_porch;
    assign   o_VGA_vsync = w_vsync_porch;

    assign   o_VGA_red_0 = w_red_Porch[0];
    assign   o_VGA_red_1 = w_red_Porch[1];
    assign   o_VGA_red_2 = w_red_Porch[2];

    assign o_VGA_green_0 = w_green_Porch[0];
    assign o_VGA_green_1 = w_green_Porch[1];
    assign o_VGA_green_2 = w_green_Porch[2];

    assign  o_VGA_blue_0 = w_blue_Porch[0];
    assign  o_VGA_blue_1 = w_blue_Porch[1];
    assign  o_VGA_blue_2 = w_blue_Porch[2]; 
endmodule