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
    
    
    // ------------------------- Player Movement Variables -------------------------
    reg [10:0] pos_x = 300;
    reg [10:0] pos_y = 100;
    
    //Assign output wires to x and y registers
    assign playerpos_x = pos_x;
    //+100 to account for border
    assign playerpos_y = pos_y + 100;
    
    wire signed [5:0] acc_x;
    wire signed [5:0] acc_y;
    
    reg signed [5:0] vel_x = 0;
    reg signed [5:0] vel_y = 0;
    
    
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
    
    
    // ---------------------------- Update Collision Map -----------------------------
    //2D array of collidable tiles on the screen
    reg collision_map [0:(`SCREEN_SIZE - 1)][0:(`LEVEL_HEIGHT - 1)];
    
    reg[6:0] xcounter = 0;
    reg[6:0] ycounter = 0;
    
    //Update tile address
    always @ (posedge clk) begin
        level_addr <= xcounter + (ycounter * `LEVEL_SIZE);
    end
    
    //Collision clock divider to account for memory latency
    wire collisionmap_clk;
    
    collisionmap_clk_div (
        .clk(clk),
        .collisionmap_clk(collisionmap_clk)
    );
    
    //Update collision map
    always @ (posedge collisionmap_clk) begin
        if(!rst) begin
            xcounter <= 0;
            ycounter <= 0;
        end            
        else begin
            //Set tile collisions
            //Tiles >= 11 are collidable 
            collision_map[xcounter][ycounter] <= (tile >= 8'd11);
            
            //Loop through X and Y positions
            if (xcounter == (`SCREEN_SIZE - 1)) begin
                xcounter <= 0;
                
                if (ycounter == `LEVEL_HEIGHT-1) 
                    ycounter <= 0;
                else
                    ycounter <= ycounter + 1;
            end
            else 
                xcounter <= xcounter + 1 ;
           
        end
    end
    
   
    
    // ------------------------------ Get Player Input ------------------------------
    reg grounded = 0;
    
    //Check if standing on a collidable block
    always @ (posedge clk)  begin
        if(!rst) 
            grounded <= 0;
        else
            grounded <= (
                collision_map[(pos_x) >> 6][(pos_y + `BLK_SIZE + 5) >> 6] || 
                collision_map[(pos_x+ `BLK_SIZE -1) >> 6][(pos_y + `BLK_SIZE + 5) >> 6]
            );
    end
    
    
    //Process button inputs and return accelleration
    input_handler input_handler_inst (
        .clk(clk),
        .grounded(grounded),
        .btn(btn),
        .vel_x(vel_x),
        .vel_y(vel_y),
        .acc_x(acc_x),
        .acc_y(acc_y)
    );
    
      
    //60Hz game clock for position updates
    wire game_clk;
    
    game_clk_div (
    .clk(clk),
    .game_clk(game_clk)
    );
    
    // --------------------------------- Update Y axis ---------------------------------
    always @ (posedge game_clk)  begin
        /*
        // ------------------------ CHECK SCREEN BOUNDARIES ------------------------
        //If pos_y overflows so off screen left reset to 1
        if (vel_y > 0 && (pos_y + vel_y) > 1600) begin 
            vel_x <= 0;
            pos_x <= 1;
        end
        */
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
        // ------------------------ CHECK SCREEN BOUNDARIES ------------------------
        //If pos_x overflows so off screen left reset to 1
        if (vel_x < 0 && (pos_x + vel_x - 64) > 1600) begin 
            vel_x <= 0;
            pos_x <= 1;
        end
        
        //If pos_x off screen stop
        else if (pos_x + `BLK_SIZE > `RESOLUTION_X) begin
            vel_x <= 0;
            pos_x <= `RESOLUTION_X - `BLK_SIZE - 1;
        end
        
        
        // --------------------------- CHECK COLLISIONS ---------------------------
        //If moving LEFT and next position overlaps with collidable block
        else if (vel_x < 0 && (
        collision_map[(pos_x + vel_x - 64) >> 6][(pos_y) >> 6] || 
        collision_map[(pos_x + vel_x - 64) >> 6][(pos_y + `BLK_SIZE - 1) >> 6]
        )) begin
            //If player is going to collide, stop them 
            vel_x <= 0;
            //Set their position to the right of the block that player collided with
            //Position is & 11'b11111000000 to find block edge
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
        
        
        // -------------------------- UPDATE VELOCITIES --------------------------
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
    
    
endmodule
