
module XOR_OP #(parameter N=8) (
    input clk, rstn, valid, 
    input [N-1:0] D_in,
    output logic [N-1:0] D_out
);

always @ (posedge clk or negedge rstn) begin
    if (!rstn) begin
        D_out <= '0;
    end
    else begin
        if (valid) D_out <= D_out ^ D_in;
    end
end

endmodule 