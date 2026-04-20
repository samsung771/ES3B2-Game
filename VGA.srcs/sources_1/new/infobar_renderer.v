`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.04.2026 19:41:34
// Design Name: 
// Module Name: infobar_renderer
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

`define SMALL_SPRITE_OFFSET 1024
`define SMALL_SPRITE_SIZE 32

`define NUMBER_POS_X 1150
`define NUMBER_POS_Y 45
`define LIVES_POS_X 1108
`define LIVES_POS_Y 45

module infobar_renderer(
        input clk,
        input anim_clk,
        input rst,
        input [10:0] curr_x,
        input [10:0] curr_y,
        output [3:0] draw_r,
        output [3:0] draw_g,
        output [3:0] draw_b,
        input [3:0] lives

    );
    
    reg [17:0] bar_addr = 0; //18 bit address
    wire [11:0] bar_pixel;
    
    reg [13:0] num_addr = 0; 
    wire [11:0] num_pixel;
    
    reg [11:0] lives_addr = 0;
    wire [11:0] lives_pixel;
    
    blk_mem_gen_3 bar_sprite
    (
    .clka(clk),
    .addra(bar_addr),
    .douta(bar_pixel)   
    );
    
    blk_mem_gen_4 number_sprites
    (
    .clka(clk),
    .addra(num_addr),
    .douta(num_pixel)   
    );
    
    blk_mem_gen_5 live_sprites
    (
    .clka(clk),
    .addra(lives_addr),
    .douta(lives_pixel)   
    );
    
    
    
    reg [11:0] addrOffset = 0;
    always @ (posedge anim_clk) begin
        if (addrOffset < 3*`SMALL_SPRITE_OFFSET) 
            addrOffset <= addrOffset + `SMALL_SPRITE_OFFSET;
        else
            addrOffset <= 0;
    end  
    
    reg [3:0] fg_r, fg_g, fg_b;
    
    `define WITHIN_SPRITE(x,y) (             \
        curr_x >= x &&                       \
        curr_x <  x + `SMALL_SPRITE_SIZE &&  \
        curr_y >= y &&                       \
        curr_y <  y + `SMALL_SPRITE_SIZE     \
        )
    
    always @ (posedge clk) begin
        if (!rst) begin
            lives_addr <= 0;
            num_addr <= 0;
        end
        else if (`WITHIN_SPRITE(`LIVES_POS_X,`LIVES_POS_Y))begin
            //set rgb to sprite
            fg_r <= lives_pixel[11:8];
            fg_g <= lives_pixel[7:4];
            fg_b <= lives_pixel[3:0];
            
            if (curr_x == `LIVES_POS_X && curr_y == `LIVES_POS_Y)
                lives_addr <= addrOffset;
            
            else
                lives_addr <= lives_addr + 1;
        end
        else if (`WITHIN_SPRITE(`NUMBER_POS_X,`NUMBER_POS_Y))begin
            //set rgb to sprite
            fg_r <= num_pixel[11:8];
            fg_g <= num_pixel[7:4];
            fg_b <= num_pixel[3:0];
            
            if (curr_x == `NUMBER_POS_X && curr_y == `NUMBER_POS_Y)
                num_addr <= lives * `SMALL_SPRITE_OFFSET;
            
            else
                num_addr <= num_addr + 1;
        end
        else begin
            fg_r <= 0;
            fg_g <= 0;
            fg_b <= 0;
        end
    end    
        
            
            
            
    
    reg [3:0] bar_r, bar_g, bar_b;
    
    wire transparent = (fg_r != 0 || fg_g != 0 || fg_b != 0);
    
    assign draw_r = transparent ? fg_r : bar_r;
    assign draw_g = transparent ? fg_g : bar_g;
    assign draw_b = transparent ? fg_b : bar_b;
    
    //Draw inside border
    always @ (posedge clk) begin
        if (!rst)
            bar_addr <= 0;
        else if (curr_y <= `BORDER_TOP) begin
                //set rgb to sprite
                bar_r <= bar_pixel[11:8];
                bar_g <= bar_pixel[7:4];
                bar_b <= bar_pixel[3:0];
                
                bar_addr <= curr_x + (curr_y*`RESOLUTION_X) + 6;
                
        end else begin
            bar_r <= `BORDER_R;
            bar_g <= `BORDER_G;
            bar_b <= `BORDER_B;
        end
    end
endmodule
