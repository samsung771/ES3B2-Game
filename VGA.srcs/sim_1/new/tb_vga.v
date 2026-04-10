`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.03.2026 03:17:16
// Design Name: 
// Module Name: tb_vga
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


module tb_vga();

    reg clk;
    reg rst;
    reg [2:0] sw;
    
    wire [3:0] pix_r;
    wire [3:0] pix_g;
    wire [3:0] pix_b;
    
    wire hsync;
    wire vsync;
    
    
    
    initial begin
        #1
        clk = 0;
        sw = 3'b000;
    end
    
    always begin
        #1 clk = ~clk;
    end
    
    vga_out vga_inst( 
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .pix_r(pix_r),
        .pix_g(pix_g),
        .pix_b(pix_b),
        .hsync(hsync),
        .vsync(vsync)
    );
endmodule
