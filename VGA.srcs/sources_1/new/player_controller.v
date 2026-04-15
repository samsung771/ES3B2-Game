`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.04.2026 16:59:04
// Design Name: 
// Module Name: player_controller
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

module player_controller(
    input clk,
    input rst,
    input [4:0] btn,
    output [10:0] playerpos_x,
    output [10:0] playerpos_y
    );
    
    
    reg [10:0] pos_x = 300;
    reg [10:0] pos_y = 100;
    
    assign playerpos_x = pos_x;
    assign playerpos_y = pos_y + 100;
    
    
    reg[21:0] clk_div;
    reg game_clk;
    //60Hz clock div
    always @ (posedge clk)  begin
        if(!rst)
            clk_div <= 0;
        else begin
            if (clk_div == 22'd1666666) begin
                clk_div <= 0;
                game_clk <= !game_clk;
            end else 
                clk_div <= clk_div+1;
        end
    end
     
    
    
    // ----------------------------- Level Memory Setup ----------------------------- 
    //Memory address for tiled level
    reg [8:0] level_addr = 0;
    //Tile ID from level memory
    wire [7:0] tile;
  
    //Level data memory block
    blk_mem_gen_2 level
    (
    .clka(clk),
    .addra(level_addr),
    .douta(tile)   
    );
    
    
    
    // -------------------------- Collision Raycast setup ---------------------------
    `define RAY_SIZE 20
    
    //Rays from each corner
    wire [5:0] up_ray_x [0:1];
    wire [5:0] up_ray_y;
    assign up_ray_x[0] = (pos_x) >> 6;
    assign up_ray_x[1] = (pos_x + `BLK_SIZE - 1) >> 6;
    assign up_ray_y = (pos_y - `RAY_SIZE) >> 6;
  
    wire [5:0] down_ray_x [0:1];
    wire [5:0] down_ray_y;
    assign down_ray_x[0] = (pos_x) >> 6;
    assign down_ray_x[1] = (pos_x + `BLK_SIZE - 1) >> 6;
    assign down_ray_y = (pos_y + `BLK_SIZE - 1 + `RAY_SIZE) >> 6;
    
    wire [5:0] left_ray_x;
    wire [5:0] left_ray_y [0:1];
    assign left_ray_x = (pos_x - `RAY_SIZE) >> 6;
    assign left_ray_y[0] = (pos_y) >> 6;
    assign left_ray_y[1] = (pos_y + `BLK_SIZE - 1) >> 6;
    
    wire [5:0] right_ray_x;
    wire [5:0] right_ray_y [0:1];
    assign right_ray_x = (pos_x + `BLK_SIZE - 1 + `RAY_SIZE) >> 6;
    assign right_ray_y[0] = (pos_y) >> 6;
    assign right_ray_y[1] = (pos_y + `BLK_SIZE - 1) >> 6;
    
    
    reg[6:0] xcounter = 0;
    reg[6:0] ycounter = 0;
    
    
    reg [3:0] collisionclk_div = 0;
    reg collisionclk = 0;
    reg [2:0] corner = 0;
    
    // Collision clk divider
    always @ (posedge clk) begin
        if(!rst)
            collisionclk <= 0;
        else begin
            if (collisionclk_div == 10) begin
                collisionclk_div <= 0;
                collisionclk <= !collisionclk;
            end
            else
                collisionclk_div <= collisionclk_div +1;
        end
    end
    
    // ---------------------------- Update Collision Map -----------------------------
    
    reg collision_map [0:(`LEVEL_SIZE - 1)][0:(`LEVEL_HEIGHT - 1)];
    
    always @ (posedge collisionclk) begin
        collision_map[xcounter][ycounter] <= (tile >= 8'd11);
        
        if (xcounter == (`LEVEL_SIZE - 1)) begin
            ycounter <= (ycounter == (`LEVEL_HEIGHT-1)) ? 0 : ycounter + 1;
            xcounter <= 0;
        end
        else 
            xcounter <= xcounter +1;
       
        level_addr <= xcounter + (ycounter * `LEVEL_SIZE)+1;
    end
    // ----------------------------- Check Collisions -----------------------------   
    reg collision_u,collision_d,collision_l,collision_r;
   
    
    always @ (posedge collisionclk)  begin
        //Collisions Down
        collision_d <= (
            collision_map[down_ray_x[0]][down_ray_y] || 
            collision_map[down_ray_x[1]][down_ray_y]
        );
            
        //Collisions Up
        collision_u <= (
            collision_map[up_ray_x[0]][up_ray_y] || 
            collision_map[up_ray_x[1]][up_ray_y]
        );
        
        //Collisions Left
        collision_l <= (
            collision_map[left_ray_x][left_ray_y[0]] || 
            collision_map[left_ray_x][left_ray_y[1]]
        );
        
        //Collisions Right
        collision_r <= (
            collision_map[right_ray_x][right_ray_y[0]] || 
            collision_map[right_ray_x][right_ray_y[1]]
        );
   end
     
    // ------------------------------ Update positions ------------------------------
  
    reg signed [5:0] acc_x = 0;
    reg signed [5:0] acc_y = 2;

    reg signed [5:0] vel_x = 0;
    reg signed [5:0] vel_y = 0;
    
    always @ (posedge game_clk)  begin
        
        if (btn[0]) begin 
            pos_x <= 300;
            pos_y <= 100;
            vel_x <= 0;
            vel_y <= 0;
            acc_x <= 0;
        end 
        else if (pos_x <= 5) begin
            vel_x <= 0;
            acc_x <= 0;
            pos_x <= 6;
        end
        else begin
            if (collision_d) begin
                if (btn[1]) begin
                    vel_y <= -25;
                    pos_y <= pos_y - 15;
                end            
                else begin
                    vel_y <= 0;
                    pos_y <= (down_ray_y << 6) - `BLK_SIZE;
                end
            end
            else if (collision_u) begin
                vel_y <= 0;
                pos_y <= (up_ray_y << 6) + vel_y + 5;
            end
            else begin
                if (vel_y <= 15 && vel_y >= -30)
                    vel_y <= vel_y + acc_y;
                if (vel_y < 0)
                    pos_y <= pos_y + vel_y - 64;
                else
                    pos_y <= pos_y + vel_y;
            end
            
            
            if (collision_l) begin
                vel_x <= 0;
                pos_x <= (left_ray_x << 6) - 5;
            end
            else if (collision_r) begin
                vel_x <= 0;
                pos_x <= (right_ray_x << 6) - `BLK_SIZE + 5;
            end
            else begin
                if (vel_x < 0)
                    pos_x <= pos_x + vel_x - 64;
                else
                    pos_x <= pos_x + vel_x;
            end
           
           if (btn[2] && !btn[3]) begin
                if (vel_x <= 12 && vel_x >= -12)
                    acc_x <= -2;
                else
                    acc_x <= 0;
                
                vel_x <= vel_x + acc_x; 
            end
        
        
            else if (btn[3]) begin
                if (vel_x <= 12 && vel_x >= -12)
                    acc_x <= 2;
                else
                    acc_x <= 0;
        
                vel_x <= vel_x + acc_x; 
            end
            
            else begin
                if (vel_x <= -2) begin
                    acc_x <= 2;
                    vel_x <= vel_x + acc_x; 
                end
                
                else if (vel_x >= 2) begin
                    acc_x <= -2;
                    vel_x <= vel_x + acc_x; 
                end
                
                else begin
                    acc_x <= 0;
                    vel_x <= 0;
                end
            end
       
        /*
            case (btn[4:1]) 
            `LBTN:
                if (!collision_l)
                    pos_x <= pos_x -10;
            `RBTN:
                if (!collision_r)
                    pos_x <= pos_x +10;
            `UBTN:
                if (!collision_u)
                    pos_y <= pos_y - 10;
            `DBTN: 
                if (!collision_d)
                    pos_y <= pos_y + 10;
            endcase
            */
        end 
    end
    
    
endmodule
