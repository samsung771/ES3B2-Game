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
    input [15:0] sw,
    input [4:0] btn,
    output [15:0] LED,
    output [6:0] seg,
    output [7:0] an,
    output [3:0] pix_r,
    output [3:0] pix_g,
    output [3:0] pix_b,
    output hsync,
    output vsync
    );
    
    
    wire pixclk;
        
    wire [15:0] playerpos_x;
    wire [10:0] playerpos_y;
    wire [15:0] camerapos_x;
    wire [1:0] movestate;
    wire [1:0] eventstate;
    wire [3:0] lives;
    
    
    wire [15:0] enemy_1_pos_x;
    wire [10:0] enemy_1_pos_y;
    wire enemy_1_direction;
    
    
    wire [15:0] enemy_2_pos_x;
    wire [10:0] enemy_2_pos_y;
    wire enemy_2_direction;
    
    clk_wiz_0 pix (
    .clk_out1(pixclk),
    .clk_in1(clk)
    );
    
    timer timer_inst (
    .clk(clk),
    .rst(rst),
    .eventstate(eventstate),
    .seg(seg),
    .an(an)
    );
    
    
      
    // ----------------------------- Level Memory Setup ----------------------------- 
    //Memory address for tiled level
    wire [9:0] collision_addr;
    //Tile ID from level memory
    wire [7:0] collision_tile;
    
    //Memory address for tiled level
    wire [9:0] draw_addr;
    //Tile ID from level memory
    wire [7:0] draw_tile;
    
    //Level data memory block
    blk_mem_gen_2 level
    (
        .clka(pixclk),
        .addra(draw_addr),
        .douta(draw_tile),  
        .clkb(clk), 
        .addrb(collision_addr),
        .doutb(collision_tile)   
    );
    
    
    //60Hz game clock for position updates
    wire game_clk;
    
    game_clk_div (
        .clk(clk),
        .game_clk(game_clk)
    );
    
    
    camera_controller camera_inst (
        .clk(clk),
        .rst(rst),
        .playerpos_x(playerpos_x),
        .camerapos_x(camerapos_x)
    );
    
    player_controller player_inst (
        .clk(clk),
        .game_clk(game_clk),
        .rst(rst),
        .btn(btn),
        .sw(sw),
        .LED(LED),
        .cam_x(camerapos_x),
        .playerpos_x(playerpos_x),
        .playerpos_y(playerpos_y),
        .movestate(movestate),
        .playerstate(eventstate),
        .memory_addr(collision_addr),
        .tile(collision_tile),
        .lives(lives),
        .enemy_1_pos_x(enemy_1_pos_x),
        .enemy_1_pos_y(enemy_1_pos_y),
        .enemy_2_pos_x(enemy_2_pos_x),
        .enemy_2_pos_y(enemy_2_pos_y)
    );
    
    enemy_controller #( `ENEMY_1_BOUND_RIGHT, 
                        `ENEMY_1_BOUND_LEFT, 
                        `ENEMY_1_POS_Y) 
    enemy_1_inst (
        .clk(clk),
        .game_clk(game_clk),
        .rst(rst),
        .enemypos_x(enemy_1_pos_x),
        .enemypos_y(enemy_1_pos_y),
        .direction(enemy_1_direction)
    );
    
    
    enemy_controller #( `ENEMY_2_BOUND_RIGHT, 
                        `ENEMY_2_BOUND_LEFT, 
                        `ENEMY_2_POS_Y) 
    enemy_2_inst (
        .clk(clk),
        .game_clk(game_clk),
        .rst(rst),
        .enemypos_x(enemy_2_pos_x),
        .enemypos_y(enemy_2_pos_y),
        .direction(enemy_2_direction)
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
        .playerpos_x(playerpos_x),
        .playerpos_y(playerpos_y),
        .playerstate(movestate),
        .eventstate(eventstate),
        .memory_addr(draw_addr),
        .tile(draw_tile),
        .lives(lives),
        .enemy_1_pos_x(enemy_1_pos_x),
        .enemy_1_pos_y(enemy_1_pos_y),
        .enemy_1_direction(enemy_1_direction),
        .enemy_2_pos_x(enemy_2_pos_x),
        .enemy_2_pos_y(enemy_2_pos_y),
        .enemy_2_direction(enemy_2_direction)
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
