
module ECC_ENCODER #(parameter N=8) (clk, rstn, enroll, D_in, D_out, done);
localparam M = $clog2(N);

input clk, rstn, enroll;
input [N-1:0] D_in;
output logic [N+M:0] D_out;
output logic done;

logic [N+M:0] temp;

logic [M:0] parity;
int i,j,pos,p_pos,d_pos;

//always @(posedge clk or negedge rstn) begin
//    if (!rstn) begin
//        D_out <= '0;
//        parity <= '0;
//        pos <= 0;
//        temp <= '0;
        
//    end
//    else begin
//        if (enroll) begin
//            foreach (parity[i]) begin
//                parity[i] = 0;
//                for (j=0; j<N; j++) begin
//                    if (j & 1<<i) parity[i] ^= D_in[j];
//                end
//            end  
//            for (pos=0,i=1; pos<N+M+1; pos++) begin 
//                if (i == pos+1) begin
//                    temp[pos] = parity[p_pos];
//                    p_pos++;
//                    i = i<<1;
//                end
//                else begin  
//                    temp[pos] = D_in[d_pos];
//                    d_pos++;
//                end
//            end
//            D_out = temp;
//        end
//    end
//end

enum logic [1:0] {IDLE, GEN_PARITY, GEN_OUT, DONE} state;
logic [M-1:0] par_addr;

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        D_out <= '0;
        parity <= '0;
        pos <= 0;
        temp <= '0;
        par_addr <= '0;
        done <= 1'b0;
    end
    else begin
        case (state)
            IDLE: begin
                par_addr <= '0;
                if (enroll) state <= GEN_PARITY;
            end
            
            GEN_PARITY: begin
                for (j=0; j<N; j++) 
                    if (j & 1<<i) parity[par_addr] ^= D_in[j];
                if (par_addr == M) begin
                    pos = 0;
                    i = 1;
                    state <= GEN_OUT;
                end
                else par_addr <= par_addr + 1; 
            end
            
            GEN_OUT: begin
                if (i == pos+1) begin
                    temp[pos] = parity[p_pos];
                    p_pos++;
                    i = i<<1;
                end
                else begin
                    temp[pos] = D_in[d_pos];
                    d_pos++;
                end
                if (pos == N+M) state <= DONE;
                else pos <= pos + 1;
            end
            
            DONE: begin
                D_out <= temp;
                done <= 1;
                state <= IDLE;
            end
            
            default: state <= IDLE;
        endcase
    end
end

endmodule