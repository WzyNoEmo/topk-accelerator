`timescale 1ns/1ps
`include "./unit_selector.v"

module test_unit_selector;

`define DATA_WIDTH 32
`define LOG_INPUT_NUM 4

reg clk, rst, i_valid;
reg [`DATA_WIDTH*(2**`LOG_INPUT_NUM)-1 : 0] x_0, x_1;
wire signed [`DATA_WIDTH*(2**`LOG_INPUT_NUM)-1 : 0] y;
wire o_valid;

always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 0;
    #5
    rst = 1;
end

integer i;

initial begin
    i_valid = 0;
    for(i = 0; i < (2**`LOG_INPUT_NUM); i = i + 1) begin
        x_0[`DATA_WIDTH*(i+1)-1 -: `DATA_WIDTH] = $random();
        x_1[`DATA_WIDTH*(i+1)-1 -: `DATA_WIDTH] = $random();
    end
    $display("-------------------before select------------------");
    for(i = 0; i < (2**`LOG_INPUT_NUM); i = i + 1) begin
        $display("%g,", $bitstoshortreal(x_0[`DATA_WIDTH*(i+1)-1 -: `DATA_WIDTH]));
        $display("%g,", $bitstoshortreal(x_1[`DATA_WIDTH*(i+1)-1 -: `DATA_WIDTH]));
    end
    #10
    i_valid = 1;
    #150
    $display("------------------after select---------------------");
    for(i = 0; i < (2**`LOG_INPUT_NUM); i = i + 1) begin
        $display("%g,", $bitstoshortreal(y[`DATA_WIDTH*(i+1)-1 -: `DATA_WIDTH]));
    end
end

unit_selector #
(
    .DATA_WIDTH(`DATA_WIDTH),
    .LOG_INPUT_NUM(`LOG_INPUT_NUM)
) unit_selector_ 
(
    .clk(clk),
    .rst(rst),
    .i_valid(i_valid),
    .x_0(x_0),
    .x_1(x_1),
    .y(y),
    .o_valid(o_valid)
);

endmodule


