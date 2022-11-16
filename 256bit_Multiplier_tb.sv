`timescale 1ns/1ps

`define delay   10

class seq_item #();

  rand bit [255:0] rand_A;
  rand bit [255:0] rand_B;
  constraint value_A {rand_A inside {[256'h1:256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF]};}
  constraint value_B {rand_B inside {[256'h1:256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF]};}

endclass


module Multiplier_tb;

reg [511:0] Expect;

reg clk, start;
reg [255:0] A, B;
wire [511:0] C;
wire busy;

Mul256with128 mult(clk, start, busy, A, B, C);
seq_item #() item;

initial begin
  $dumpfile("dump.vcd");
  $dumpvars;
  #300000 
  $finish;
end

always #50  clk = ~clk;

initial begin

  clk=1;  // initialize clk
  item = new();

    repeat(300) begin
        start = 0;
        item.randomize();
        {A,B} = {item.rand_A, item.rand_B};
        Expect = A * B;
        @(posedge clk)  #`delay;
        start = 1;
        @(posedge clk)  #`delay;
        while (busy==1) @(posedge clk);
        if(Expect==C) begin
            $display("Match A=%h B=%h C=%h Expect=%h",A,B,C,Expect);
        end else begin
            $display("Error A=%h B=%h C=%h Expect=%h",A,B,C,Expect);
        end
    end
$finish;
end
endmodule