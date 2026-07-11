`timescale 1ns / 1ps

module ECC_TOP_TB #(parameter N=8, M=8, K=8, real TEMP=65.0, real VOLT=0.8);

logic clk;
logic rstn;
logic en;
logic [N-1:0] ch;
logic [N+$clog2(N):0] ecc_rp;
logic done;

ECC_TOP #(N, M, K) dut (.*);
//reg [N-1:0] mem [M];
int i;

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
            $display("parity = %4b | rp = %4b", dut.e1.parity, dut.rp); 
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

initial $monitor("@%3dns, rstn=%0b | en=%0b | ch=%8b | ecc_rp=%12b | done=%0b", $time, rstn, en, ch, ecc_rp, done);

endmodule