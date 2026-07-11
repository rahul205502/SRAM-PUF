`timescale 1ns / 1ps

module XOR_TB #(parameter N=8, M=8);

logic clk, rstn, valid;
logic [N-1:0] D_in, D_out;

XOR_OP #(N) dut (.*);

always #5 clk = ~clk;

reg [N-1:0] mem [M];
logic [N-1:0] D_out_check;

initial begin
    clk=0; rstn=0; valid=0;    
    foreach(mem[i]) mem[i]=$random;
    #10; rstn=1;
    D_out_check=0;
    foreach(mem[i]) D_out_check ^= mem[i]; 
    for (int i=0; i<M; i++) begin
        D_in = mem[i];
        valid = 1; #10; valid=0;
    end
    if (D_out == D_out_check) $display("--- TEST SUCCESSFUL --- D_out=%0h --- D_out_check=%0h", D_out, D_out_check);
    else $display("--- TEST UNSUCCESSFUL --- D_out=%0h --- D_out_check=%0h", D_out, D_out_check);
    $finish;
end

initial $monitor("time=%0dns | rstn=%0b | valid=%0b | D_in=%0h | D_out=%0b", $time, rstn, valid, D_in, D_out);
 
endmodule