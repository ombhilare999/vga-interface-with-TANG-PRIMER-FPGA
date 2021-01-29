////////////////////////////////////////////////////////////////////////////////
//   Module Name: vga_sync_pulse.v
//  Dependencies: 25 MHz Clock Input and Hsynch and Vsynch Output
//          Info: Producing Vertical and Horizontal Synch Signals using clock 
//                reference
////////////////////////////////////////////////////////////////////////////////


module vga_sync_pulse
(
    input   i_clk,
    output  o_hsync,
    output  o_vsync,
    output reg [9:0] o_col_count = 0,
    output reg [9:0] o_row_count = 0
);

    //Parameter Needed For producing horizontal and veritical sync
    parameter TOTAL_COLS = 800;
    parameter TOTAL_ROWS = 525;
    parameter ACTIVE_COLS = 640;
    parameter ACTIVE_ROWS = 480;

    always @(posedge i_clk) begin
        if( o_col_count == (TOTAL_COLS - 1))
        begin
            o_col_count<= 0;
            if (  o_row_count == (TOTAL_ROWS - 1) ) 
                o_row_count<= 0;
            else 
                o_row_count <= o_row_count + 1;     
        end    
        else begin
            o_col_count<= o_col_count + 1;
        end
    end

    assign o_hsync = o_col_count < (ACTIVE_COLS - 1) ? 1'b1 : 1'b0;
    assign o_vsync = o_row_count < (ACTIVE_ROWS - 1) ? 1'b1 : 1'b0;

endmodule