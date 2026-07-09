
module LFSR #(parameter N=8)(
    input  logic clk,
    input  logic rstn,
    input  logic en,
    input  logic [N-1:0] ch,
    input  logic [N-1:0] seed_t,
    input  logic [N-1:0] gate_t,
    output logic [N-1:0] rp,
    output logic done
);

reg [N-1:0] mem, seed, gate;
reg [$clog2(N):0] addr;

enum logic [1:0] {
IDLE,
LOAD,
SHIFT,
DONE } state;

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        mem <= 0;
        addr <= 0;
        rp <= 0;
        done <= 0;
        state <= IDLE;
    end
    else begin
        done <= 0;
        case (state)
            IDLE: begin
                addr <= '0;
//                seed <= '0;
//                gate <= '0;
                if (en) begin
                    seed <= seed_t;
                    gate <= gate_t;
                    state <= LOAD;
                end
            end
            LOAD: begin
                mem <= seed;
                state <= SHIFT;
            end
            SHIFT: begin
                mem <= {ch[addr]^(^(gate & mem)), mem[N-1:1]};
                if (addr == N-1) state <= DONE;
                else addr <= addr + 1;
            end
            DONE: begin
                rp <= mem;
                done <= 1;
                state <= IDLE;
            end
            default: state <= IDLE;
        endcase
    end
end

endmodule