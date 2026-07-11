`timescale 1ns / 1ps

module TB_MAJOR_VOTE #(parameter N=8, M=8, K=9);

logic clk, rstn, en;
logic [N-1:0] D_in;
logic [N-1:0] D_out;
logic get_val, done;

MAJOR_VOTE #(N,K) dut (.*);
int i;
reg [N-1:0] mem [K*M];

always #5 clk = ~clk;

initial begin
    clk=0;
    rstn=0;
    en=0;
    i=0;
    D_in='0;
    foreach (mem[i,j]) mem[i][j] <= $random;
    #10 rstn=1;
    en=1;
    #10; en=0;
    
    foreach (mem[i]) begin
        @(posedge get_val) D_in <= mem[i];
    end
    
    fork begin
        begin
            wait(done); #5;
            $display("TEST SUCCESSFUL");
            $finish;
        end
        begin
            #3000;
            $display("TEST UNSUCCESSFUL");
            $finish;
        end
    end
    join_any
end

//always @ (posedge get_val) begin 
//    if (i<M) begin
//        D_in <= mem[i]; 
//        i<=i+1; 
//    end
//end

initial $monitor("@%3dns, rstn=%0b | en=%0b | D_in=%2h | D_out=%2h | get_val=%0b | done=%0b",
                  $time, rstn, en, D_in, D_out, get_val, done);
               
endmodule 