`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.03.2026 02:49:17
// Design Name: 
// Module Name: vga_out
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

`define VGA_SIZE_X 11'd1903
`define VGA_SIZE_Y 10'd931

module vga_out(
    input clk,
    input rst,
    input [3:0] draw_r,
    input [3:0] draw_g,
    input [3:0] draw_b,
    output [10:0] curr_x,
    output [10:0] curr_y,
    output [3:0] pix_r,
    output [3:0] pix_g,
    output [3:0] pix_b,
    output hsync,
    output vsync
    );
    
    reg [10:0] hcount = 0;
    reg [9:0] vcount = 0;
    reg [10:0] curr_x_r;
    reg [10:0] curr_y_r;

    wire display_region;
    wire line_end = (hcount == `VGA_SIZE_X);
    wire col_end = (vcount == `VGA_SIZE_Y);
    
    
    assign hsync = ((hcount >= 11'd0) && (hcount <= 11'd151)); 
    assign vsync = ((vcount >= 10'd0) && (vcount <= 10'd2)); 
    
    assign display_region = (((hcount >= 11'd384) && (hcount <= 11'd1823)) && (vcount >= 10'd31) && (vcount <= 10'd930));

        
    assign pix_r = (display_region) ? draw_r : 4'b0000;
    assign pix_g = (display_region) ? draw_g : 4'b0000;
    assign pix_b = (display_region) ? draw_b : 4'b0000;
    
    always @ (posedge clk) begin
        if(!rst) begin
            hcount <= 11'd0;
            vcount <= 10'd0;
        end else begin
            if (col_end)
                vcount <= 10'd0;
            if (line_end) begin
                hcount <= 11'd0;
                vcount <= vcount + 10'd1;
            end else 
                hcount <= hcount + 11'd1;
        end 
    end
    
    assign curr_x = curr_x_r;
    assign curr_y = curr_y_r;
    
    // Loop Horizontal counter
    always @ (posedge clk) begin
        if(!rst)
            curr_x_r <= 11'd0;
        else begin
            if ((hcount >= 11'd384) && (hcount <= 11'd1824)) begin
                curr_x_r <= curr_x_r + 11'd1;
            end else 
                curr_x_r <= 11'd0;
        end 
    end 
    
    // Loop Vertical counter
    always @ (posedge clk) begin
        if(!rst)
            curr_y_r <= 11'd0;
        else begin
            if ((vcount >= 11'd31) && (vcount <= 11'd930)) begin
                if (line_end)
                    curr_y_r <= curr_y_r + 11'd1;
            end else 
                curr_y_r <= 11'd0;
        end 
    end 
    
endmodule
