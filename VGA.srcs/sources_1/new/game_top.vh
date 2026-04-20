//Screen Resolutions
`define RESOLUTION_X 11'd1440
`define RESOLUTION_Y 11'd900

//Border Sizes
`define BORDER_TOP 11'd100
`define BORDER_BTM 11'd32

//Border colour
`define BORDER_R 4'h0
`define BORDER_G 4'h0
`define BORDER_B 4'h0

//Tile dimensions in pixels
`define BLK_SIZE 7'd64
//Pixels per tile
`define MEM_OFFSET 15'd4096

//Level Dimensions
`define LEVEL_SIZE 10'd72
`define LEVEL_HEIGHT 6'd13
//Screen width in tiles
//`define SCREEN_SIZE 6'd24

//Button Macros
`define LBTN 4'b0010
`define RBTN 4'b0100
`define UBTN 4'b0001
`define DBTN 4'b1000

//Player Movement
`define X_ACCELERATION 2
`define X_AIR_ACCELERATION 1
`define JUMP_ACCELERATION 26
`define GRAVITY 2
`define MAX_SPEED_X 10
`define MAX_SPEED_Y 26

`define WIN_FLAG_POS 4400
`define OFF_MAP_POS 750

//Camera positions
`define CAM_BOUND 550
`define CAM_BOUND_MAX 3170

//Enemy positions
`define ENEMY_1_BOUND_LEFT 3650
`define ENEMY_1_BOUND_RIGHT 3900
`define ENEMY_1_POS_Y 668

`define ENEMY_2_BOUND_LEFT 2816
`define ENEMY_2_BOUND_RIGHT 3136
`define ENEMY_2_POS_Y 610



