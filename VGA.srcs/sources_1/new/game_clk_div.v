`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.04.2026 11:55:35
// Design Name: 
// Module Name: game_clk_div
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


module game_clk_div(
        input clk,
        output game_clk
    );
        
    reg[21:0] clk_div;
    reg game_clk_reg = 0; 
    
    assign game_clk = game_clk_reg;
    
    
    //30Hz clock divider  
    always @ (posedge clk)  begin
        if (clk_div == 22'd1666666) begin
            clk_div <= 0;
            game_clk_reg <= !game_clk_reg;
        end else 
            clk_div <= clk_div+1;
    end
    
endmodule
