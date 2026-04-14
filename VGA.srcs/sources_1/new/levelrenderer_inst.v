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
    // ---------------------------- Colour Register Setup ----------------------------
    //Colour registers to draw to
    reg [3:0] bg_r, bg_g, bg_b;
    
    //Assign local registers to outputs
    assign draw_r = bg_r;
    assign draw_g = bg_g;
    assign draw_b = bg_b;
 
    // ----------------------------- Sprite Memory Setup -----------------------------    
    //Memory address for tile sprites
    reg [15:0] sprite_addr = 0; 
    //Offset for the tile sprite in memory
    reg [15:0] tile_offset = 0;
    //Pixel address within the tile
    reg [15:0] pix_offset = 0;
    
    //Pixel data from sprite memory
    wire [11:0] rom_pixel;
    
    //Tile sprites memory block
    blk_mem_gen_1 tilemap
    (
    .clka(clk),
    .addra(sprite_addr),
    .douta(rom_pixel)   
    );
    
    // ----------------------------- Level Memory Setup ----------------------------- 
    //Memory address for tiled level
    reg [8:0] level_addr = 0;
    //Tile ID from level memory
    wire [7:0] tile;
  
    //Level data memory block
    blk_mem_gen_2 level
    (
    .clka(clk),
    .addra(level_addr),
    .douta(tile)   
    );
    
    // ------------------------------- Tile Counters ------------------------------- 
    //X and Y positions within the tile
    wire [5:0] pixcounter_x, pixcounter_y;
    
    //Counters are truncated to 6 bits as a quick MOD 64
    // +3 offset to account for memory latency
    assign pixcounter_x = curr_x + 3;
    // +28 offset to line up with top border
    assign pixcounter_y = curr_y + 11'd28; 
    
    //Tile X and Y positions 
    wire [5:0] tilecounter_x, tilecounter_y;
    
    //Counters are bitshifted right by 6 as quick DIV 64
    // +6 offset to account for combined memory latency
    assign tilecounter_x = (curr_x+6) >> 6;
    // -100 offset to line up with top border
    assign tilecounter_y = (curr_y-100) >> 6;
     
    
    // ------------------------------ Drawing Block ------------------------------ 
    always @ (posedge clk) begin
        if (!rst) begin
            bg_r <= 4'b0000;
            bg_g <= 4'b0000;
            bg_b <= 4'b0000;
        end 
        //If within level space
        else if (
        (curr_y >= `BORDER_TOP) && 
        (curr_y < (`RESOLUTION_Y-`BORDER_BTM))
        ) begin
            //Update address registers
            //Level address from tile X and Y positions
            level_addr <= tilecounter_x + (tilecounter_y * `LEVEL_SIZE);
            
            //Pixel offset from X and Y position within tile
            pix_offset <= pixcounter_x + (pixcounter_y * `BLK_SIZE);
            //Tile offset from tile ID * size of tile in memory
            tile_offset <= tile * `MEM_OFFSET;
            
            //Update sprite address
            sprite_addr <= pix_offset + tile_offset;
            
            //Set draw registers to sprite colours
            bg_r <= rom_pixel[11:8];
            bg_g <= rom_pixel[7:4];
            bg_b <= rom_pixel[3:0];
            
        end 
        //Else draw border
        else begin
            bg_r <= `BORDER_R;
            bg_g <= `BORDER_G;
            bg_b <= `BORDER_B;
        end
    end
endmodule
