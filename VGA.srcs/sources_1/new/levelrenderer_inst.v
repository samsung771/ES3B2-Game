`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.04.2026 19:53:25
// Design Name: 
// Module Name: levelrenderer_inst
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

module levelrenderer(
        input clk,
        input rst,
        input [10:0] curr_x,
        input [10:0] curr_y,
        output [3:0] draw_r,
        output [3:0] draw_g,
        output [3:0] draw_b
    );
    
    reg [3:0] bg_r, bg_g, bg_b;
    
    reg [15:0] addr = 0; //16 bit address
    reg [15:0] addrOffset = 0; //16 bit address
    wire [11:0] rom_pixel;
    
    wire [5:0] blkcounter_x, blkcounter_y;
    wire [5:0] tilecounter_x, tilecounter_y;
 
    assign blkcounter_x = curr_x[5:0];
    assign blkcounter_y = curr_y + 10'd28; 
    
    assign tilecounter_x = curr_x >> 6;
    assign tilecounter_y = (curr_y-100) >> 6;
    
    always @ (posedge clk) begin
        if (!rst) begin
            bg_r <= 4'b0000;
            bg_g <= 4'b0000;
            bg_b <= 4'b0000;
        end else if (
        (curr_y >= `BORDER_TOP) && 
        (curr_y < (`RESOLUTION_Y-`BORDER_BTM))
        ) begin 
            //set rgb to sprite
            bg_r <= rom_pixel[11:8];
            bg_g <= rom_pixel[7:4];
            bg_b <= rom_pixel[3:0];
            
            addr <= blkcounter_x + (blkcounter_y * 64) + (tilecounter_x[3:0] * `MEM_OFFSET);
        end else begin
            bg_r <= `BORDER_R;
            bg_g <= `BORDER_G;
            bg_b <= `BORDER_B;
        end
    end
    
    assign draw_r = bg_r;
    assign draw_g = bg_g;
    assign draw_b = bg_b;
    
    blk_mem_gen_1 inst
    (
    .clka(clk),
    .addra(addr),
    .douta(rom_pixel)   
    );
    
endmodule
