`timescale 1ns / 1ps

module bitonic_sorting_recursion_submodule #
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
    // Declare the wires which come out of the input_2 compare network of every stage
    wire [DATA_WIDTH*(2**LOG_INPUT_NUM)-1 : 0] stage0_rslt;
    wire stage0_valid;
    genvar i;


    // Stage 1
    // Stage0_0~2**(n-1)-1 has the same ascending feature with the entire network output.
    for ( i = 0; i < (2**(LOG_INPUT_NUM-1)); i = i + 1) begin: stage0
        input_2_fp32 #
        (
            .DATA_WIDTH(DATA_WIDTH),
            .ASCENDING(ASCENDING)
        )
        input_2_stage0
        (
            .clk(clk),
            .rst(rst),
            .i_valid(i_valid),
            .x_0(x[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i]),
            .x_1(x[DATA_WIDTH*(i+1+(2**(LOG_INPUT_NUM-1)))-1:DATA_WIDTH*(i+(2**(LOG_INPUT_NUM-1)))]),
            .y_0(stage0_rslt[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i]),
            .y_1(stage0_rslt[DATA_WIDTH*(i+1+(2**(LOG_INPUT_NUM-1)))-1:DATA_WIDTH*(i+(2**(LOG_INPUT_NUM-1)))]),
            .o_valid(stage0_valid)
        );
    end

    // Stage 2
    // Stage1_0 has the same ascending feature with the entire network output.
    // Stage1_1 has the same ascending feature with the entire network output as well.
    bitonic_sorting_recursion_submodule #
    (
        .LOG_INPUT_NUM(LOG_INPUT_NUM-1),
        .DATA_WIDTH(DATA_WIDTH),
        .ASCENDING(ASCENDING)
    )
    inst_stage1_0 
    (
        .clk(clk),
        .rst(rst),
        .i_valid(stage0_valid),
        .x(stage0_rslt[DATA_WIDTH*(2**(LOG_INPUT_NUM-1))-1:0]),
        .y(y[DATA_WIDTH*(2**(LOG_INPUT_NUM-1))-1:0]),
        .o_valid(o_valid)
    );

    bitonic_sorting_recursion_submodule #
    (
        .LOG_INPUT_NUM(LOG_INPUT_NUM-1),
        .DATA_WIDTH(DATA_WIDTH),
        .ASCENDING(ASCENDING)
    )
    inst_stage1_1 
    (
        .clk(clk),
        .rst(rst),
        .i_valid(stage0_valid),
        .x(stage0_rslt[DATA_WIDTH*(2**LOG_INPUT_NUM)-1:DATA_WIDTH*(2**(LOG_INPUT_NUM-1))]),
        .y(y[DATA_WIDTH*(2**LOG_INPUT_NUM)-1:DATA_WIDTH*(2**(LOG_INPUT_NUM-1))]),
        .o_valid()
    );
end else if (LOG_INPUT_NUM == 1) begin
    input_2_fp32 #
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


