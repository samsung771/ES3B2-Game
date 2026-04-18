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
        
    wire [10:0] playerpos_x;
    wire [10:0] playerpos_y;
    wire [15:0] camerapos_x;
    wire [15:0] globalpos;
    
    
    clk_wiz_0 pix (
    .clk_out1(pixclk),
    .clk_in1(clk)
    );
    
    
    //60Hz game clock for position updates
    wire game_clk;
    
    game_clk_div (
        .clk(clk),
        .game_clk(game_clk)
    );
    
    wire signed [5:0] vel_x;
    
    camera_controller camera_inst (
        .clk(clk),
        .rst(rst),
        .playerpos_x(globalpos),
        .vel_x(vel_x),
        .camerapos_x(camerapos_x)
    );
    
    player_controller player_inst (
        .clk(clk),
        .game_clk(game_clk),
        .rst(rst),
        .btn(btn),
        .cam_x(camerapos_x),
        .playerpos_x(playerpos_x),
        .playerpos_y(playerpos_y),
        .globalpos(globalpos),
        .vel_out(vel_x)
    );
    
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
        .cam_x(camerapos_x),
        .draw_r(draw_r),
        .draw_g(draw_g),
        .draw_b(draw_b),
        .playerpos_x(globalpos),
        .playerpos_y(playerpos_y)
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
