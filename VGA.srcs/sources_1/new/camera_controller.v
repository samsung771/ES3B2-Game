`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.04.2026 18:38:10
// Design Name: 
// Module Name: camera_controller
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

module camera_controller(
        input clk,
        input rst,
        input[15:0] playerpos_x,
        output [15:0] camerapos_x
    );
    
    //Output camera register 
    reg [15:0] camerapos_x_reg = 0;
    assign camerapos_x = camerapos_x_reg;
    
    always @ (posedge clk) begin
        if (!rst) 
            camerapos_x_reg <= 0;    
        else begin
            //Stop cam from going past the left edge of the level
            if (playerpos_x < `CAM_BOUND)
                camerapos_x_reg <= 0;
            
            //Stop cam from going past the right edge of the level        
            else if (playerpos_x - `CAM_BOUND >= `CAM_BOUND_MAX)
                camerapos_x_reg <= `CAM_BOUND_MAX;
            
            //Else update to put player ~central
            else
                camerapos_x_reg <= playerpos_x - `CAM_BOUND; 
        end 
    end
endmodule
