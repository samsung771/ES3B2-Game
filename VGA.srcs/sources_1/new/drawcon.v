`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.03.2026 09:44:14
// Design Name: 
// Module Name: drawcon
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "game_top.vh"

module drawcon(
        input [10:0] curr_x,
        input [10:0] curr_y,
        output [3:0] draw_r,
        output [3:0] draw_g,
        output [3:0] draw_b,
        input [10:0] blkpos_x,
        input [10:0] blkpos_y
    );
    
    reg [3:0] blk_r, blk_g, blk_b;

    reg [3:0] bg_r = `BORDER_R;
    reg [3:0] bg_g = `BORDER_G;
    reg [3:0] bg_b = `BORDER_B;

    
    //Draw inside border
    always@* begin
        if (
        (curr_x >= `BORDER_SIZE) &&
        (curr_x <= (`RESOLUTION_X-`BORDER_SIZE)) && 
        (curr_y >= `BORDER_SIZE) && 
        (curr_y <= (`RESOLUTION_Y-`BORDER_SIZE))
        ) begin
            //Draw Block
            if (
            (curr_x >= blkpos_x) && 
            (curr_x <= blkpos_x + `BLK_SIZE) &&
            (curr_y >= blkpos_y) && 
            (curr_y <= blkpos_y + `BLK_SIZE)
            ) begin
                blk_r <= `BLK_R;
                blk_g <= `BLK_G;
                blk_b <= `BLK_B;
            end else begin
                blk_r <= `BG_R;
                blk_g <= `BG_G;
                blk_b <= `BG_B;
            end
            
        end else begin
            blk_r <= 4'b0000;
            blk_g <= 4'b0000;
            blk_b <= 4'b0000;
        end
    end
    
    assign draw_r = (blk_r != 4'b0000) ? blk_r : bg_r;    
    assign draw_g = (blk_g != 4'b0000) ? blk_g : bg_g;
    assign draw_b = (blk_b != 4'b0000) ? blk_b : bg_b;

endmodule
