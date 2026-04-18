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

`define CAM_BOUND_RIGHT 900
`define CAM_BOUND_LEFT 300
`define CAM_BOUND_MAX 3170

module camera_controller(
        input clk,
        input rst,
        input[15:0] playerpos_x,
        input signed [5:0] vel_x,
        output [15:0] camerapos_x
    );
    
    reg [15:0] camerapos_x_reg = 0;
    
    assign camerapos_x = camerapos_x_reg;
    
    reg [5:0] dif_x = 0;
    
    always @ (posedge clk) begin
        if (!rst) 
            camerapos_x_reg <= 0;    
        else begin
            if (playerpos_x < camerapos_x_reg + `CAM_BOUND_LEFT) begin
                dif_x <= `CAM_BOUND_LEFT - playerpos_x;
                
                if (camerapos_x_reg <= vel_x)
                    camerapos_x_reg <= 0;
                
                else
                    camerapos_x_reg <= camerapos_x_reg - dif_x;
            end
            else if (playerpos_x > camerapos_x_reg + `CAM_BOUND_RIGHT) begin
                dif_x <=  playerpos_x - `CAM_BOUND_RIGHT;
                
                
                if (camerapos_x_reg + dif_x >= `CAM_BOUND_MAX)
                    camerapos_x_reg <= `CAM_BOUND_MAX;
                
                else
                    camerapos_x_reg <= camerapos_x_reg + dif_x;
            end
            else
                 dif_x <= 0;
        end 
    end
    
    /*
    always @ (posedge clk) begin
        if (!rst) 
            camerapos_x_reg <= 0;    
        else begin
            if (camerapos_x_reg <= vel_x)
                camerapos_x_reg <= 0;
            else if (camerapos_x_reg + vel_x >= `CAM_BOUND_MAX)
                camerapos_x_reg <= `CAM_BOUND_MAX;    
                
            else if (vel_x < 0)
                camerapos_x_reg <= camerapos_x_reg + vel_x - 64;
                
            else
                camerapos_x_reg <= camerapos_x_reg + vel_x;
            
        end 
    end
    */
endmodule
