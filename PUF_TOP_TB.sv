`timescale 1ns / 1ps

module TB_PUF_TOP #(parameter N=8, M=8, K=8, real TEMP=65.0, real VOLT=0.8);

logic clk;
logic rstn;
logic en;
logic [N-1:0] ch;
logic [N-1:0] rp;
logic done;

int i;

PUF_TOP #(N, M, K) dut (.*);
//reg [N-1:0] mem [M];

always #5 clk = ~clk;

initial begin
    clk  = 0;
    rstn = 0;
    en = 0;
    ch = $random;
    
    dut.initialize_mem();
    dut.change_cond(.temp(TEMP), .volt(VOLT));
    
    #10; rstn = 1; en = 1;
    #10; en = 0;
    
    fork begin
        begin
            wait(done); #10;
            $display("TEST SUCCESSFUL");
            $finish;
        end
        begin
            #5000;
            $display("TEST UNSUCCESSFUL");
            $finish;
        end
    end
    join_any
end

initial $monitor("@%3dns, rstn=%0b | en=%0b | ch=%2h | rp=%2h | done=%0b", $time, rstn, en, ch, rp, done);

endmodule