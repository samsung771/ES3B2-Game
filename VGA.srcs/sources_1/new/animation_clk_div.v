`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.04.2026 19:15:24
// Design Name: 
// Module Name: animation_clk_div
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


module animation_clk_div(
        input clk,
        output anim_clk
    );
    
    //Divider counter register
    reg[23:0] clk_div = 0;
    
    //Output clock
    reg anim_clk_reg;
    assign anim_clk = anim_clk_reg;
    
    //5Hz clock divider
    always @ (posedge clk)  begin
        if (clk_div == 24'd10000000) begin
            clk_div <= 0;
            anim_clk_reg <= !anim_clk_reg;
        end else 
            clk_div <= clk_div+1;
    end
endmodule
