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

    
    reg [12:0] addr = 0; //13 bit address
    reg [12:0] addrOffset = 0; //13 bit address
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
    
    
   
    
    // ------------- Animation clock divider
    reg [23:0] clk_div;
    reg anim_clk;
    //~10Hz clock div
    always @ (posedge clk)  begin
        if(!rst)
            clk_div <= 0;
        else begin
            if (clk_div == 24'd10000000) begin
                clk_div <= 0;
                anim_clk <= !anim_clk;
            end else 
                clk_div <= clk_div+1;
        end
    end

    always @ (posedge anim_clk) begin
        if (addrOffset < (`MEM_OFFSET * 3)) 
            addrOffset <= addrOffset + `MEM_OFFSET;
        else
            addrOffset <= 0;
    end
    
    
    // ----------------- Rendering
    wire [8:0] pix_x, pix_y;
    
    assign pix_x = curr_x >> 2;  
    assign pix_y = curr_y >> 2;
    
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
                if ((curr_x == blkpos_x) || (curr_y == blkpos_y)) begin
                    blk_r <= 4'hf;
                    blk_g <= 4'h0;
                    blk_b <= 4'h0;
                end else begin
                    //set rgb to sprite
                    blk_r <= rom_pixel[11:8];
                    blk_g <= rom_pixel[7:4];
                    blk_b <= rom_pixel[3:0];
                end
                
                if ((curr_x == blkpos_x) && (curr_y == blkpos_y))
                    addr <= addrOffset;
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
