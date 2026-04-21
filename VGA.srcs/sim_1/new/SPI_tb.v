`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.04.2026 01:11:52
// Design Name: 
// Module Name: SPI_tb
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


module SPI_tb();
    reg clk;
    reg ACL_MISO;
    wire [15:0] data_out;
    wire ACL_MOSI;
    wire ACL_SCLK;
    wire ACL_CSN;
    
    initial begin
        #1
        clk <= 0;
        ACL_MISO <= 0;
        end
        
    always @*
       #1clk <= !clk;
        
    
    accellerometer_controller accellerometer_inst (
        .clk(clk),
        .ACL_MISO(ACL_MISO),
        .ACL_MOSI(ACL_MOSI),
        .ACL_SCLK(ACL_SCLK),
        .ACL_CSN(ACL_CSN),
        .data_out(data_out)
    );
endmodule
