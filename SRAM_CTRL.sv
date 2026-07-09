
module SRAM_CTRL #(parameter N=8, M=8, K=9) (
    input clk, rstn, en, get_val,
    output logic [N-1:0] out,
    output logic new_val, done
);

logic [$clog2(M)-1:0] addr;
logic [$clog2(K)-1:0] addr_mv;
logic rd_en;
//logic [N-1:0] sram_out;

SRAM #(N,M) sr (.clk(clk), .rstn(rstn), .en(en), .clr(1'b0), 
                .addr(addr), .rd_en(rd_en), .out(out));

// assign new_val = rd_en;

enum logic [2:0] {IDLE, DELAY, TRANSFER, MV_LOOP, DONE} state;
                  
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        // out <= '0;
        rd_en <= 1'b0;
        new_val <= 1'b0;
        done <= 1'b0;
        // done_mv <= 1'b0;
        addr <= '0;
        addr_mv <= '0;
        state <= IDLE;
    end
    else begin
        done <= 1'b0;
        // done_mv <= 1'b0;
        new_val <= 1'b0;
        case (state)
            IDLE: begin
                addr <= '0;
                addr_mv <= '0;
                if (en) state <= DELAY;
            end
            
            DELAY: begin
                if (get_val) begin
                    rd_en <= 1'b1;
                    state <= TRANSFER;
                end
            end
            
            TRANSFER: begin
                // rd_en <= 1'b1;
                // out <= sram_out;
                new_val <= 1;
                rd_en <= 1'b0;
                if (addr_mv == K-1) begin
                    addr_mv <= '0;
                    // done_mv <= 1'b1;
                    state <= MV_LOOP;
                end
                else begin
                    addr_mv += 1;
                    state <= DELAY;
                end
            end
            
            MV_LOOP: begin
                if (addr == M-1) begin
                    // done <= 1'b1;
                    // state <= IDLE;
                    addr <= '0;
                    state <= DONE;
                end
                else begin
                    addr += 1'b1;
                    state <= DELAY;
                end
            end
            
            DONE: begin
                done <= 1'b1;
                state <= IDLE;
            end
            
            default: state <= IDLE;
        endcase
    end
end

`ifndef SYNTHESIS

function automatic void initialize_mem (input reg [N-1:0] mem [M]);
     sr.initialize_mem (.mem_t(mem));
endfunction

function automatic void change_cond (input real temp=25.0, input real volt=1.0);
    sr.change_cond (.temp_t(temp), .volt_t(volt));
endfunction

function real get_errProb ();
    get_errProb = sr.err_prob ();
endfunction

`endif

endmodule