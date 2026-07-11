
module ECC_TOP #(parameter N=8, M=8, K=9) (
    input clk, rstn, en,
    input [N-1:0] ch,
    output [N+$clog2(N):0] ecc_rp,
    output logic done
);

logic ecc_enroll, puf_done, ecc_done;
logic [N-1:0] rp;

PUF_TOP #(N,M,K) p1 (.clk(clk), .rstn(rstn), .en(en), .ch(ch), .rp(rp), .done(puf_done));
ECC_ENCODER #(N) e1 (.clk(clk), .rstn(rstn), .enroll(ecc_enroll), .D_in(rp), .D_out(ecc_rp), .done(ecc_done));

enum logic [1:0] {PUF_EN, ECC_EN, ECC_DONE} state;

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        ecc_enroll <= 1'b0;
        done <= 1'b0;
        state <= PUF_EN;
    end
    else begin
        case (state)
            PUF_EN: if (en) state <= ECC_EN;
            ECC_EN: begin
                if (puf_done) begin
                    ecc_enroll <= 1'b1;
                    state <= ECC_DONE;
                end
            end
            ECC_DONE: begin
                ecc_enroll <= 1'b0;
                if(ecc_done) begin
                    done <= 1'b1;
                    state <= PUF_EN;
                end
            end
        endcase
    end
end
                

`ifndef SYNTHESIS
reg [2*N-1:0] mem_sim [M];

function automatic void initialize_mem (input reg [2*N-1:0] mem [M] = mem_sim);
     p1.s1.initialize_mem (.mem(mem));
endfunction

function automatic void change_cond (input real temp=25.0, input real volt=1.0);
    p1.s1.change_cond (.temp(temp), .volt(volt));
endfunction

initial foreach(mem_sim[i]) mem_sim[i] = $random;

function real get_errProb ();
    get_errProb = p1.s1.get_errProb ();
endfunction

`endif

endmodule
