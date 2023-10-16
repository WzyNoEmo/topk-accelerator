`timescale 1ns/1ps
//`include "E:/topk_accelerator/project/bitonic_sorting_recursion.v"

module test_sorter;


`define DATA_WIDTH 32
`define LOG_INPUT_NUM 4


reg clk, rst;
reg i_valid;
reg [`DATA_WIDTH*(2**`LOG_INPUT_NUM)-1 : 0] x;
wire [`DATA_WIDTH*(2**`LOG_INPUT_NUM)-1 : 0] y;
wire o_valid;

always #5 clk = ~clk;

integer i;

initial begin
    clk = 0;
    rst = 0;
    i_valid = 0;
    
    for(i = 0; i < (2**`LOG_INPUT_NUM); i = i + 1) begin
        x[`DATA_WIDTH*(i+1)-1 -: `DATA_WIDTH] = $random();
    end
    $display("-------------before sorting----------------");
    for(i = 0; i < (2**`LOG_INPUT_NUM); i = i + 1) begin
        $display("%g | %b", $bitstoshortreal($signed(x[`DATA_WIDTH*(i+1)-1 -: `DATA_WIDTH])), x[`DATA_WIDTH*(i+1)-1 -: `DATA_WIDTH]);
    end

    
    #10
    rst = 1;
    #10
    i_valid = 1;
    #150
    $display("-------------after sorting------------------");
    for(i = 0; i < (2**`LOG_INPUT_NUM); i = i + 1) begin
        $display("%g | %b", $bitstoshortreal($signed(y[`DATA_WIDTH*(i+1)-1 -: `DATA_WIDTH])), y[`DATA_WIDTH*(i+1)-1 -: `DATA_WIDTH]);
    end
end

bitonic_sorting_recursion #
(
    .LOG_INPUT_NUM(`LOG_INPUT_NUM),
    .DATA_WIDTH(`DATA_WIDTH),
    .ASCENDING(0)
) sorter
(
    .clk(clk),
    .rst(rst),
    .i_valid(i_valid),
    .x(x),
    .y(y),
    .o_valid(o_valid)
);


endmodule