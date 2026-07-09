
module SRAM #(parameter N=8, M=8) (
    input clk, rstn, en, clr, rd_en,
    input [$clog2(M)-1:0] addr,
    output logic [N-1:0] out
);

reg [N-1:0] mem [M];

`ifndef SYNTHESIS real temp=25.0; real volt=1.0; `endif

always @ (posedge clk or negedge rstn) begin
    if (!rstn) out <= '0;
    else begin
        `ifndef SYNTHESIS 
            if (rd_en) out <= corrupt(mem[addr], temp, volt);
        `else
            if (rd_en) out <= mem[addr];
        `endif
        if (clr) mem[addr] <= 0;
    end
end

`ifndef SYNTHESIS
    real p;
    
    function real err_prob ();
        err_prob = p;
    endfunction
    
    function real abs (
        input real x=0
    );
        abs = (x>=0) ? x : -x;
    endfunction
    
    function reg [N-1:0] corrupt (
        input reg [N-1:0] data,
        input real temp=25.0, 
        input real volt=1.0
    );        
        real r;
        corrupt = data;
        p = 0.002
          + 0.005 * abs(temp - 25.0)
          + 0.05  * abs(1.0 - volt);
        
        if (p>0.4) p=0.4;
        // $display("%0h", data);
        foreach (corrupt[i]) begin
            r = $urandom_range(0,1000000) / 1000000.0;
            if (p>r) corrupt[i] = ~corrupt[i];
        end
    endfunction

    function void change_cond (
        input real temp_t, 
        input real volt_t
    );
        temp = temp_t;
        volt = volt_t;
    endfunction
        
    function void initialize_mem (
        input reg [N-1:0] mem_t [M]
    );
        mem = mem_t;
    endfunction
    
`endif  

endmodule
