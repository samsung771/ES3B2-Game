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
        input signed [7:0] z_accel,
        input signed [5:0] vel_x,
        input signed [5:0] vel_y,
        input [1:0] eventstate,
        output [1:0] movementstate,
        output signed [5:0] acc_x,
        output signed [5:0] acc_y
    );
    
    //Signed accelleration registers
    reg signed [5:0] acc_x_reg = 0;
    reg signed [5:0] acc_y_reg = `GRAVITY;
    
    //Output accellerations
    assign acc_x = acc_x_reg;
    assign acc_y = acc_y_reg;
    
    //Movement state for animations
    //0 = idle, 1 = right, 2 = left
    reg [1:0] state = 0;
    assign movementstate = state;
    
    // ------------------------------ Handle Inputs ------------------------------
    always @ (posedge clk)  begin
        //If player has not won or died
        if (eventstate == 0) begin
            //When LEFT button is pressed
            if (btn[2] && !btn[3]) begin
                //Acceleration is lower in if not standing on the ground
                acc_x_reg <= grounded ? -`X_ACCELERATION : -`X_AIR_ACCELERATION;
                
                //Update state
                state <= 2;
            end
            
            //When RIGHT button is pressed
            else if (btn[3] && !btn[2]) begin
                //Acceleration is lower in if not standing on the ground
                acc_x_reg <= grounded ? `X_ACCELERATION : `X_AIR_ACCELERATION;
                
                //Update state
                state <= 1;
            end
            
            //Add friction if on the ground and no buttons are pressed
            else if (grounded) begin
                //If moving accelerate in the opposite direction
                //Accelleration is -1/2 * velocity 
                if (vel_x < 1 || vel_x > 1)
                    acc_x_reg <= -1 * (vel_x >> 1);
                
                //Stop player if |vel_x| = 1
                //As (1 >> 1) = 0 therefore no friction
                else if (vel_x != 0)
                    acc_x_reg <= -1 * vel_x;
                    
                //If no buttons are pressed stop accellerating
                else
                    acc_x_reg <= 0;
                
                //Update state     
                state <= 0;
            end
            
            else
                acc_x_reg <= 0;
            
            //Jump when board is tilted up and player is standing
            if (z_accel > 20 && grounded)
                acc_y_reg <= -`JUMP_ACCELERATION;
            else //Else apply gravity
                acc_y_reg <= `GRAVITY;
        end
        //Else stop the player from moving
        else begin
            acc_x_reg <= -1 * vel_x;
            state <= 0;
        end
    end
    
endmodule
