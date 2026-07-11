
module CODEWORD_GEN #(parameter N=8) (clk, rstn, en, ch, ecc_rp, c_word);
localparam M=$clog2(N);
input clk, rstn, en;
input [N-1:0] ch;
input [N+M:0] ecc_rp;
output logic [N+M:0] c_word;

logic [N+M:0] temp;
int pos,d_pos,i;

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        c_word <= '0;
        temp <= '0;
    end
    else if (en) begin
        for (pos=0,i=1; pos<N+M+1; pos++) begin 
            if (i == pos+1) begin
                temp[pos] = 1'b0;
                i = i<<1;
            end
            else begin  
                temp[pos] = ch[d_pos];
                d_pos++;
            end
        end
    end
    temp ^= ecc_rp;
    c_word = temp;
end

endmodule