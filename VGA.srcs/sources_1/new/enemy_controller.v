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
#(ENEMYBOUND_RIGHT=0, ENEMYBOUND_LEFT=0, ENEMYPOS_Y=0)
(
        input clk,
        input game_clk,
        input rst,
        output [15:0] enemypos_x,
        output [10:0] enemypos_y,
        output direction
    );
    `define ENEMYBOUND_LEFT 3650
    `define ENEMYBOUND_RIGHT 3900
    `define ENEMYPOS_Y 668
    
    reg [15:0] pos_x = ENEMYBOUND_RIGHT;
    reg [10:0] pos_y = ENEMYPOS_Y;
    
    assign enemypos_x = pos_x;
    assign enemypos_y = pos_y;
    
    reg dir = 0;
    assign direction = dir;
    
    always @ (posedge game_clk) begin
        if (!rst) 
            pos_x <= ENEMYBOUND_LEFT;
        else begin
            if (dir) begin
                if (pos_x >= ENEMYBOUND_RIGHT)
                    dir <= 0;
                else
                    pos_x <= pos_x + 5;
            end
            else begin
                if (pos_x <= ENEMYBOUND_LEFT)
                    dir <= 1;
                else
                    pos_x <= pos_x - 5;
            end
        end
    end
endmodule
