`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 03:26:18
// Design Name: 
// Module Name: enemy_renderer
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


module enemy_renderer(
        input clk,
        input anim_clk,
        input rst,
        input [10:0] curr_x,
        input [10:0] curr_y,
        input [15:0] cam_x,
        output [3:0] draw_r,
        output [3:0] draw_g,
        output [3:0] draw_b,
        input [15:0] pos_x,
        input [10:0] pos_y,
        input enemydirection
    );
    
    
    //Setup address inputs and pixel outputs
    reg [13:0] addr = 0;
    wire [11:0] rom_pixel;
    
    //Set up block memory instance
    blk_mem_gen_6 enemy_sprite (.clka(clk), .addra(addr), .douta(rom_pixel));
    
    //Offset for position within sprite
    reg [13:0] pixOffset = 0;
    
    //Colour registers
    reg [3:0] blk_r, blk_g, blk_b;
    
    //Convert global position to position on the screen
    wire [15:0] blkpos_x;
    assign blkpos_x = pos_x - cam_x;
    
    //Loop through memory offsets at each animation tick to move through each animation frame
    reg [13:0] animOffset = 0;
    always @ (posedge anim_clk) begin
        if (animOffset < `MEM_OFFSET) 
            animOffset <= animOffset + `MEM_OFFSET;
        else
            animOffset <= 0;
    end  
    
    always @ (posedge clk) begin
        if (
            (pos_x > cam_x) &&
            (pos_x + `BLK_SIZE < cam_x + `RESOLUTION_X) &&
            (curr_x >= blkpos_x) && 
            (curr_x < blkpos_x + `BLK_SIZE) &&
            (curr_y >= pos_y) && 
            (curr_y < pos_y + `BLK_SIZE)
            ) begin
                //set rgb to sprite
                blk_r <= rom_pixel[11:8];
                blk_g <= rom_pixel[7:4];
                blk_b <= rom_pixel[3:0];
                
                //Set position within sprite, +3 to account for memory latency
                pixOffset <= (curr_x-blkpos_x) + ((curr_y-pos_y)*`BLK_SIZE) + 3;
                
                //Address = pixel in sprite + animation frame
                //+ offset for the sprites direction
                addr <= pixOffset + animOffset + (enemydirection * 2 * `MEM_OFFSET);
        end
        else begin
            //Set foreground to 0 if not drawing a sprite
            //to allow for transparency
            blk_r <= 4'b0000;
            blk_g <= 4'b0000;
            blk_b <= 4'b0000;
        end
    end 
            
    //Output colour registers
    assign draw_r = blk_r;
    assign draw_g = blk_g;
    assign draw_b = blk_b;
                
endmodule
