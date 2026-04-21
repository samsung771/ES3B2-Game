`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.04.2026 00:01:45
// Design Name: 
// Module Name: accellerometer_controller
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


module accellerometer_controller(
    input clk,
    input ACL_MISO,
    output ACL_MOSI,
    output ACL_SCLK,
    output ACL_CSN,
    output signed [7:0] data_out
    );
    
    //CLK and MOSI setup
    wire spi_clk;
    reg MOSI = 0;
    
    //Read and write instruction codes
    reg [7:0] read = 8'h0B;
    reg [7:0] write = 8'h0A;
    
    //Z axis MSB address
    reg [7:0] z_addr =  8'h08;
    
    //Accellerometer configuration address
    reg [7:0] power_cfg =  8'h2D;
    //Set accel to measurement mode
    reg [7:0] device_start =  8'h02;
    
    
    //Output register
    reg signed [7:0] zdata = 0;
    assign data_out = zdata;
    
    //Counter for which bit to send
    reg [2:0] bit = 7;
    
    //SPI communication is broken into 8 bit sections
    //0: instruction e.g. read/write
    //1: register address
    //2: data to write or data read from address
    //other bits are a divider for polling as accel only samples in kHz
    reg [13:0] message_byte = 0;
    
    //Do once register to only write to config once
    reg do_once = 1;
    
    //CLK phase = 0
    //So send data on posedge
    always @ (posedge spi_clk) begin
        //Write to configuration address
        if(do_once) begin
        case (message_byte) 
            0: MOSI <= write[bit];
            1: MOSI <= power_cfg[bit];
            2: MOSI <= device_start[bit];
            default: MOSI <= 0;
        endcase
        //Once finished configuration, turn off do once
        if (message_byte == 2 && bit == 0)
           do_once <= 0; 
        end
        else begin
        //Set MOSI pin for read command
        case (message_byte) 
            0: MOSI <= read[bit];
            1: MOSI <= z_addr[bit];
            default: MOSI <= 0;
        endcase
        end
    end
    
    
    //CLK phase = 0
    //So read data on negedge
    always @ (negedge spi_clk) begin
        //If in reading
        if (message_byte == 2 && !do_once)
            zdata[bit] <= ACL_MISO;
    end
    
    always @ (negedge spi_clk) begin
        //MSB first so decrement each clk cycle
        if (bit != 0)
            bit <= bit -  1;
        else begin
            //Reset bit counter
            bit <= 7;
            
            //Increment message byte after each 8 bits
            message_byte <= message_byte + 1; 
        end 
    end
    
    //Set CLK to 0 outside message and chip select to 0 during message
    assign ACL_SCLK = (message_byte >= 0 && message_byte < 3) && spi_clk;
    assign ACL_CSN = !(message_byte >= 0 && message_byte < 3);
    assign ACL_MOSI = MOSI;
    
    //5MHz SPI clock
    clk_wiz_1 spi_clk_div ( 
    .clk_out1(spi_clk),
    .clk_in1(clk)
    );
    
endmodule
