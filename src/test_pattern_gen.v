////////////////////////////////////////////////////////////////////////////////
//   Module Name: test_pattern_gen.v
//  Dependencies: 25 MHz Clock, input hsync and vsync, also the pattern number
//          Info: Generating DIffernet Test Patterns according to the input
//                i_pattern
////////////////////////////////////////////////////////////////////////////////

/*
    Available Patterns:
    Pattern 0: Disables the test pattern generator
    Pattern 1: All Red
    Pattern 2: All Green
    Pattern 3: ALl Blue
    Pattern 4: Checkboard White/Black
*/

module test_pattern_gen
(
    input i_clk,
    input [2:0] i_pattern,
    input i_hsync,
    input i_vsync,
    output reg o_hsync = 0,
    output reg o_vsync = 0,
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

    //Control Signls:
    wire w_vsync;
    wire w_hsync;
    wire [9:0] w_col_count;
    wire [9:0] w_row_count;

    //Patterns have 16 indexes (0 to 15)
    wire [VIDEO_WIDTH - 1:0] pattern_red   [0:4];      //3 Bit Vector with 16 depth
    wire [VIDEO_WIDTH - 1:0] pattern_green [0:4];      //3 Bit Vector with 16 depth
    wire [VIDEO_WIDTH - 1:0] pattern_blue  [0:4];      //3 Bit Vector with 16 depth

    //Creating Instant
    sync_count i3
    (
        .i_clk(i_clk),
        .i_hsync(i_hsync),
        .i_vsync(i_vsync),
        .o_hsync(w_hsync),
        .o_vsync(w_vsync),
        .o_col_count(w_col_count),
        .o_row_count(w_row_count)
    );

    //Registers sync to align with the output data
    always @(i_clk) begin
        o_vsync <= w_vsync;
        o_hsync <= w_hsync;
    end

    // Pattern 0: Disables the Test Pattern Generator
    assign pattern_red[0]   = 0;
    assign pattern_green[0] = 0;
    assign pattern_blue[0]  = 0;

    // Pattern 1: All Red
    assign pattern_red[1]   = (w_col_count < ACTIVE_COLS && w_row_count < ACTIVE_ROWS) ? {VIDEO_WIDTH{1'b1}} : 0;
    assign pattern_green[1] = 0;
    assign pattern_blue[1]  = 0;

    // Pattern 2: All GREEN
    assign pattern_red[2]   = 0;
    assign pattern_green[2] = (w_col_count < ACTIVE_COLS && w_row_count < ACTIVE_ROWS) ? {VIDEO_WIDTH{1'b1}} : 0;
    assign pattern_blue[2]  = 0;

    // Pattern 3: All Blue
    assign pattern_red[3]   = 0;
    assign pattern_green[3] = 0;
    assign pattern_blue[3]  = (w_col_count < ACTIVE_COLS && w_row_count < ACTIVE_ROWS) ? {VIDEO_WIDTH{1'b1}} : 0;

    // Pattern 4: Checkboard White/Black
    assign pattern_red[4]   = w_col_count[5] ^ w_row_count[5] ? {VIDEO_WIDTH{1'b1}} : 0;
    assign pattern_green[4] = pattern_red[4];
    assign pattern_blue[4]  = pattern_red[4];  

    ////////////////////////////////////////////////////////////////////////////////////////////
    // Select Different Test Patterns
    ////////////////////////////////////////////////////////////////////////////////////////////
    always @(posedge i_clk) begin
        case(i_pattern)
            3'b000: begin
                o_red_video   <=   pattern_red[0];
                o_green_video <= pattern_green[0];
                o_blue_video  <=  pattern_blue[0];
            end
            3'b001: begin
                o_red_video   <=   pattern_red[1];
                o_green_video <= pattern_green[1];
                o_blue_video  <=  pattern_blue[1];
            end
            3'b010: begin
                o_red_video   <=   pattern_red[2];
                o_green_video <= pattern_green[2];
                o_blue_video  <=  pattern_blue[2];
            end
            3'b011: begin
                o_red_video   <=  pattern_red[3];
                o_green_video <= pattern_green[3];
                o_blue_video  <=  pattern_blue[3];
            end
            3'b100: begin
                o_red_video   <=  pattern_red[4];
                o_green_video <= pattern_green[4];
                o_blue_video  <=  pattern_blue[4];
            end
        endcase
    end
endmodule