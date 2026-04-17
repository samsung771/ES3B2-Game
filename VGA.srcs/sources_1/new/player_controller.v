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
    
    
    // ---------------------- Player Position Registers Setup ----------------------- 
    reg [10:0] pos_x = 300;
    reg [10:0] pos_y = 100;
    
    //Assign output wires to x and y registers
    assign playerpos_x = pos_x;
    //+100 to account for border
    assign playerpos_y = pos_y + 100;
  
    
    // ----------------------------- Level Memory Setup ----------------------------- 
    //Memory address for tiled level
    reg [9:0] level_addr = 0;
    //Tile ID from level memory
    wire [7:0] tile;
  
    //Level data memory block
    blk_mem_gen_2 level
    (
    .clka(clk),
    .addra(level_addr),
    .douta(tile)   
    );
    
    // ---------------------------- Collision Map Clock -----------------------------
    //Collision clock divider to account for memory latency
    reg [3:0] collisionclk_div = 0;
    reg collisionclk = 0;
    
    //Divide clk to 10MHz
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
    //2D array of collidable tiles on the screen
    reg collision_map [0:(`SCREEN_SIZE - 1)][0:(`LEVEL_HEIGHT - 1)];
    
    reg[6:0] xcounter = 0;
    reg[6:0] ycounter = 0;
    
    always @ (posedge collisionclk) begin
        //Set tile collisions
        //Tiles >= 11 are collidable 
        collision_map[xcounter][ycounter] <= (tile >= 8'd11);
        
        //Loop through X and Y positions
        if (xcounter == (`SCREEN_SIZE - 1)) begin
            ycounter <= (ycounter == (`LEVEL_HEIGHT-1)) ? 0 : ycounter + 1;
            xcounter <= 0;
        end
        else 
            xcounter <= xcounter +1;
       
        //Update memory address to get next tile
        level_addr <= xcounter + (ycounter * `LEVEL_SIZE)+1;
    end
    
    // ------------------------ Player Movement Variables ------------------------
    `define X_ACCELERATION 2
    `define X_AIR_ACCELERATION 1
    `define JUMP_ACCELERATION 25
    `define GRAVITY 2
    `define MAX_SPEED_X 16
    `define MAX_SPEED_Y 25
    
    
    reg signed [5:0] acc_x = 0;
    reg signed [5:0] acc_y = `GRAVITY;

    reg signed [5:0] vel_x = 0;
    reg signed [5:0] vel_y = 0;
    
    reg grounded = 0;
   
    // ------------------------------ Handle Inputs ------------------------------
    always @ (posedge clk)  begin
        
        //Check if standing on a collidable block
        grounded <= (
        collision_map[(pos_x) >> 6][(pos_y + `BLK_SIZE + 5) >> 6] || 
        collision_map[(pos_x+ `BLK_SIZE -1) >> 6][(pos_y + `BLK_SIZE + 5) >> 6]
        );
        
        //When LEFT button is pressed
        if (btn[2] && !btn[3]) begin
            //Acceleration is lower in if not standing on the ground
            acc_x <= grounded ? -`X_ACCELERATION : -`X_AIR_ACCELERATION;
        end
        
        //When RIGHT button is pressed
        else if (btn[3] && !btn[2]) begin
            //Acceleration is lower in if not standing on the ground
            acc_x <= grounded ? `X_ACCELERATION : `X_AIR_ACCELERATION;
        end
        
        //Add friction if on the ground and no buttons are pressed
        else if (grounded) begin
            //If moving accelerate in the opposite direction
            //Accelleration is 1/2 velocity 
            if (vel_x < 1 || vel_x > 1)
                acc_x <= -1 * (vel_x >> 1);
            
            //Stop player if |vel_x| = 1
            //As (1 >> 1) = 0 therefore no friction
            else if (vel_x != 0)
                acc_x <= -1 * vel_x;
                
            //If no buttons are pressed stop accellerating
            else
                acc_x <= 0;
        end
        
        else
            acc_x <= 0;
        
        //Jump when UP button is pressed and player is standing
        if (btn[1] && grounded)
            acc_y <= -`JUMP_ACCELERATION;
        else
            acc_y <= `GRAVITY;
    end
    
      
    // ----------------------------- Game Clock Divider ----------------------------- 
    
    //60Hz clock divider to update positions
    reg[21:0] clk_div;
    reg game_clk; 
    
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
    
    // --------------------------------- Update Y axis ---------------------------------
    always @ (posedge game_clk)  begin
        //If moving DOWN and next position overlaps with collidable block
        if (vel_y > 0 && (
        collision_map[(pos_x) >> 6][(pos_y + `BLK_SIZE + vel_y) >> 6] || 
        collision_map[(pos_x+ `BLK_SIZE -1) >> 6][(pos_y + `BLK_SIZE + vel_y) >> 6]
        )) begin
            //If player is going to collide, stop them 
            //and set their position to above the block
            vel_y <= 0;
            pos_y <= ((pos_y + vel_y) & 11'b11111000000) - 1;
        end
        
        //If moving UP and next position overlaps with collidable block
        else if (vel_y < 0 && (
        collision_map[(pos_x) >> 6][(pos_y + vel_y - 64) >> 6] || 
        collision_map[(pos_x+ `BLK_SIZE -1) >> 6][(pos_y + vel_y - 64) >> 6]
        )) begin
            //If player is going to collide, stop them 
            //and set their position to below the block
            vel_y <= 0;
            pos_y <= ((pos_y + vel_y - 64 + `BLK_SIZE) & 11'b11111000000) + 1;
        end
        
        //If not colliding in Y, update position and velocity
        else begin
            //Only add accelleration if it doesnt go over speed cap
            if (
            vel_y + acc_y <= `MAX_SPEED_Y && 
            vel_y + acc_y >= -`MAX_SPEED_Y
            )
                vel_y <= vel_y + acc_y;
           
            //Update position
            if (vel_y < 0)
                //-64 to convert from 2s complement signed to unsigned
                pos_y <= pos_y + vel_y - 64;
            else 
                pos_y <= pos_y + vel_y;
        end
    end
    
    
    
    // --------------------------------- Update X axis ---------------------------------
    always @ (posedge game_clk)  begin
        //If off screen reset to 1
        if (pos_x > 1500) begin
            vel_x <= 0;
            pos_x <= 1;
        end
        else begin
            //If moving LEFT and next position overlaps with collidable block
            if (vel_x < 0 && (
            collision_map[(pos_x + vel_x - 64) >> 6][(pos_y) >> 6] || 
            collision_map[(pos_x + vel_x - 64) >> 6][(pos_y + `BLK_SIZE - 1) >> 6]
            )) begin
                //If player is going to collide, stop them 
                //and set their position to the right of the block
                vel_x <= 0;
                pos_x <= ((pos_x + vel_x - 64 + `BLK_SIZE) & 11'b11111000000) + 1;
            end
            
            //If moving RIGHT and next position overlaps with collidable block
            else if (vel_x > 0 && (
            collision_map[(pos_x + `BLK_SIZE + vel_x) >> 6][(pos_y) >> 6] || 
            collision_map[(pos_x + `BLK_SIZE + vel_x) >> 6][(pos_y + `BLK_SIZE - 1) >> 6]
            )) begin
                //If player is going to collide, stop them 
                //and set their position to the left of the block
                vel_x <= 0;
                pos_x <= ((pos_x + vel_x) & 11'b11111000000) - 1;
            end
            
            //If not colliding in X, update position and velocity
            else begin
                //Only add accelleration if it doesnt go over speed cap
                if (
                vel_x + acc_x <= `MAX_SPEED_X && 
                vel_x + acc_x >= -`MAX_SPEED_X
                )
                    vel_x <= vel_x + acc_x;
                
                //Update position
                if (vel_x < 0)
                    //-64 to convert from 2s complement signed to unsigned
                    pos_x <= pos_x + vel_x - 64; 
                else 
                    pos_x <= pos_x + vel_x;
            end
        end
    end
    
    
endmodule
