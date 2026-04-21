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

`define WINMSG_WIDTH 440
`define WINMSG_HEIGHT 203
`define WINMSG_POS_X 480
`define WINMSG_POS_Y 200

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
        input [1:0] playerstate,
        input [1:0] eventstate
    );
    
    //Setup address inputs and pixel outputs for player sprite
    reg [15:0] addr = 0;
    wire [11:0] rom_pixel;
    
    //Set up block memory instance
    blk_mem_gen_0 player_sprites(.clka(clk), .addra(addr), .douta(rom_pixel));
    
    //Setup address inputs and pixel outputs for win message sprite
    reg [16:0] winmsg_addr = 0; 
    wire [11:0]  winmsg_pixel;
    
    //Set up block memory instance
    win_message_mem win_msg_sprite (.clka(clk), .addra(winmsg_addr), .douta(winmsg_pixel));
    
    
    //Colour registers
    reg [3:0] blk_r, blk_g, blk_b;
    
    //Convert global position to position on the screen
    wire [0:10] blkpos_x;
    assign blkpos_x = playerpos_x - cam_x;
    

    //Loop through memory offsets at each animation tick to move through each animation frame
    reg [15:0] addrOffset = 0;
    always @ (posedge anim_clk) begin
        if (addrOffset < 3*`MEM_OFFSET) 
            addrOffset <= addrOffset + `MEM_OFFSET;
        else
            addrOffset <= 0;
    end  
    
    always @ (posedge clk) begin
        if ( 
            (curr_x >= blkpos_x) &&                 //Draw when within sprite bounds
            (curr_x < blkpos_x + `BLK_SIZE) &&
            (curr_y >= playerpos_y) && 
            (curr_y < playerpos_y + `BLK_SIZE) &&
            (curr_y > `BORDER_TOP) &&               //And player is within play space
            (curr_y < `RESOLUTION_Y - `BORDER_BTM)
            ) begin
                //set rgb to sprite
                blk_r <= rom_pixel[11:8];
                blk_g <= rom_pixel[7:4];
                blk_b <= rom_pixel[3:0];
                
                //set address to 0 at start of sprite
                if ((curr_x == blkpos_x) && (curr_y == playerpos_y))
                    addr <= addrOffset + (playerstate * 16'd16384);
                //else increment
                else
                    addr <= addr + 1;
                
        end else if (
        eventstate == 2 &&                          //If player has won
        curr_x >= `WINMSG_POS_X &&                  //And within message sprite
        curr_x < `WINMSG_POS_X + `WINMSG_WIDTH &&
        curr_y >= `WINMSG_POS_Y &&
        curr_y < `WINMSG_POS_Y + `WINMSG_HEIGHT
        ) begin
                //set rgb to sprite
                blk_r <= winmsg_pixel[11:8];
                blk_g <= winmsg_pixel[7:4];
                blk_b <= winmsg_pixel[3:0];
                
                //set address to 0 at start of sprite
                if ((curr_x == `WINMSG_POS_X) && (curr_y == `WINMSG_POS_Y))
                    winmsg_addr <= 0;
                //else increment
                else
                    winmsg_addr <= winmsg_addr + 1;
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
