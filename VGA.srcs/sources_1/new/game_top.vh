`define RESOLUTION_X 11'd1440
`define RESOLUTION_Y 11'd900

`define PIXEL_SIZE 4
`define PIXEL_X `RESOLUTION_X >> 2
`define PIXEL_Y `RESOLUTION_Y >> 2


`define BORDER_TOP 11'd100
`define BORDER_BTM 11'd32

`define BORDER_R 4'h0
`define BORDER_G 4'h0
`define BORDER_B 4'h0

`define BG_R 4'h5
`define BG_G 4'h9
`define BG_B 4'hf

`define BLK_SIZE 7'd64
`define MEM_OFFSET 13'd256

//Button Macros
`define LBTN 4'b0010
`define RBTN 4'b0100
`define UBTN 4'b0001
`define DBTN 4'b1000





