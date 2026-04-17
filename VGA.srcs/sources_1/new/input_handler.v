`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.04.2026 11:30:57
// Design Name: 
// Module Name: input_handler
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

module input_handler(
        input clk,
        input grounded,
        input [4:0] btn,
        input signed [5:0] vel_x,
        input signed [5:0] vel_y,
        output signed [5:0] acc_x,
        output signed [5:0] acc_y
    );
    
    reg signed [5:0] acc_x_reg = 0;
    reg signed [5:0] acc_y_reg = `GRAVITY;
    
    assign acc_x = acc_x_reg;
    assign acc_y = acc_y_reg;
    
    
    // ------------------------------ Handle Inputs ------------------------------
    always @ (posedge clk)  begin
        //When LEFT button is pressed
        if (btn[2] && !btn[3]) begin
            //Acceleration is lower in if not standing on the ground
            acc_x_reg <= grounded ? -`X_ACCELERATION : -`X_AIR_ACCELERATION;
        end
        
        //When RIGHT button is pressed
        else if (btn[3] && !btn[2]) begin
            //Acceleration is lower in if not standing on the ground
            acc_x_reg <= grounded ? `X_ACCELERATION : `X_AIR_ACCELERATION;
        end
        
        //Add friction if on the ground and no buttons are pressed
        else if (grounded) begin
            //If moving accelerate in the opposite direction
            //Accelleration is 1/2 velocity 
            if (vel_x < 1 || vel_x > 1)
                acc_x_reg <= -1 * (vel_x >> 1);
            
            //Stop player if |vel_x| = 1
            //As (1 >> 1) = 0 therefore no friction
            else if (vel_x != 0)
                acc_x_reg <= -1 * vel_x;
                
            //If no buttons are pressed stop accellerating
            else
                acc_x_reg <= 0;
        end
        
        else
            acc_x_reg <= 0;
        
        //Jump when UP button is pressed and player is standing
        if (btn[1] && grounded)
            acc_y_reg <= -`JUMP_ACCELERATION;
        else
            acc_y_reg <= `GRAVITY;
    end
    
endmodule
