
module TB_CODEWORD_GEN #(parameter N=8);
localparam M=$clog2(N);
logic clk, rstn, en;
logic [N-1:0] ch;
logic [N+M:0] ecc_rp, c_word;

CODEWORD_GEN #(N) dut (.*);

always #5 clk = ~clk;

initial begin
    clk = 0;
    rstn = 0;
    en = 0; 
    ch = $random;
    ecc_rp = $random;
    
    #10;
    
    rstn = 1;
    en = 1;
    
    fork begin
        begin
            @(c_word);
            $display("OUTPUT GENERATED\ncodeword = %0b", c_word);
            $finish;
        end
        begin
            #2000;
            $display("OUTPUT NOT GENERATED");
            $finish;
        end
    end
    join_any
end

endmodule