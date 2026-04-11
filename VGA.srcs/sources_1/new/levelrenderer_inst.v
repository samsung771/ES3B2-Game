`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.04.2026 19:53:25
// Design Name: 
// Module Name: levelrenderer_inst
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

module levelrenderer(
        input clk,
        input rst,
        input [10:0] curr_x,
        input [10:0] curr_y,
        output [3:0] draw_r,
        output [3:0] draw_g,
        output [3:0] draw_b
    );
    
    reg [3:0] bg_r, bg_g, bg_b;
    
    always @ (posedge clk) begin
        if (!rst) begin
            bg_r <= 4'b0000;
            bg_g <= 4'b0000;
            bg_b <= 4'b0000;
        end else if (
        (curr_x >= `BORDER_SIZE) &&
        (curr_x <= (`RESOLUTION_X-`BORDER_SIZE)) && 
        (curr_y >= `BORDER_SIZE) && 
        (curr_y <= (`RESOLUTION_Y-`BORDER_SIZE))
        ) begin 
            bg_r <= `BG_R;
            bg_g <= `BG_G;
            bg_b <= `BG_B;
        end else begin
            bg_r <= `BORDER_R;
            bg_g <= `BORDER_G;
            bg_b <= `BORDER_B;
        end
    end
    
    assign draw_r = bg_r;
    assign draw_g = bg_g;
    assign draw_b = bg_b;
    
endmodule
