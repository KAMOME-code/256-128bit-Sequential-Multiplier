`timescale 1ns/1ps

`define Init    0   //state
`define Mul1    1   //state
`define Mul2    2   //state
`define Mul3    3   //state
`define Mul4    4   //state
`define Mul5    5   //state

module Mul256with128(clk, start, busy, A, B, C);

input clk, start;
input [255:0] A,B;
output busy;
output [511:0] C;

reg [127:0] a,b;
reg [511:0] C;
reg [2:0] state;
reg busy;

wire [255:0] c;

assign c = a * b;

always @(posedge clk or negedge start) begin
if(!start) begin    //Ready
    busy <= 0;
    state <= `Init;
end else begin
    if(state == `Init) begin
    busy <= 1;
    C <= 512'b0;
    a <= A[127:0];
    b <= B[127:0];
    state <= `Mul1;
    end else if(state == `Mul1) begin
    C[255:0] <= c;
    a <= A[127:0];
    b <= B[255:128];
    state <= `Mul2;
    end else if(state == `Mul2) begin
    C[511:128] <= C[383:128] + c;
    a <= A[255:128];
    b <= B[127:0];
    state <= `Mul3;
    end else if(state == `Mul3) begin
    C[511:128] <= C[383:128] + c;
    a <= A[255:128];
    b <= B[255:128];
    state <= `Mul4;
    end else if(state == `Mul4) begin  
    C[511:256] <= C[511:256] + c;
    state <= `Mul5;
    end else if(state == `Mul5) begin    
    busy <= 0;
    end
end
end
endmodule