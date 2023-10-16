`timescale 1ns / 1ps

module input_2_fp32 #(
    parameter DATA_WIDTH = 32,
    parameter ASCENDING = 1
) (
    input clk, rst, i_valid,
    input [DATA_WIDTH-1 : 0] x_0, x_1,
    output reg [DATA_WIDTH-1 : 0] y_0, y_1,
    output reg o_valid
);
    
wire flag_0, flag_1;
wire [7 : 0] exp_0, exp_1;
wire [22 : 0] frac_0, frac_1;
reg result;

// condition
wire exp_0_l_exp_1, exp_0_e_exp_1;
wire frac_0_l_frac_1, frac_0_e_frac_1;

assign {flag_0, exp_0, frac_0} = x_0;
assign {flag_1, exp_1, frac_1} = x_1;

assign exp_0_l_exp_1   = exp_0 < exp_1;
assign exp_0_e_exp_1   = exp_0 == exp_1;
assign frac_0_l_frac_1 = frac_0 < frac_1;
assign frac_0_e_frac_1 = frac_0 == frac_1;

always @(*) begin
    if(!exp_0_e_exp_1)
        result = exp_0_l_exp_1 ? 0: 1;
    else if(!frac_0_e_frac_1)
        result = frac_0_l_frac_1 ? 0: 1;
    else
        result = 0;
end


always @(posedge clk or negedge rst) begin
    if (!rst) begin
        y_0 <= 0;
        y_1 <= 0;
        o_valid <= 0;
    end
    else begin
        if (ASCENDING) begin
            if (!result) begin
                y_0 <= x_0;
                y_1 <= x_1;
            end
            else begin
                y_0 <= x_1;
                y_1 <= x_0;
            end
        end
        else begin
            if (result) begin
                y_0 <= x_0;
                y_1 <= x_1;
            end
            else begin
                y_0 <= x_1;
                y_1 <= x_0;
            end
        end

        o_valid <= i_valid;
    end
end

endmodule