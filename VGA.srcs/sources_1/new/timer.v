`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2026 20:54:25
// Design Name: 
// Module Name: timer
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


module timer(
    input clk,
    input rst,
    input [1:0] eventstate,
    output [6:0] seg,
    output [7:0] an
    );
    
  
    //7 segment output
    reg [6:0] seg_reg;
    assign seg = seg_reg;
    
    //Array of digits between 0-9
    reg [3:0] timer_digits [0:3];
    //Counter in seconds
    reg [11:0] counter = 0;
    
    //Digit to write to 
    reg [3:0] digit = 0;
    
    //Set digit being written in 7 seg display
    assign an = ~(1 << digit);
   
    //1Hz clock divider
    reg[26:0] clk_div;
    always @ (posedge clk)  begin
        if (!rst)
            counter <= 0;
        else if (clk_div == 27'd100000000) begin //every 1s
            clk_div <= 0;
            //If player hasnt won
            if (eventstate != 2) begin
                counter <= counter + 1;
                
                //Convert counter to each decimal digit
                timer_digits[0] <= counter % 10;
                timer_digits[1] <= (counter / 10) % 10;
                timer_digits[2] <= (counter / 100) % 10;
                timer_digits[3] <= (counter / 1000) % 10;
            end
        end else 
            clk_div <= clk_div+1;
    end
    
    
    //Divider to pulse through each digit
    reg [11:0] divider = 0;
    always@ (posedge clk) 
        divider <= divider + 1; //Frequency doesn't have to be anything specific so just overflow at 12 bits
    
    always@ (posedge clk) begin
        if (divider == 0) begin
            if (digit == 3)
                digit <= 0;
            else
                digit <= digit + 1;
        end
    end
    
    //Display digit on 7 seg display
    always@ (posedge clk) begin
        case(timer_digits[digit])
            0: seg_reg = 7'b1000000;
            1: seg_reg = 7'b1111001;
            2: seg_reg = 7'b0100100;
            3: seg_reg = 7'b0110000;
            4: seg_reg = 7'b0011001;
            5: seg_reg = 7'b0010010;
            6: seg_reg = 7'b0000010;
            7: seg_reg = 7'b1111000;
            8: seg_reg = 7'b0000000;
            9: seg_reg = 7'b0010000;
        endcase
    end
    
endmodule
