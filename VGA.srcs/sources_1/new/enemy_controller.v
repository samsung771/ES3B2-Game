`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 03:24:37
// Design Name: 
// Module Name: enemy_controller
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


module enemy_controller
#(ENEMYBOUND_RIGHT=0, ENEMYBOUND_LEFT=0, ENEMYPOS_Y=0) //Enemy parameters so module is reusable
(
        input clk,
        input game_clk,
        input rst,
        output [15:0] enemypos_x,
        output [10:0] enemypos_y,
        output direction
    );
    
    //Enemy position registers, x is global
    reg [15:0] pos_x = ENEMYBOUND_RIGHT;
    reg [10:0] pos_y = ENEMYPOS_Y;
    
    //Output x and y positions
    assign enemypos_x = pos_x;
    assign enemypos_y = pos_y;
    
    //Enemy movement direction for animations
    reg dir = 0;
    assign direction = dir;
    
    //Every game tick
    always @ (posedge game_clk) begin
        if (!rst) //Reset position
            pos_x <= ENEMYBOUND_LEFT;
        else begin
            //When moving left
            if (dir) begin
                //If hits boundary change direction
                if (pos_x >= ENEMYBOUND_RIGHT)
                    dir <= 0;
                //Else keep moving
                else
                    pos_x <= pos_x + 5;
            end
            //When moving right
            else begin
                //If hits boundary change direction
                if (pos_x <= ENEMYBOUND_LEFT)
                    dir <= 1;
                //Else keep moving
                else
                    pos_x <= pos_x - 5;
            end
        end
    end
endmodule
