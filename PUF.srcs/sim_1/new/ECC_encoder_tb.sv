
module ECC_ENCODER_TB #(parameter N=8);
localparam M=$clog2(N);
logic clk, rstn, enroll;
logic [N-1:0] D_in;
logic [N+M:0] D_out;
logic done;

ECC_ENCODER #(N) dut (.*);

always #5 clk = ~clk;

initial begin
    clk = 0;
    rstn = 0; D_in = 8'hAC; enroll = 0;
    #10; rstn = 1; enroll = 1;    
    
    fork begin
        begin
            @(done); #5;
            $display("OUTPUT GENERATED");
            $display("D_in = %8b | D_out = %12b (parity = %4b)", D_in, D_out, dut.parity);
            $finish;
        end
        begin
            #1000;
            $display("OUTPUT NOT GENERATED\nSIMULATION FAILED");
            $finish;
        end
    end
    join_any;
end

endmodule  