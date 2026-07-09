
module MAJOR_VOTE #(parameter N=8, M=8, K=9) (
input clk, rstn, en, new_val, 
input [N-1:0] D_in,
output logic [N-1:0] D_out,
output logic get_val, valid, done
);

// logic [N-1:0] mem;
logic [$clog2(M):0] addr;
logic [$clog2(K):0] addr_mv;
logic [N-1:0][$clog2(K):0] cnt;

enum logic [2:0] {IDLE, CLEAR_CNT, GET_VAL, COMPUTE, DECIDE, DONE} state;

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
//        mem <= '0;
        addr <= '0;
        addr_mv <= '0;
        cnt <= '0;
        D_out <= '0;
        get_val <= 1'b0;
        done <= 1'b0;
        state <= IDLE;
    end
    else begin
    done <= 1'b0;
    valid <= 1'b0;
    case (state)
        IDLE: begin
//            mem <= '0;
            addr <= '0;
            addr_mv <= '0;
            if (en) state <= CLEAR_CNT;
        end
        
        CLEAR_CNT: begin
            cnt <= '0;
            state <= GET_VAL;
        end
            
        GET_VAL: begin
            get_val <= 1'b1;
            // state <= READ;
            state <= COMPUTE;
        end
        
        // READ: begin
            // mem <= D_in;
            // get_val <= 1'b0;
            // state <= COMPUTE;
        // end
        
        COMPUTE: begin
            if (new_val) begin 
                foreach (D_in[i]) if (D_in[i]==1'b1) cnt[i] += 1'b1;
                get_val <= 1'b0;
                if (addr_mv == K-1) begin
                    addr_mv <= '0;
                    state <= DECIDE;
                end
                else begin
                    addr_mv += 1'b1;
                    state <= GET_VAL;
                end
            end
        end
        
        DECIDE: begin
            foreach (D_out[i]) D_out[i] <= (cnt[i] > (K-1)/2);
            valid <= 1'b1;
            if (addr == M-1) begin
                addr <= '0;
                state <= DONE;
            end
            else begin
                addr += 1'b1;
                state <= CLEAR_CNT;
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

endmodule