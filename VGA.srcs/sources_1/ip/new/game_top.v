`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.11.2023 00:02:47
// Design Name: 
// Module Name: gametop
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


module gametop(input clk,
    input rst,
    input [2:0] sw,
    output [3:0] pix_r,
    output [3:0] pix_g,
    output [3:0] pix_b,
    output hsync,
    output vsync
    );

//internal wire
    wire pixclk;
    wire [3:0] pix_r_aux;
    wire [3:0] pix_g_aux;
    wire [3:0] pix_b_aux;
   reg [3:0] draw_r = 4'd0;
    reg [3:0] draw_g = 4'd0;
    reg [3:0] draw_b = 4'd0;  

    wire [10:0] curr_x;
    wire [10:0] curr_y;

    assign pix_r_aux = 4'b0100;
    assign pix_g_aux = 4'b0100;
    assign pix_b_aux = 4'b0100;

//clock generator
    clk_wiz_0 inst
  (
  // Clock out ports  
  .clk_out1(pixclk),
 // Clock in ports
  .clk_in1(clk)
  );
 always@*
    begin
        //box
        if((curr_x < 11'd1823) && (curr_x > 11'd384) && (curr_y < 11'd930) && (curr_y > 11'd830))
        begin
            draw_r <= pix_r_aux;
            draw_g <= pix_g_aux;
            draw_b <= pix_b_aux;    
        end else begin
        draw_r <= 4'b000;
        draw_g <= 4'b000;
        draw_b <= 4'b000;
        end
        end

vga vga_inst (
        .clk(pixclk),
        .rst(rst),
        .pix_r(pix_r),
        .pix_g(pix_g),
        .pix_b(pix_b),
        .hsync(hsync),
        .vsync(vsync),
        .draw_r(draw_r),
        .draw_g(draw_g),
        .draw_b(draw_b),
        .curr_x(curr_x),
        .curr_y(curr_y)   
    );

endmodule
