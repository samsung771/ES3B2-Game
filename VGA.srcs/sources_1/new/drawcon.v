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

    wire [3:0] bg_r, bg_g, bg_b;

    
    reg [14:0] addr = 0; //15 bit address
    reg [14:0] addrOffset = 0; //15 bit address
    wire [11:0] rom_pixel;
    
    levelrenderer levelrenderer_inst (
        .clk(clk),
        .rst(rst),
        .curr_x(curr_x),
        .curr_y(curr_y),
        .draw_r(bg_r),
        .draw_g(bg_g),
        .draw_b(bg_b)
    );
    
    reg[21:0] clk_div;
    reg game_clk;
    //60Hz clock div
    always @ (posedge clk)  begin
        if(!rst)
            clk_div <= 0;
        else begin
            if (clk_div == 22'd33333333) begin
                clk_div <= 0;
                game_clk <= !game_clk;
            end else 
                clk_div <= clk_div+1;
        end
    end

    always @ (posedge game_clk) begin
        if (addrOffset < 'd12288) 
            addrOffset <= addrOffset + 'd4096;
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
            (curr_y >= blkpos_y) && 
            (curr_y < blkpos_y + `BLK_SIZE)
            ) begin
                //set rgb to sprite
                blk_r <= rom_pixel[11:8];
                blk_g <= rom_pixel[7:4];
                blk_b <= rom_pixel[3:0];
                
                //set address to 0 at start
                if ((curr_x == blkpos_x) && (curr_y == blkpos_y))
                    addr <= addrOffset;
                //else increment
                else
                    addr <= addr + 1;
                
        end else begin
            blk_r <= 4'b0000;
            blk_g <= 4'b0000;
            blk_b <= 4'b0000;
        end
    end
    
    assign draw_r = ((blk_r != 4'b0000) || (blk_g != 4'b0000) || (blk_b != 4'b0000)) ? blk_r : bg_r;    
    assign draw_g = ((blk_r != 4'b0000) || (blk_g != 4'b0000) || (blk_b != 4'b0000)) ? blk_g : bg_g;
    assign draw_b = ((blk_r != 4'b0000) || (blk_g != 4'b0000) || (blk_b != 4'b0000)) ? blk_b : bg_b;
    
    blk_mem_gen_0 inst
    (
    .clka(clk),
    .addra(addr),
    .douta(rom_pixel)   
    );
    
endmodule
