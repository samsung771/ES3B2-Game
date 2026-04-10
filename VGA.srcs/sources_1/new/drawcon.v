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

    
    //parameter IMG_SIZE = 100;
    reg [13:0] addr = 0; //14 bit address
    wire [11:0] rom_pixel;
    
    //Draw inside border
    always @ (posedge clk) begin
        if (!rst) begin
            blk_r <= 4'b0000;
            blk_g <= 4'b0000;
            blk_b <= 4'b0000;
            addr <= 0;
        end else if (
        (curr_x >= `BORDER_SIZE) &&
        (curr_x <= (`RESOLUTION_X-`BORDER_SIZE)) && 
        (curr_y >= `BORDER_SIZE) && 
        (curr_y <= (`RESOLUTION_Y-`BORDER_SIZE))
        ) begin
            //If pointer is within block
            if (
            (curr_x >= blkpos_x) && 
            (curr_x <= blkpos_x + `BLK_SIZE) &&
            (curr_y >= blkpos_y) && 
            (curr_y <= blkpos_y + `BLK_SIZE)
            ) begin
                //set rgb to sprite
                blk_r <= rom_pixel[11:8];
                blk_g <= rom_pixel[7:4];
                blk_b <= rom_pixel[3:0];
                
                //set address to 0 at start
                if ((curr_x == blkpos_x) && (curr_y == blkpos_y))
                    addr <= 0;
                //else increment
                else
                    addr <= addr + 1;
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
    
    blk_mem_gen_0 inst
    (
    .clka(clk),
    .addra(addr),
    .douta(rom_pixel)   
    );
    
endmodule
