`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.04.2026 12:02:36
// Design Name: 
// Module Name: collisionmap_clk_div
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


module collisionmap_clk_div(
        input clk,
        output collisionmap_clk
    );
    
    //Divider counter register
    reg [3:0] collisionclk_div = 0;
    
    //Output clock
    reg collisionclk = 0;
    assign collisionmap_clk = collisionclk;
    
    //Divide clk to ~5MHz
    //Doesn't have to be accurate just needs to allow for memory latency
    always @ (posedge clk) begin
        if (collisionclk_div == 10) begin
            collisionclk_div <= 0;
            collisionclk <= !collisionclk;
        end
        else begin
            collisionclk_div <= collisionclk_div +1;
                
        end
    end
endmodule
