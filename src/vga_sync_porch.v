////////////////////////////////////////////////////////////////////////////////
//   Module Name: vga_sync_porch.v
//  Dependencies: 25 MHz Clock, input hsync and vsync, also the pattern number
//          Info: Generating DIffernet Test Patterns according to the input
//                i_pattern
////////////////////////////////////////////////////////////////////////////////

module vga_sync_porch
(
    input i_clk,
    input i_hsync,
    input i_vsync,
    input [2:0] i_red_video,
    input [2:0] i_green_video,
    input [2:0] i_blue_video,
    output reg o_hsync,
    output reg o_vsync,
    output reg [2:0] o_red_video,
    output reg [2:0] o_green_video,
    output reg [2:0] o_blue_video
);

    //Parameter Needed:
    parameter VIDEO_WIDTH =    3;
    parameter TOTAL_COLS  =  800;
    parameter TOTAL_ROWS  =  525;
    parameter ACTIVE_COLS =  640;
    parameter ACTIVE_ROWS =  480;  

    parameter c_FRONT_PORCH_HORZ = 18;
    parameter c_BACK_PORCH_HORZ  = 50;
    parameter c_FRONT_PORCH_VERT = 10;
    parameter c_BACK_PORCH_VERT  = 33;

    wire w_hsync;
    wire w_vsync;
    wire [9:0] w_col_count;
    wire [9:0] w_row_count;

    reg [VIDEO_WIDTH-1:0] r_red_video = 0;
    reg [VIDEO_WIDTH-1:0] r_green_video = 0;
    reg [VIDEO_WIDTH-1:0] r_blue_video = 0;

    //Creating Instant
    sync_count i5
    (
        .i_clk(i_clk),
        .i_hsync(i_hsync),
        .i_vsync(i_vsync),
        .o_hsync(w_hsync),
        .o_vsync(w_vsync),
        .o_col_count(w_col_count),
        .o_row_count(w_row_count)
    );

    //Modifies the Hsync and Vsync signals to include Front and Back Porch
    always @(posedge i_clk) begin
        if ( (w_col_count < c_FRONT_PORCH_HORZ + ACTIVE_COLS) || (w_col_count > TOTAL_COLS - c_BACK_PORCH_HORZ) ) begin
            o_hsync <= 1'b1;
        end    
        else begin 
            o_hsync <= w_hsync;   
        end 

        if ( (w_row_count < c_FRONT_PORCH_VERT + ACTIVE_ROWS) || (w_row_count > TOTAL_ROWS - c_BACK_PORCH_VERT) ) begin
            o_vsync <= 1'b1;
        end    
        else begin 
            o_vsync <= w_vsync;   
        end 
    end

    //Align input video to modified sync pulses
    always @(posedge i_clk) begin
        r_red_video   <=   i_red_video;
        r_green_video <= i_green_video;
        r_blue_video  <=  i_blue_video;

        o_red_video   <=   r_red_video;
        o_green_video <= r_green_video;
        o_blue_video  <=  r_blue_video;
    end
endmodule