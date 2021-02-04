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
    wire [VIDEO_WIDTH - 1:0] pattern_red   [0:5];      //3 Bit Vector with 16 depth
    wire [VIDEO_WIDTH - 1:0] pattern_green [0:5];      //3 Bit Vector with 16 depth
    wire [VIDEO_WIDTH - 1:0] pattern_blue  [0:5];      //3 Bit Vector with 16 depth

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
    always @(posedge i_clk) begin
        o_vsync <= w_vsync;
        o_hsync <= w_hsync;
    end

    ///////////////////////////////////////////////////////
    // Pattern 0: Disables the Test Pattern Generator
    ///////////////////////////////////////////////////////
    assign pattern_red[0]   = 0;
    assign pattern_green[0] = 0;
    assign pattern_blue[0]  = 0;

    //////////////////////////////////////////////////////
    // Pattern 1: All Red
    //////////////////////////////////////////////////////
    assign pattern_red[1]   = (w_col_count < ACTIVE_COLS && w_row_count < ACTIVE_ROWS) ? {VIDEO_WIDTH{1'b1}} : 0;
    assign pattern_green[1] = 0;
    assign pattern_blue[1]  = 0;

    //////////////////////////////////////////////////////
    // Pattern 2: All GREEN
    //////////////////////////////////////////////////////
    assign pattern_red[2]   = 0;
    assign pattern_green[2] = (w_col_count < ACTIVE_COLS && w_row_count < ACTIVE_ROWS) ? {VIDEO_WIDTH{1'b1}} : 0;
    assign pattern_blue[2]  = 0;

    //////////////////////////////////////////////////////
    // Pattern 3: All Blue
    /////////////////////////////////////////////////////
    assign pattern_red[3]   = 0;
    assign pattern_green[3] = 0;
	assign pattern_blue[3]  = (w_col_count < ACTIVE_COLS && w_row_count < ACTIVE_ROWS) ? {VIDEO_WIDTH{1'b1}} : 0;

    /////////////////////////////////////////////////////
    // Pattern 4: Checkboard White/Black
    /////////////////////////////////////////////////////
    assign pattern_red[4]   = (w_col_count < ACTIVE_COLS && w_row_count < ACTIVE_ROWS) ? (w_col_count[6] ^ w_row_count[6] ? {VIDEO_WIDTH{1'b1}} : 0) : 0;
    assign pattern_green[4] = pattern_red[4];
    assign pattern_blue[4]  = pattern_red[4];  

    ////////////////////////////////////////////////////
    // Pattern 5: Color Bars
    // Divides active area into 8 Equal Bars and colors them accordingly
    // Colors Each According to this Truth Table:
    // R G B  w_Bar_Select  Ouput Color
    // 0 0 0       0        Black
    // 0 0 1       1        Blue
    // 0 1 0       2        Green
    // 0 1 1       3        Turquoise
    // 1 0 0       4        Red
    // 1 0 1       5        Purple
    // 1 1 0       6        Yellow
    // 1 1 1       7        White
    ////////////////////////////////////////////////////
    
    wire [6:0] w_Bar_Width = ACTIVE_COLS/8;
  
    wire [2:0] w_Bar_Select = w_col_count < w_Bar_Width*1 ? 0 : 
  			        w_col_count < w_Bar_Width*2 ? 1 : 
  			        w_col_count < w_Bar_Width*3 ? 2 : 
  			        w_col_count < w_Bar_Width*4 ? 3 : 
  			        w_col_count < w_Bar_Width*5 ? 4 : 
  			        w_col_count < w_Bar_Width*6 ? 5 : 
  			        w_col_count < w_Bar_Width*7 ? 6 : 7;

    // Implement Truth Table above with Conditional Assignments
    assign pattern_red[5] = (w_Bar_Select == 4 || w_Bar_Select == 5 
                                            || w_Bar_Select == 6 || w_Bar_Select == 7) ?  
                                            {VIDEO_WIDTH{1'b1}} : 0;
					 
    assign pattern_green[5] = (w_Bar_Select == 2 || w_Bar_Select == 3 
					 || w_Bar_Select == 6 || w_Bar_Select == 7) 
					 ?  {VIDEO_WIDTH{1'b1}} : 0;

    assign pattern_blue[5] =  (w_Bar_Select == 1 || w_Bar_Select == 3 
				       || w_Bar_Select == 5 || w_Bar_Select == 7) 
                                              ? {VIDEO_WIDTH{1'b1}} : 0;

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
            3'b101: begin
                o_red_video   <=  pattern_red[5];
                o_green_video <= pattern_green[5];
                o_blue_video  <=  pattern_blue[5];
            end
        endcase
    end
endmodule