`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.04.2026 19:09:09
// Design Name: 
// Module Name: player_renderer
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

module player_renderer(
        input clk,
        input anim_clk,
        input rst,
        input [10:0] curr_x,
        input [10:0] curr_y,
        input [15:0] cam_x,
        output [3:0] draw_r,
        output [3:0] draw_g,
        output [3:0] draw_b,
        input [15:0] playerpos_x,
        input [10:0] playerpos_y,
        input [1:0] playerstate
    );
    reg [15:0] addr = 0; //15 bit address
    reg [15:0] addrOffset = 0; //15 bit address
    wire [11:0] rom_pixel;
    
    
    blk_mem_gen_0 inst
    (
    .clka(clk),
    .addra(addr),
    .douta(rom_pixel)   
    );
    
    
    
    reg [3:0] blk_r, blk_g, blk_b;
    
    wire [0:10] blkpos_x;
    
    assign blkpos_x = playerpos_x - cam_x;
    

    always @ (posedge anim_clk) begin
        if (addrOffset < 3*`MEM_OFFSET) 
            addrOffset <= addrOffset + `MEM_OFFSET;
        else
            addrOffset <= 0;
    end  
    
    //Draw inside border
    always @ (posedge clk) begin
        if (!rst) begin
            blk_r <= 4'b0000;
            blk_g <= 4'b0000;
            blk_b <= 4'b0000;
            addr <= 0;
        end else if (
            (curr_x >= blkpos_x) && 
            (curr_x < blkpos_x + `BLK_SIZE) &&
            (curr_y >= playerpos_y) && 
            (curr_y < playerpos_y + `BLK_SIZE) &&
            (curr_y > `BORDER_TOP) &&
            (curr_y < `RESOLUTION_Y - `BORDER_BTM)
            ) begin
                //set rgb to sprite
                blk_r <= rom_pixel[11:8];
                blk_g <= rom_pixel[7:4];
                blk_b <= rom_pixel[3:0];
                
                //set address to 0 at start
                if ((curr_x == blkpos_x) && (curr_y == playerpos_y))
                    addr <= addrOffset + (playerstate * 16'd16384);
                //else increment
                else
                    addr <= addr + 1;
                
        end else begin
            blk_r <= 4'b0000;
            blk_g <= 4'b0000;
            blk_b <= 4'b0000;
        end
    end
    
    assign draw_r = blk_r;
    assign draw_g = blk_g;
    assign draw_b = blk_b;
    
endmodule
