`timescale 1ns / 1ps

module LFSR_TB #(parameter N=8);

logic clk;
logic rstn;
logic en;
logic [N-1:0] ch;
logic [N-1:0] seed_t;
logic [N-1:0] gate_t;
logic [N-1:0] rp;
logic done;

LFSR #(N) dut (.*);

always #5 clk = ~clk;

initial begin
    clk = 0;
    rstn = 0;
    en = 0;
    ch = $random % (2**N);
    seed_t = $random % (2**N);
    gate_t = $random % (2**N);
    #10; 
    rstn = 1;
    en = 1; #10; en = 0;
    
    fork begin
        begin
            wait(done); #5;
            $display("DONE DETECTED");
            $finish;
        end
        begin
            #1000;
            $display("DONE NOT DETECTED");
            $finish;
        end
    end
    join_any
end

initial $monitor("@%3dns, rstn=%0b | en=%0b | ch=%2h | seed=%2h | gate=%2h | rp=%2h | done=%0b",
                  $time, rstn, en, ch, dut.seed, dut.gate, rp, done);
    
endmodule