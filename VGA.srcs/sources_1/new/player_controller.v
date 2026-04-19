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
    input game_clk,
    input rst,
    input [4:0] btn,
    input [15:0] cam_x,
    output [10:0] playerpos_x,
    output [10:0] playerpos_y,
    output [15:0] globalpos,
    output [1:0] movestate,
    output [1:0] playerstate
    );
    
    
    // ------------------------- Player Movement Variables -------------------------
    reg [12:0] global_pos_x = 300;
    reg [10:0] pos_y = 100;
    
    //Assign output wires to x and y registers
    //Output players position on the screen
    assign playerpos_x = global_pos_x - cam_x;
    //+100 to account for border
    assign playerpos_y = pos_y + 100;
    
    assign globalpos = global_pos_x;
    
    wire signed [5:0] acc_x;
    wire signed [5:0] acc_y;
    
    reg signed [5:0] vel_x = 0;
    reg signed [5:0] vel_y = 0;
    
    //Animation state
    wire [1:0] movementstate;
    assign movestate = movementstate;
    
    //Player state - dead or finised level
    reg [1:0] eventstate = 0;
    assign playerstate = eventstate;
    
    
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
    reg collision_map [0:(`LEVEL_SIZE-1)][0:(`LEVEL_HEIGHT-1)];
    
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
            if (xcounter == (`LEVEL_SIZE - 1)) begin
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
        if(!rst) begin
            grounded <= 0;
            eventstate <= 0;
        end
        else begin
            grounded <= (
                collision_map[(global_pos_x) >> 6][(pos_y + `BLK_SIZE + 5) >> 6] || 
                collision_map[(global_pos_x + `BLK_SIZE -1) >> 6][(pos_y + `BLK_SIZE + 5) >> 6]
            );
            
            if (pos_y > 750 && pos_y < 1800) 
                eventstate <= 4;
            else if (global_pos_x > 4400)
                eventstate <= 5;
            else 
                eventstate <= 0;
        end
    end
    
    
    //Process button inputs and return accelleration
    input_handler input_handler_inst (
        .clk(clk),
        .grounded(grounded),
        .btn(btn),
        .vel_x(vel_x),
        .vel_y(vel_y),
        .eventstate(eventstate),
        .movementstate(movementstate),
        .acc_x(acc_x),
        .acc_y(acc_y)
    );
    
    reg [3:0] resetcounter = 0;
      
    // --------------------------------- Update Y axis ---------------------------------
    always @ (posedge game_clk)  begin
        if(!rst) 
            pos_y <= 100;
        else begin
        if ( resetcounter == 15 && eventstate == 4) 
            pos_y <= 100;
            
        else if (vel_y < 0 && pos_y + vel_y - 64 > 1500) begin
            vel_y <= `GRAVITY;
            pos_y <= 1;
        end
        
        // --------------------------- CHECK COLLISIONS ---------------------------
        //If moving DOWN and next position overlaps with collidable block
        else if (vel_y > 0 && (
        collision_map[(global_pos_x) >> 6][(pos_y + `BLK_SIZE + vel_y) >> 6] || 
        collision_map[(global_pos_x+ `BLK_SIZE -1) >> 6][(pos_y + `BLK_SIZE + vel_y) >> 6]
        )) begin
            //If player is going to collide, stop them 
            //and set their position to above the block
            vel_y <= 0;
            pos_y <= ((pos_y + vel_y) & 11'b11111000000) - 1;
        end
        
        //If moving UP and next position overlaps with collidable block
        else if (vel_y < 0 && (
        collision_map[(global_pos_x) >> 6][(pos_y + vel_y - 64) >> 6] || 
        collision_map[(global_pos_x + `BLK_SIZE -1) >> 6][(pos_y + vel_y - 64) >> 6]
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
    end
    
    
    
    // --------------------------------- Update X axis ---------------------------------
    always @ (posedge game_clk)  begin
        if(!rst) 
            global_pos_x <= 300;
        else begin
        if (eventstate == 4) begin
            resetcounter <= resetcounter + 1;
            if ( resetcounter == 15) begin
                global_pos_x <= 300;
                resetcounter <= 0;
            end
        end
        
        // ------------------------ CHECK SCREEN BOUNDARIES ------------------------
        //If pos_x overflows so off screen left reset to 1
        else if (vel_x < 0 && global_pos_x + vel_x - 64 > 5000) begin 
            vel_x <= 0;
            global_pos_x <= 1;
        end
        
        // --------------------------- CHECK COLLISIONS ---------------------------
        //If moving LEFT and next position overlaps with collidable block
        else if (vel_x < 0 && (
        collision_map[(global_pos_x + vel_x - 64) >> 6][(pos_y) >> 6] || 
        collision_map[(global_pos_x + vel_x - 64) >> 6][(pos_y + `BLK_SIZE - 1) >> 6]
        )) begin
            //If player is going to collide, stop them 
            vel_x <= 0;
            //Set their position to the right of the block that player collided with
            //Position is & 11'b11111100000 to find block edge
            global_pos_x <= ((global_pos_x + vel_x - 64 + `BLK_SIZE) & 15'b111111111000000) + 1;
        end
        
        //If moving RIGHT and next position overlaps with collidable block
        else if (vel_x > 0 && (
        collision_map[(global_pos_x + `BLK_SIZE + vel_x) >> 6][(pos_y) >> 6] || 
        collision_map[(global_pos_x + `BLK_SIZE + vel_x) >> 6][(pos_y + `BLK_SIZE - 1) >> 6]
        )) begin
            //If player is going to collide, stop them 
            //and set their position to the left of the block
            vel_x <= 0;
            global_pos_x <= ((global_pos_x + vel_x) & 15'b111111111000000) - 1;
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
                global_pos_x <= global_pos_x + vel_x - 64; 
            else 
                global_pos_x <= global_pos_x + vel_x;
        end
        end
    end
    
   
    
endmodule
