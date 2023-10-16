`timescale 1ps/1ps
`include "./unit_selector.v"
`include "./buffer.v"

module topk_top #
(
    parameter LOG_INPUT_NUM = 4,    //TOPK -> TOP16
    parameter DATA_WIDTH = 32
) (
    input clk, rst,
    input i_valid,
    input [DATA_WIDTH*(2**LOG_INPUT_NUM)-1 : 0] x,  //32*16
    output [DATA_WIDTH*(2**LOG_INPUT_NUM)-1 : 0] y
    // output o_valid
);

wire [DATA_WIDTH*(2**LOG_INPUT_NUM)-1 : 0] selector_rslt;
wire selector_o_valid;


buffer #
(
    .DATA_WIDTH(DATA_WIDTH),
    .LOG_INPUT_NUM(LOG_INPUT_NUM)
) buffer_
(
    .clk(clk),
    .rst(rst),
    .i_valid(selector_o_valid),
    .i_data(selector_rslt),
    .o_data(y)
);

unit_selector #
(
    .DATA_WIDTH(DATA_WIDTH),
    .LOG_INPUT_NUM(LOG_INPUT_NUM)
) unit_selector_
(
    .clk(clk),
    .rst(rst),
    .i_valid(i_valid),
    .x_0(y),
    .x_1(x),
    .y(selector_rslt),
    .o_valid(selector_o_valid)
);


endmodule