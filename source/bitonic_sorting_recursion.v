//********************************************************************************************************
//**  核心：并行排序算法（双调排序）                                                                       ** 
//**  参考网址：https://blog.csdn.net/qq_42224089/article/details/128628161                              **
//**  理解：                                                                                             **
//**         bitonic_sorting_recursion_submodule  实现真正意义上的比较器，实现方式又是以递归方式完成         **
//**         bitonic_sorting_recursion            递归进行任务拆分                                        **
//**         对于每个part，stage1先进行任务划分（forward），stage2利用submodule进行递归整合(backward)        **
//**                                                                                                     **
//*********************************************************************************************************

`timescale 1ns / 1ps
`include "./bitonic_sorting_recursion_submodule.v"
`include "./input_2_fp32.v"

module bitonic_sorting_recursion #
(
    parameter LOG_INPUT_NUM = 4, // Eg: If LOG_INPUT_NUM=4, then input number is 2**4=16 
    parameter DATA_WIDTH = 32,
    parameter ASCENDING = 1

)
(
    input clk, rst, i_valid,
    input [DATA_WIDTH*(2**LOG_INPUT_NUM)-1 : 0] x,
    output [DATA_WIDTH*(2**LOG_INPUT_NUM)-1 : 0] y,
    output o_valid
);

if (LOG_INPUT_NUM > 1) begin
    // Declare the wires which come out of the 2 2**(n-1)-input comparators with opposite ascending feature.
    wire [DATA_WIDTH*(2**LOG_INPUT_NUM)-1 : 0] stage0_rslt;
    wire stage0_valid;


    // Stage 1, use two 2**(n-1)-input comparators with opposite ascending features to sort.
    // Stage0_0 has the same ascending feature with the entire network output.
    // Stage0_1 has the opposite ascending feature with the entire network output.
    bitonic_sorting_recursion #
    (
        .LOG_INPUT_NUM(LOG_INPUT_NUM-1),
        .DATA_WIDTH(DATA_WIDTH),
        .ASCENDING(ASCENDING)
    )
    inst_stage0_0 
    (
        .clk(clk),
        .rst(rst),
        .i_valid(i_valid),
        .x(x[DATA_WIDTH*(2**(LOG_INPUT_NUM-1))-1:0]),
        .y(stage0_rslt[DATA_WIDTH*(2**(LOG_INPUT_NUM-1))-1:0]), // 7 - 0
        .o_valid(stage0_valid)
    );

    bitonic_sorting_recursion #
    (
        .LOG_INPUT_NUM(LOG_INPUT_NUM-1),
        .DATA_WIDTH(DATA_WIDTH),
        .ASCENDING(1-ASCENDING)
    )
    inst_stage0_1 
    (
        .clk(clk),
        .rst(rst),
        .i_valid(i_valid),
        .x(x[DATA_WIDTH*(2**LOG_INPUT_NUM)-1:DATA_WIDTH*(2**(LOG_INPUT_NUM-1))]),
        .y(stage0_rslt[DATA_WIDTH*(2**LOG_INPUT_NUM)-1:DATA_WIDTH*(2**(LOG_INPUT_NUM-1))]), // 15 - 8
        .o_valid()
    );

    // Stage 2, use a 2**n-input bitonic submodule to sort the outputs of the stage 1.
    // bitonic_sorting_resursion_submodule should have the same ascending feature with the entire network output.
    bitonic_sorting_recursion_submodule #
    (
        .LOG_INPUT_NUM(LOG_INPUT_NUM),
        .DATA_WIDTH(DATA_WIDTH),
        .ASCENDING(ASCENDING)
    )
    inst_stage1 
    (
        .clk(clk),
        .rst(rst),
        .i_valid(stage0_valid),
        .x(stage0_rslt),
        .y(y),
        .o_valid(o_valid)
    );
end else if (LOG_INPUT_NUM == 1) begin
    input_2_fp32 #  //一拍出结果
    (
        .DATA_WIDTH(DATA_WIDTH),
        .ASCENDING(ASCENDING)
    )
    input_2_stage0_1 
    (
        .clk(clk),
        .rst(rst),
        .i_valid(i_valid),
        .x_0(x[DATA_WIDTH-1:0]),
        .x_1(x[DATA_WIDTH*2-1:DATA_WIDTH]),
        .y_0(y[DATA_WIDTH-1:0]),
        .y_1(y[DATA_WIDTH*2-1:DATA_WIDTH]),
        .o_valid(o_valid)
    );
end


endmodule


