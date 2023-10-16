`timescale 1ns/1ps
`include "./topk_top.v"

module test_topk;

`define DATA_WIDTH 32
`define LOG_INPUT_NUM 4

reg clk, rst, i_valid;
reg [`DATA_WIDTH*(2**`LOG_INPUT_NUM)-1 : 0] x;
wire signed [`DATA_WIDTH*(2**`LOG_INPUT_NUM)-1 : 0] y;
// wire o_valid;

always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 0;
    i_valid = 0;
    #5
    rst = 1;
    #5
    i_valid = 1;
end

integer i, j;

initial begin
    for(i = 0; i < 20; i = i + 1) begin
        for(j = 0; j < (2**`LOG_INPUT_NUM); j = j + 1) begin
            x[`DATA_WIDTH*(j+1)-1 -: `DATA_WIDTH] = $random();
        end
        #10
        $display("-------------------data input %d------------------", i);
        for(j = 0; j < (2**`LOG_INPUT_NUM); j = j + 1) begin
            $display("%g,", $bitstoshortreal(x[`DATA_WIDTH*(j+1)-1 -: `DATA_WIDTH]));
        end
    end
    #150
    $display("------------------after select---------------------");
    for(i = 0; i < (2**`LOG_INPUT_NUM); i = i + 1) begin
        $display("%g,", $bitstoshortreal(y[`DATA_WIDTH*(i+1)-1 -: `DATA_WIDTH]));
    end
end


topk_top #
(
    .DATA_WIDTH(`DATA_WIDTH),
    .LOG_INPUT_NUM(`LOG_INPUT_NUM)
) topk_top_ 
(
    .clk(clk),
    .rst(rst),
    .i_valid(i_valid),
    .x(x),
    .y(y)
    // .o_valid(o_valid)
);

endmodule


