
module PUF_TOP #(parameter N=8, M=8, K=9) (
    input logic clk,
    input logic rstn,
    input logic en,
    input logic [N-1:0] ch,
    output logic [N-1:0] rp,
    output logic done
);

logic en_SRAM, en_MAJOR_VOTE, en_LFSR;
logic done_SRAM, done_MAJOR_VOTE, done_LFSR;
logic new_val, get_val, valid;

logic [2*N-1:0] out_SRAM, out_MAJOR_VOTE, out_XOR;
logic [N-1:0] seed, gate; // output of MAJOR_VOTE

assign en_SRAM = en;
assign done_LFSR = done; 
assign {seed, gate} = out_XOR;

enum logic [1:0] { // enable condition for each module
SRAM,
MAJOR_VOTE,
LFSR,
DONE } state;

always @ (posedge clk or negedge rstn) begin
    if (!rstn) begin
        en_MAJOR_VOTE <= 0;
        en_LFSR <= 0;
        state <= SRAM;
    end
    else begin
        en_MAJOR_VOTE <= 0;
        en_LFSR <= 0;
        
        case (state)
            SRAM: begin
                if (en) state <= MAJOR_VOTE;
            end
            
            MAJOR_VOTE: begin 
                en_MAJOR_VOTE <= 1;
                state <= LFSR;
            end
            
            LFSR: begin
                if (done_MAJOR_VOTE) begin
                    en_LFSR <= 1;
                    state <= DONE;
                end
            end
            
            DONE: begin
                if (done) state <= SRAM;
            end
            
            default: state <= SRAM;
        endcase
    end
end

SRAM_CTRL #(2*N, M, K) s1 (
    .clk (clk),
    .rstn (rstn),
    .en (en),
    .get_val (get_val),
    .out (out_SRAM),
    .new_val (new_val),
    .done (done_SRAM) 
);

MAJOR_VOTE #(2*N, M, K) m1 (
    .clk (clk),
    .rstn (rstn),
    .en(en_MAJOR_VOTE),
    .new_val (new_val),
    .D_in (out_SRAM),
    .D_out (out_MAJOR_VOTE),
    .get_val (get_val),
    .valid (valid),
    .done (done_MAJOR_VOTE)
);

XOR_OP #(2*N) x1 (
    .clk (clk),
    .rstn (rstn),
    .valid (valid),
    .D_in (out_MAJOR_VOTE),
    .D_out (out_XOR)
);

LFSR #(N) l1 (
    .clk (clk),
    .rstn (rstn),
    .en (en_LFSR),
    .ch (ch),
    .seed_t (seed),
    .gate_t (gate),
    .rp (rp),
    .done (done)
); 

`ifndef SYNTHESIS
reg [2*N-1:0] mem_sim [M];
initial foreach(mem_sim[i]) mem_sim[i] = $random;

function automatic void initialize_mem (input reg [2*N-1:0] mem [M] = mem_sim);
    s1.initialize_mem (mem_sim);
endfunction

function automatic void change_cond (input real temp, input real volt);
    s1.change_cond (.temp(temp), .volt(volt));
endfunction

`endif

endmodule
