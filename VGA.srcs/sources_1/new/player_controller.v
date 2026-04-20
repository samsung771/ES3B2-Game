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
    input [15:0] sw,
    output [15:0] LED,
    input [15:0] cam_x,
    output [15:0] playerpos_x,
    output [10:0] playerpos_y,
    output [1:0] movestate,
    output [1:0] playerstate,
    output [9:0] memory_addr,
    input [7:0] tile,
    output [3:0] lives,
    input [15:0] enemy_1_pos_x,
    input [10:0] enemy_1_pos_y,
    input [15:0] enemy_2_pos_x,
    input [10:0] enemy_2_pos_y
    );
    
    //Secret Code
    `define SECRET_CODE 16'b1100100110011001
    //Sets LEDs on if they match the code
    //Uses bitwise XNOR gate 
    assign LED = sw ^~ `SECRET_CODE;
    
    // ------------------------- Player Movement Variables -------------------------
    reg [12:0] global_pos_x = 300;
    reg [10:0] pos_y = 100;
    
    //Assign output wires to x and y registers
    //Output players position on the screen
    assign playerpos_x = global_pos_x;
    //+100 to account for border
    assign playerpos_y = pos_y + 100;
    
    
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
    
    reg [3:0] attempts = 0;
    assign lives = attempts;
    
    // ----------------------------- Level Memory Setup ----------------------------- 
    //Memory address for tiled level
    reg [9:0] level_addr = 0;
    assign memory_addr = level_addr;
  
    
    
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
    
    //Check if player overlaps with enemy
    function check_enemy_collision; 
    input[15:0] enemy_pos_x;
    input[10:0] enemy_pos_y;
    begin
            check_enemy_collision = (
                ((global_pos_x >= enemy_pos_x &&                        
                global_pos_x < enemy_pos_x + `BLK_SIZE) ||                     
                (global_pos_x + `BLK_SIZE >= enemy_pos_x &&                    
                global_pos_x + `BLK_SIZE < enemy_pos_x + `BLK_SIZE)) &&        
                                                                        
                ((pos_y + 100 >= enemy_pos_y &&                         
                pos_y + 100 < enemy_pos_y + `BLK_SIZE) ||               
                (pos_y + `BLK_SIZE + 100 >= enemy_pos_y &&              
                pos_y + `BLK_SIZE + 100 < enemy_pos_y + `BLK_SIZE))
            );
    end
    endfunction
    
    
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
            
            if (pos_y > `OFF_MAP_POS) //Fall off the map or ...
                eventstate <= 1;
            else if  (
                check_enemy_collision(enemy_1_pos_x, enemy_1_pos_y) ||
                check_enemy_collision(enemy_2_pos_x, enemy_2_pos_y)
            ) //Collides with enemy
                eventstate <= 1;
                
                
            else if (global_pos_x > `WIN_FLAG_POS ||
                     sw == `SECRET_CODE)
                eventstate <= 2;
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
     
     `define FIND_EDGE(pos) (pos & 16'b1111111111000000)
     
    // --------------------------------- Update Y axis ---------------------------------
    always @ (posedge game_clk)  begin
        if(!rst) 
            pos_y <= 100;
        else begin
        if ( resetcounter == 5 && eventstate == 1) 
            pos_y <= 100;
            
        else if (vel_y < 0 && pos_y + vel_y - 64 > 1500) begin
            vel_y <= `GRAVITY;
            pos_y <= 1;
        end
        
        `define LEFT_CORNER  (global_pos_x) >> 6
        `define RIGHT_CORNER (global_pos_x + `BLK_SIZE-1) >> 6
        `define NEWPOS_DOWN  (pos_y + `BLK_SIZE + vel_y) >> 6
        `define NEWPOS_UP    (pos_y + vel_y - 64) >> 6
        
        // --------------------------- CHECK COLLISIONS ---------------------------
        //If moving DOWN and next position overlaps with collidable block
        else if (vel_y > 0 && (
        collision_map[`LEFT_CORNER ][`NEWPOS_DOWN] || 
        collision_map[`RIGHT_CORNER][`NEWPOS_DOWN]
        )) begin
            //If player is going to collide, stop them 
            //and set their position to above the block
            vel_y <= 0;
            pos_y <= `FIND_EDGE(pos_y + vel_y) - 1;
        end
        
        //If moving UP and next position overlaps with collidable block
        else if (vel_y < 0 && (
        collision_map[`LEFT_CORNER ][`NEWPOS_UP] || 
        collision_map[`RIGHT_CORNER][`NEWPOS_UP]
        )) begin
            //If player is going to collide, stop them 
            //and set their position to below the block
            vel_y <= 0;
            pos_y <= `FIND_EDGE(pos_y + vel_y) + 1;
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
        if(!rst) begin
            attempts <= 0;
            global_pos_x <= 300;
        end
        else begin
        if (eventstate == 1) begin
            resetcounter <= resetcounter + 1;
            if ( resetcounter == 5) begin
                attempts <= attempts + 1;
                global_pos_x <= 300;
                resetcounter <= 0;
            end
        end
        
        // ------------------------ CHECK SCREEN BOUNDARIES ------------------------
        //If moving left and new position would overflow (i.e. go off the screen)
        else if (vel_x < 0 && global_pos_x + vel_x - 64 > 5000) begin 
            //Stop player and set position to edge
            vel_x <= 0;
            global_pos_x <= 1;
        end
        
        
        `define NEWPOS_LEFT  (global_pos_x + vel_x - 64) >> 6
        `define NEWPOS_RIGHT (global_pos_x + `BLK_SIZE + vel_x) >> 6
        `define TOP_CORNER   (pos_y) >> 6
        `define BTM_CORNER   (pos_y + `BLK_SIZE - 1) >> 6
        
        // --------------------------- CHECK COLLISIONS ---------------------------
        //If moving LEFT and next position overlaps with collidable block
        else if (vel_x < 0 && (
        collision_map[`NEWPOS_LEFT][`TOP_CORNER] || 
        collision_map[`NEWPOS_LEFT][`BTM_CORNER]
        )) begin
            //If player is going to collide, stop them 
            vel_x <= 0;
            //Set their position to the right of the block that player collided with
            global_pos_x <= `FIND_EDGE(global_pos_x + vel_x) + 1;
        end
        
        //If moving RIGHT and next position overlaps with collidable block
        else if (vel_x > 0 && (
        collision_map[`NEWPOS_RIGHT][`TOP_CORNER] || 
        collision_map[`NEWPOS_RIGHT][`BTM_CORNER]
        )) begin
            //If player is going to collide, stop them 
            //and set their position to the left of the block
            vel_x <= 0;
            global_pos_x <= `FIND_EDGE(global_pos_x + vel_x) - 1;
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
