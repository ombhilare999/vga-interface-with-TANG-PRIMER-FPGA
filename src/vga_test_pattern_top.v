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

	//Select Input for Pattern Display
	input sel0,
	input sel1,	
	
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
    output  o_VGA_blue_2,
    output reg o_VGA_CLK = 1'b1
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
	
	// Clock Signals
	
	wire bufpll_lock, pclk;

	ip_pll pll
	(
		.refclk		(i_clk),
		.reset		(1'b0),
		.extlock	(bufpll_lock),
		.clk0_out	(pclk)
	);
	
	//Pattern for dispaly
	wire [2:0]i_pattern;
    reg  [2:0]i_pattern_reg;

	always @(sel0 or sel1) begin
        case({sel0, sel1}) 
            2'b00: i_pattern_reg <= 3'b000;
            2'b01: i_pattern_reg <= 3'b001;
            2'b10: i_pattern_reg <= 3'b010;
            2'b11: i_pattern_reg <= 3'b011;
        endcase 
    end

    assign i_pattern = i_pattern_reg;
	
    //////////////////////////////////////////////////////////////////////////////////////
    // Creating Instants of VGA modules
    //////////////////////////////////////////////////////////////////////////////////////

    vga_sync_pulse i1
    (
        .i_clk(pclk),
        .o_hsync(w_hsync_vga),
        .o_vsync(w_vsync_vga),
        .o_col_count(),
        .o_row_count()
    );

    test_pattern_gen i2
    (
        .i_clk(pclk),
        .i_pattern(i_pattern),
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
        .i_clk(pclk),
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
	
	always @(posedge pclk) 
		o_VGA_CLK <= ~o_VGA_CLK;

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

module ip_pll(refclk,
		reset,
		extlock,
		clk0_out);

	input refclk;
	input reset;
	output extlock;
	output clk0_out;

	wire clk0_buf;

	EG_LOGIC_BUFG bufg_feedback( .i(clk0_buf), .o(clk0_out) );

	EG_PHY_PLL #(.DPHASE_SOURCE("DISABLE"),
		.DYNCFG("DISABLE"),
		.FIN("24.000"),
		.FEEDBK_MODE("NORMAL"),
		.FEEDBK_PATH("CLKC0_EXT"),
		.STDBY_ENABLE("DISABLE"),
		.PLLRST_ENA("ENABLE"),
		.SYNC_ENABLE("ENABLE"),
		.DERIVE_PLL_CLOCKS("DISABLE"),
		.GEN_BASIC_CLOCK("DISABLE"),
		.GMC_GAIN(6),
		.ICP_CURRENT(3),
		.KVCO(6),
		.LPF_CAPACITOR(3),
		.LPF_RESISTOR(2),
		.REFCLK_DIV(24),
		.FBCLK_DIV(25),
		.CLKC0_ENABLE("ENABLE"),
		.CLKC0_DIV(30),
		.CLKC0_CPHASE(30),
		.CLKC0_FPHASE(0)	)
	pll_inst (.refclk(refclk),
		.reset(reset),
		.stdby(1'b0),
		.extlock(extlock),
		.psclk(1'b0),
		.psdown(1'b0),
		.psstep(1'b0),
		.psclksel(3'b000),
		.psdone(open),
		.dclk(1'b0),
		.dcs(1'b0),
		.dwe(1'b0),
		.di(8'b00000000),
		.daddr(6'b000000),
		.do({open, open, open, open, open, open, open, open}),
		.fbclk(clk0_out),
		.clkc({open, open, open, open, clk0_buf}));
endmodule
