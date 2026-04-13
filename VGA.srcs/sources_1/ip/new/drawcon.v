`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.11.2022 16:50:09
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


module drawcon(
    input clk,
    input rst,
//
    input [10:0] blkpos_x,
    input [10:0] blkpos_y,    
    output [3:0] draw_r,
    output [3:0] draw_g,
    output [3:0] draw_b,
    input [10:0] curr_x,
    input [10:0] curr_y,
    input [10:0] idpos_x,
    input [10:0] idpos_y  
    );
    
reg [3:0] blk_r, blk_b, blk_g;
reg [3:0] bg_r, bg_g, bg_b;
reg [3:0] id_r,id_g,id_b;
//signals for image
parameter BLK_SIZE_X = 100, BLK_SIZE_Y = 100;
reg [13:0] addr;
wire [11:0] rom_pixel;

//signal for id
parameter BLK_SIZE_X2 = 400, BLK_SIZE_Y2 = 100;
reg [18:0] addr2;
wire [11:0] rom_pixel2;

// background colour
always@(posedge clk) begin
    if((curr_x < 11'd10) || (curr_x > 11'd400) || (curr_y < 11'd790) || (curr_y > 11'd890)) begin
        bg_r <= 4'b1111;
        bg_g <= 4'b1111;
        bg_b <= 4'b1111;
    end
    if((curr_x < 11'd400) || (curr_x > 11'd1430) || (curr_y < 11'd790) || (curr_y > 11'd890)) begin
        bg_r <= 4'b0000;
        bg_g <= 4'b0000;
        bg_b <= 4'b0000;
    end
//    if((curr_x < 11'd10) || (curr_x > 11'd1430) || (curr_y < 11'd0) || (curr_y > 11'd790)) begin
//        bg_r <= 4'b1111;
//        bg_g <= 4'b1111;
//        bg_b <= 4'b1111;
//    end
end

//image block
always@(posedge clk) begin    
    if (!rst) begin
        blk_r <= 4'b0000;
        blk_g <= 4'b0000;
        blk_b <= 4'b0000;
        addr <= 0;
    end
    else begin
        if((curr_x < blkpos_x) || (curr_x > blkpos_x+BLK_SIZE_X-1) ||
           (curr_y < blkpos_y) || (curr_y > blkpos_y+BLK_SIZE_Y-1)) begin
            blk_r <= 4'b0000;
            blk_g <= 4'b0000;
            blk_b <= 4'b0000;
        end
        else begin
            blk_r <= rom_pixel[11:8];
            blk_g <= rom_pixel[7:4];
            blk_b <= rom_pixel[3:0];
            if ((curr_x == blkpos_x) && (curr_y == blkpos_y) )
                addr <= 0;
            else 
                addr <= addr + 1;
        end
    end            
end
//ID
always@(posedge clk) begin   
    if((curr_x < idpos_x) || (curr_x > idpos_x+BLK_SIZE_X2-1) ||
       (curr_y < idpos_y) || (curr_y > idpos_y+BLK_SIZE_Y2-1)) begin
        id_r <= 4'b0000;
        id_g <= 4'b0000;
        id_b <= 4'b0000;
    end
    else begin
            id_r <= rom_pixel2[11:8]; 
            id_g <= rom_pixel2[7:4];  
            id_b <= rom_pixel2[3:0];  
        if ((curr_x == idpos_x) && (curr_y == idpos_y) )
            addr2 <= 0;
        else 
            addr2 <= addr2 + 1;
    end
        
end
assign draw_r = (id_r != 4'b0000)? id_r : ((blk_r != 4'b0000) ? blk_r : bg_r);
assign draw_g = (id_g != 4'b0000)? id_g : ((blk_g != 4'b0000) ? blk_g : bg_g);
assign draw_b = (id_b != 4'b0000)? id_b : ((blk_b != 4'b0000) ? blk_b : bg_b);
//instantiate
blk_mem_gen_0 inst    
(
.clka(clk),
.addra(addr),
.douta(rom_pixel)
);

blk_mem_gen_1 inst2    
(
.clka(clk),
.addra(addr2),
.douta(rom_pixel2)
);

endmodule
