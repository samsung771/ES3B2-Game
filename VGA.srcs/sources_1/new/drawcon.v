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
        
        output [9:0] memory_addr,
        input [7:0] tile,
        
        input [3:0] lives,
        
        input [15:0] enemy_1_pos_x,
        input [10:0] enemy_1_pos_y,
        input enemy_1_direction,
        
        input [15:0] enemy_2_pos_x,
        input [10:0] enemy_2_pos_y,
        input enemy_2_direction
    );
    
    //Foreground colour registers
    reg [3:0] fg_r, fg_g, fg_b;
    
    //Wires for each enemy renderer
    wire [3:0] enemy_1_r, enemy_1_g, enemy_1_b, enemy_2_r, enemy_2_g, enemy_2_b;
    
    //Combine enemy 1 and enemy 2 renders
    wire [3:0] enemy_r, enemy_g, enemy_b;
    assign enemy_r = enemy_1_r + enemy_2_r;
    assign enemy_g = enemy_1_g + enemy_2_g;
    assign enemy_b = enemy_1_b + enemy_2_b;
    
    //Wires for player render
    wire [3:0] player_r, player_g, player_b;
    
    //5Hz animation clock
    wire anim_clk;
    animation_clk_div (.clk(clk),.anim_clk(anim_clk));
   
    // ----------------------------- Foreground renderer instances ----------------------------- 
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
    
    //Enemy renderer module is reused for each enemy
    enemy_renderer enemy_1_renderer_inst (
        .clk(clk),
        .anim_clk(anim_clk),
        .rst(rst),
        .curr_x(curr_x),
        .curr_y(curr_y),
        .cam_x(cam_x),
        .draw_r(enemy_1_r),
        .draw_g(enemy_1_g),
        .draw_b(enemy_1_b),
        .pos_x(enemy_1_pos_x),
        .pos_y(enemy_1_pos_y),
        .enemydirection(enemy_1_direction)
    );
    
    enemy_renderer enemy_2_renderer_inst (
        .clk(clk),
        .anim_clk(anim_clk),
        .rst(rst),
        .curr_x(curr_x),
        .curr_y(curr_y),
        .cam_x(cam_x),
        .draw_r(enemy_2_r),
        .draw_g(enemy_2_g),
        .draw_b(enemy_2_b),
        .pos_x(enemy_2_pos_x),
        .pos_y(enemy_2_pos_y),
        .enemydirection(enemy_2_direction)
    );
    
    //Combine player and enemy registers
    //Draws enemy over player
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
    
    
    //Background colour registers
    reg [3:0] bg_r, bg_g, bg_b;
    
    //Wires for infobar render
    wire [3:0] bar_r, bar_g, bar_b;
    
    //Wires for level render
    wire [3:0] lvl_r, lvl_g, lvl_b;
    
    // ----------------------------- Background renderer instances ----------------------------- 
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
    
    //Combines Info bar and level renders
    //Draws info bar when y < 100
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
    
    //Transparent when foreground = 000
    wire transparent = ((fg_r != 4'b0000) || (fg_g != 4'b0000) || (fg_b != 4'b0000));
    
    //Draw foreground over background
    assign draw_r = transparent ? fg_r : bg_r;    
    assign draw_g = transparent ? fg_g : bg_g;
    assign draw_b = transparent ? fg_b : bg_b;
endmodule
