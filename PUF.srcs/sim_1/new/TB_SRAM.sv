`timescale 1ns / 1ps

module TB_SRAM #(parameter N=8, M=8, K=9, real TEMP=40.0, real VOLT=0.91);
logic clk, rstn, en, get_val;
logic [N-1:0] out;
logic new_val, done;

SRAM_CTRL #(N,M,K) dut (.*);

always #5 clk = ~clk;
reg [N-1:0] mem_sim [M];

initial begin
    clk = 1'b0;
    rstn = 1'b0;
    en = 1'b0;
    get_val = 1'b0;
    
    foreach(mem_sim[i]) mem_sim[i] = $random;
    dut.initialize_mem (mem_sim);
    dut.change_cond (.temp(TEMP), .volt(VOLT));
    
    #10; rstn = 1'b1; en = 1'b1; get_val=1'b1;
    #10; en = 1'b0;
    
    fork begin
        begin
            wait(done); #10;
            $display("DONE DETECTED", "\nTEST SUCCESSFUL");
            $finish;
        end
        begin
            #3000;
            $display("DONE NOT DETECTED", "\nTEST UNSUCCESSFUL");
            $finish;
        end
    end
    join_any
end

initial $monitor("@%0d, rstn=%0b | en=%0b | get_val=%0b | out=%2h | new_val=%0b | done=%0b",
        $time, rstn, en, get_val, out, new_val, done);
        
endmodule 