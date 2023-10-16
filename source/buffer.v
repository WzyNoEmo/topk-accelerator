`timescale 1ps/1ps

module buffer #(
    parameter DATA_WIDTH = 32,
    parameter LOG_INPUT_NUM = 5,
    parameter BUFFER_SIZE = 10
) (
    input clk, rst,
    input i_valid,
    input [DATA_WIDTH*(2**LOG_INPUT_NUM)-1 : 0] i_data,
    output [DATA_WIDTH*(2**LOG_INPUT_NUM)-1 : 0] o_data
);

reg [DATA_WIDTH*(2**LOG_INPUT_NUM)-1 : 0] mem[0 : BUFFER_SIZE-1];   // 数据位宽 * 一组数据个数 * Buff流水长度  32 * 16 * 10
reg [3 : 0] rd_ptr, wr_ptr;

assign o_data = mem[rd_ptr];

integer i;
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        for(i = 0; i < BUFFER_SIZE; i = i + 1) begin
            mem[i] <= 0;
        end
    end
    else begin
        if(i_valid)
            mem[wr_ptr] <= i_data;
    end
end

// rd/wr ptr
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        rd_ptr <= 4'b0;
        wr_ptr <= BUFFER_SIZE-1;
    end
    else begin
        if(i_valid) begin
            if(rd_ptr == BUFFER_SIZE-1)
                rd_ptr <= 4'b0;
            else
                rd_ptr <= rd_ptr + 1;
            
            if(wr_ptr == BUFFER_SIZE-1)
                wr_ptr <= 4'b0;
            else
                wr_ptr <= wr_ptr + 1;
        end
    end
end
    
endmodule