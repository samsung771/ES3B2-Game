`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.03.2026 04:21:45
// Design Name: 
// Module Name: game_top
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


module game_top(
    input clk,
    input rst,
    input [2:0] sw,
    input [4:0] btn,
    output [3:0] pix_r,
    output [3:0] pix_g,
    output [3:0] pix_b,
    output hsync,
    output vsync
    );
    
    wire pixclk;
        
    reg[20:0] clk_div;
    reg game_clk;
    reg [10:0] blkpos_x = `RESOLUTION_X/2;
    reg [10:0] blkpos_y = `RESOLUTION_Y/2;
    
    clk_wiz_0 inst (
        // Clock out ports  
        .clk_out1(pixclk),
        // Clock in ports
        .clk_in1(clk)
        );
    
    //60Hz clock div
    always @ (posedge clk)  begin
        if(!rst)
            clk_div <= 0;
        else begin
            if (clk_div == 21'd1666666) begin
                clk_div <= 0;
                game_clk <= !game_clk;
            end else 
                clk_div <= clk_div+1;
        end
    end
    
    always @ (posedge game_clk)  begin
        if (btn[0]) begin 
            blkpos_x <= `RESOLUTION_X/2;
            blkpos_y <= `RESOLUTION_Y/2;
        end 
        else begin
            case (btn[4:1]) 
            `LBTN:
                if (blkpos_x > 0)
                    blkpos_x <= blkpos_x -5;
            `RBTN:
                if (blkpos_x < (`RESOLUTION_X - `BLK_SIZE))
                    blkpos_x <= blkpos_x +5;
            `UBTN:
                if (blkpos_y > `BORDER_TOP)
                    blkpos_y <= blkpos_y -5;
            `DBTN: 
                if (blkpos_y < (`RESOLUTION_Y - `BORDER_BTM - `BLK_SIZE))
                    blkpos_y <= blkpos_y +5;
            endcase
        end 
    end
    
    wire [3:0] draw_r;
    wire [3:0] draw_g;
    wire [3:0] draw_b;
    
    wire [10:0] curr_x;
    wire [10:0] curr_y;
    
    drawcon drawcon_inst(
        .clk(pixclk),
        .rst(rst),
        .curr_x(curr_x),
        .curr_y(curr_y),
        .draw_r(draw_r),
        .draw_g(draw_g),
        .draw_b(draw_b),
        .blkpos_x(blkpos_x),
        .blkpos_y(blkpos_y)
        );

    vga_out vga_inst( 
        .clk(pixclk),
        .rst(rst),
        .draw_r(draw_r),
        .draw_g(draw_g),
        .draw_b(draw_b),
        .curr_x(curr_x),
        .curr_y(curr_y),
        .pix_r(pix_r),
        .pix_g(pix_g),
        .pix_b(pix_b),
        .hsync(hsync),
        .vsync(vsync)
        );
endmodule
