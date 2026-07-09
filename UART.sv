
module UART #(
    parameter N = 8, CLK_SPEED = 100_000_000, BAUD_RATE = 115200) (
    input  clk,
    input  rstn,
    input  en,
    input  [N-1:0] data,
    output logic tx,
    output logic busy,
    output logic done
);

localparam BAUD_DIV = CLK_SPEED / BAUD_RATE;

logic [$clog2(BAUD_DIV)-1:0] baud_cnt;
logic baud_tick;

always @ (posedge clk or negedge rstn) begin
    if (!rstn) begin
        baud_cnt <= 0;
        baud_tick <= 0;
    end
    else begin
        if (baud_cnt == BAUD_DIV-1) begin
            baud_cnt <= 0;
            baud_tick <= 1;
        end
        else begin
            baud_tick <= 0;
            baud_cnt <= baud_cnt + 1;
        end
    end
end

logic [N-1:0] shift_reg;
logic [$clog2(N+1)-1:0] cnt;

enum logic [1:0] {
    IDLE,
    START,
    DATA,
    DONE } state;
    
always @ (posedge clk or negedge rstn) begin
    if (!rstn) begin
        tx <= 1;
        busy <= 0;
        shift_reg <= '0;
        cnt <= '0;
        done <= 0;
        state <= IDLE;
    end
    else begin
        case (state)
            IDLE: begin
                tx <= 1;
                busy <= 0;
                shift_reg <= '0;
                cnt <= '0;
                done <= 0;
                if (en) begin
                    busy <= 1;
                    shift_reg <= data;
                    state <= START;
                end
            end
            
            START: begin
                if (baud_tick) begin
                    tx <= 0;
                    state <= DATA;
                end
            end
            
            DATA: begin
                if (baud_tick) begin
                    tx <= shift_reg[cnt];
                    if (cnt == N-1) state <= DONE;
                    else cnt <= cnt + 1;
                end
            end
            
            DONE: begin
                if (baud_tick) begin
                    tx <= 1;
                    busy <= 0;
                    done <= 1;
                    cnt <= '0;
                    state <= IDLE;
                end
            end
        endcase
    end
end

endmodule