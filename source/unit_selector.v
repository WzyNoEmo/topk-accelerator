`timescale 1ps/1ps

module unit_selector #(
    parameter DATA_WIDTH = 32,
    parameter LOG_INPUT_NUM = 5
) (
    input clk, rst,
    input i_valid,
    input [DATA_WIDTH*(2**LOG_INPUT_NUM)-1 : 0] x_0, x_1,
    output [DATA_WIDTH*(2**LOG_INPUT_NUM)-1 : 0] y,
    output o_valid
);

wire [DATA_WIDTH*(2**LOG_INPUT_NUM)-1:0] sorter_0_rslt, sorter_1_rslt; 
wire sorter_valid;
genvar i;

// stage_0: two sorter
bitonic_sorting_recursion #
(
    .LOG_INPUT_NUM(LOG_INPUT_NUM),
    .DATA_WIDTH(DATA_WIDTH),
    .ASCENDING(1)   //升序
) 
sorter_0
(
    .clk(clk),
    .rst(rst),
    .i_valid(i_valid),
    .x(x_0),
    .y(sorter_0_rslt),
    .o_valid(sorter_valid)
);

bitonic_sorting_recursion #
(
    .LOG_INPUT_NUM(LOG_INPUT_NUM),
    .DATA_WIDTH(DATA_WIDTH),
    .ASCENDING(0)   //降序
) 
sorter_1
(
    .clk(clk),
    .rst(rst),
    .i_valid(i_valid),
    .x(x_1),
    .y(sorter_1_rslt),
    .o_valid()
);

// stage 1: select topk
for(i = 0; i < (2**LOG_INPUT_NUM); i = i + 1) begin
    input_2_fp32 #
    (
        .DATA_WIDTH(DATA_WIDTH),
        .ASCENDING(1)
    )
    cmp
    (
        .clk(clk),
        .rst(rst),
        .i_valid(sorter_valid),
        .x_0(sorter_0_rslt[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i]),
        .x_1(sorter_1_rslt[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i]),
        .y_0(),
        .y_1(y[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i]),
        .o_valid(o_valid)
    );
end

endmodule