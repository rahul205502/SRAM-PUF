
module debouncer #(parameter MAX_COUNT = 20_000_000) (
    input clk, rstn, en,
    output en_db
);

reg [$clog2(MAX_COUNT):0] count;
reg en_prev;

always @(posedge clk) begin
    if (!rstn) begin
        en_db <= 1'b0;
        en_prev <= 1'b0;
    end
    else begin
        if (en != en_prev) en_prev <= en;
        else if (e