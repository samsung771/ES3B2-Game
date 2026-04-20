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
        input clk,
        input rst,
        input [10:0] curr_x,
        input [10:0] curr_y,
        input [15:0] cam_x,
        output [3:0] draw_r,
        output [3:0] draw_g,
        output [3:0] draw_b,
        input [15:0] playerpos_x,
        input [10:0] playerpos_y,
        input [1:0] playerstate,
        input [1:0] eventstate,
        input [15:0] enemypos_x,
        input [10:0] enemypos_y,
        output [9:0] memory_addr,
        input [7:0] tile,
        input [3:0] lives,
        input enemydirection
    );
    
    reg [3:0] fg_r, fg_g, fg_b;
    
    wire [3:0] enemy_r, enemy_g, enemy_b;
    wire [3:0] player_r, player_g, player_b;
    
    wire [3:0] bar_r, bar_g, bar_b;
    wire [3:0] lvl_r, lvl_g, lvl_b;
    
    reg [3:0] bg_r, bg_g, bg_b;
    
    
    wire anim_clk;
    
    animation_clk_div (
    .clk(clk),
    .anim_clk(anim_clk)
    );
   
    
    player_renderer player_renderer_inst (
        .clk(clk),
        .anim_clk(anim_clk),
        .rst(rst),
        .curr_x(curr_x),
        .curr_y(curr_y),
        .cam_x(cam_x),
        .draw_r(player_r),
        .draw_g(player_g),
        .draw_b(player_b),
        .playerpos_x(playerpos_x),
        .playerpos_y(playerpos_y),
        .playerstate(playerstate),
        .eventstate(eventstate)
    );
    
    enemy_renderer enemy_renderer_inst (
        .clk(clk),
        .anim_clk(anim_clk),
        .rst(rst),
        .curr_x(curr_x),
        .curr_y(curr_y),
        .cam_x(cam_x),
        .draw_r(enemy_r),
        .draw_g(enemy_g),
        .draw_b(enemy_b),
        .pos_x(enemypos_x),
        .pos_y(enemypos_y),
        .enemydirection(enemydirection)
    );
    
    
    levelrenderer levelrenderer_inst (
        .clk(clk),
        .rst(rst),
        .curr_x(curr_x),
        .curr_y(curr_y),
        .cam_x(cam_x),
        .draw_r(lvl_r),
        .draw_g(lvl_g),
        .draw_b(lvl_b),
        .memory_addr(memory_addr),
        .tile(tile)
    );
    
    
    infobar_renderer infobar_renderer_inst (
        .clk(clk),
        .anim_clk(anim_clk),
        .rst(rst),
        .curr_x(curr_x),
        .curr_y(curr_y),
        .draw_r(bar_r),
        .draw_g(bar_g),
        .draw_b(bar_b),
        .lives(lives)
    );
    
    always @ (posedge clk) begin
        if (curr_y <= `BORDER_TOP) begin
            bg_r <= bar_r;
            bg_g <= bar_g;
            bg_b <= bar_b;
        end
        else begin
            bg_r <= lvl_r;
            bg_g <= lvl_g;
            bg_b <= lvl_b;
        end
    end
    
     always @ (posedge clk) begin
        if ((enemy_r != 4'b0000) || (enemy_g != 4'b0000) || (enemy_b != 4'b0000)) begin
            fg_r <= enemy_r;
            fg_g <= enemy_g;
            fg_b <= enemy_b;
        end
        else begin
            fg_r <= player_r;
            fg_g <= player_g;
            fg_b <= player_b;
        end
    end
    
    wire transparent = ((fg_r != 4'b0000) || (fg_g != 4'b0000) || (fg_b != 4'b0000));
    
    assign draw_r = transparent ? fg_r : bg_r;    
    assign draw_g = transparent ? fg_g : bg_g;
    assign draw_b = transparent ? fg_b : bg_b;
    
    
endmodule
