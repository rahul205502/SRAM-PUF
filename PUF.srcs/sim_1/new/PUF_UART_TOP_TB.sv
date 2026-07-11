`timescale 1ns / 1ps

module UART_PUF_TOP_TB
#(parameter N = 8, M = 8, K = 9, CLK_SPEED = 100_000_000, BAUD_RATE = 115200, MAX_CH = 1);
logic clk;
logic rstn;
logic en;
logic tx;
logic busy;
logic done;

PUF_UART_TOP #(N, M, K, CLK_SPEED, BAUD_RATE, MAX_CH) dut (.*);

always #5 clk = ~clk;
//logic [M-1:0][2*N-1:0] mem;

initial begin
    clk = 0;
    rstn = 0;
    en = 0;
    
    dut.p1.initialize_mem();
    #10; rstn = 1; en = 1;
    
    fork begin
        begin
            wait(done);
            $display("TEST SUCCESSFUL");
            $finish;
        end
        begin
            #1_000_000_000;
            $display("TEST UNSUCCESSFUL");
            $finish;
        end
    end
    join_any
end

initial $monitor("@%0dns, rstn=%0b | en=%0b | tx=%0b | busy=%0b | done=%0b", $time, rstn, en, tx, busy, done);         
endmodule