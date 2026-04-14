`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.04.2026 01:05:12
// Design Name: 
// Module Name: frame_buffer
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

module frame_buffer(
        input clk,
        input [10:0] curr_x,
        input [10:0] curr_y,
        input [3:0] write_r,
        input [3:0] write_g,
        input [3:0] write_b,
        output [3:0] read_r,
        output [3:0] read_g,
        output [3:0] read_b
    );
    
    reg [3:0] buf_r [0:((`RESOLUTION_X >> 2)-1)][0:((`RESOLUTION_Y >> 2)-1)];
    reg [3:0] buf_g [0:((`RESOLUTION_X >> 2)-1)][0:((`RESOLUTION_Y >> 2)-1)];
    reg [3:0] buf_b [0:((`RESOLUTION_X >> 2)-1)][0:((`RESOLUTION_Y >> 2)-1)];
    
    assign read_r = buf_r[curr_x][curr_y];
    assign read_g = buf_g[curr_x][curr_y];
    assign read_b = buf_b[curr_x][curr_y];
    
    always @ (posedge clk) begin
        buf_r[curr_x][curr_y] <= write_r;
        buf_g[curr_x][curr_y] <= write_g;
        buf_b[curr_x][curr_y] <= write_b;
    end
    
endmodule
