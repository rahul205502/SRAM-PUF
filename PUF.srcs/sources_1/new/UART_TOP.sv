
module PUF_UART_TOP 
#(parameter N=8, M=8, K=9,
    CLK_SPEED = 10_000_000, BAUD_RATE = 115200,
    MAX_CH = 1<<N) (
    input  clk,
    input  rstn,
    input  en,
    output logic tx,
    output logic busy,
    output logic done
);

logic [N-1:0] ch, rp;
logic en_PUF, en_UART;
logic done_PUF, done_UART;

PUF_TOP #(N,M,K) p1 (
    .clk (clk),
    .rstn (rstn),
    .en (en_PUF),
    .ch (ch),
    .rp (rp),
    .done (done_PUF)
);

UART #(N, CLK_SPEED, BAUD_RATE) u1 (
    .clk (clk),
    .rstn (rstn),
    .en (en_UART),
    .data (rp),
    .tx (tx), 
    .busy (busy),
    .done (done_UART)
);

enum logic [2:0] {
IDLE,
PUF_EN,
PUF_DONE_WAIT,
UART_EN,
UART_DONE_WAIT,
DONE } state;

always @ (posedge clk or negedge rstn) begin
    if (!rstn) begin
        en_UART <= 0;
        en_PUF <= 0;
        ch <= 0;
        done <= 0;
        state <= IDLE;
    end
    else begin
    case (state)
        IDLE: begin
            en_UART <= 0;
            en_PUF <= 0;
            ch <= '0;
            done <= 0;
            if (en) state <= PUF_EN;
        end
        
        PUF_EN: begin 
            en_PUF <= 1;
            state <= PUF_DONE_WAIT;
        end
        
        PUF_DONE_WAIT: begin
            en_PUF <= 0;
            if (done_PUF) state <= UART_EN;
        end
        
        UART_EN: begin
            en_UART <= 1;
            state <= UART_DONE_WAIT;
        end
        
        UART_DONE_WAIT: begin
            en_UART <= 0;
            if (done_UART) begin
                if (ch == MAX_CH-1) state <= DONE;
                else begin
                    ch <= ch + 1;
                    state <= PUF_EN;
                end
            end
        end
        
        DONE: begin
            done <= 1;
            state <= IDLE;
        end
        
        default: state <= IDLE;
    endcase
    end
end

endmodule