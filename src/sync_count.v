////////////////////////////////////////////////////////////////////////////////
//   Module Name: sync_count.v
//  Dependencies: 25 MHz Clock, input hsync and output sync from sync count
//          Info: Module takes incoming horizontal and vertical pulses and create
//                Row and Column counters based on these syncs
//                It will align the Row/Col counters to the ouptut sync pulses
//                Useful for any module that needs to keep track of which Row/Col 
//                position we are on in the middile of frame
////////////////////////////////////////////////////////////////////////////////


module sync_count
(
    input  i_clk,
    input  i_hsync,
    input  i_vsync,
    output reg  o_hsync,
    output reg  o_vsync,
    output reg [9:0] o_col_count = 0,
    output reg [9:0] o_row_count = 0 
);
    //Parameter Needed For producing horizontal and veritical sync
    parameter TOTAL_COLS = 800;
    parameter TOTAL_ROWS = 525;

    wire w_frame_start;

    //Registers syncs to align with the output data
    always @(posedge i_clk) begin
        o_vsync <= i_vsync;
        o_hsync <= i_hsync;
    end

    //Keep the track of Row and column counters
    always @(posedge i_clk) begin
        if ( w_frame_start == 1'b1) begin
            o_col_count <= 0;
            o_row_count <= 0;
        end
        else begin
            if ( o_col_count == (TOTAL_COLS - 1)) begin
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
    end

    //Look for rising edge on Vertical Sync to reset the counters
    assign w_frame_start = (~o_vsync & i_vsync);
endmodule