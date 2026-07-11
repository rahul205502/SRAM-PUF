

module PUF_PARAMS #(parameter N=32, M=32, K=17, NUM_PUF=50, NUM_CH=50);

class params;
    real intra_dist; // Similarity between responses for 
                     // same challenge and same PUF 
                     //     - Measures Reproducibility
    real inter_dist; // Variation between response for
                     // same challenge and different PUF
                     //     - Measures Uniqueness
    real rb; // reliability
    real uf; // uniformity
    real uq; // uniqueness
    
    static real intra_whole = 0;
    static real inter_whole = 0;
    
    function new ();
        intra_dist = 0;
        inter_dist = 0;
        rb = 0;
        uf = 0;
    endfunction
    
    function real avg_hd (
        input logic [N-1:0] rp [NUM_PUF]
    );
        reg [$clog2(N*NUM_PUF):0] ones = '0;
        for(int i=0;i<NUM_PUF;i++)
            for(int j=i+1;j<NUM_PUF;j++)
                ones += $countones(rp[i]^rp[j]);
        avg_hd = $itor(ones) / $itor($itor(N * NUM_PUF * (NUM_PUF-1)) / 2); 
    endfunction
  
    function real ref_hd (
        input logic [N-1:0] rp [NUM_PUF]
    ); 
        int unsigned ones = '0;
        foreach (rp[i]) ones += $countones(rp[0] ^ rp[i]);
        ref_hd = $itor(ones) / $itor(N * (NUM_PUF-1));
    endfunction
      
    function void calc_intra_dist (
        input logic [N-1:0] rp [NUM_PUF] 
    );
        intra_dist = ref_hd (rp);    
        intra_whole += intra_dist / $itor(NUM_CH); 
    endfunction
    
    function void calc_inter_dist (
        input logic [N-1:0] rp [NUM_PUF] 
    );
        inter_dist = avg_hd (rp);
        inter_whole += inter_dist / $itor(NUM_CH);
    endfunction
    
    function void calc_rb ();
        rb = (1 - intra_whole) * 100;
    endfunction
    
    function void calc_uf (input logic [N-1:0] rp [NUM_PUF]);
        int unsigned ones = '0;
        foreach (rp[i]) ones += $countones(rp[i]);
        uf = ($itor(ones) / $itor(N * NUM_PUF)) * 100; 
    endfunction
    
    function void calc_uq ();
         uq = inter_whole * 100;
    endfunction
    
    function void display ();
        $display("PUF Parameters");
        $display("Intra Distance between responses (ideally 0): %1.4f", intra_whole);
        $display("Inter Distance between responses  (ideally 0.5): %1.4f", inter_whole);
        $display("Reproducibility (ideally 100%%): %3.4f%%", rb);
        $display("Uniformity (ideally 50%%): %3.4f%%", uf);
        $display("Uniqueness (ideally 50%%): %3.4f%%", uq);
   endfunction
endclass

logic clk;
logic rstn;
logic en;
logic [N-1:0] ch;
logic [N-1:0] rp;
logic done;

PUF_TOP #(N,M,K) puf (.*);

logic [N-1:0] rps [NUM_PUF];
logic [2*N-1:0] mem [M][NUM_PUF];

real temp_st [NUM_PUF];
real volt_st [NUM_PUF];
// real rand_temp, rand_volt;

always #5 clk = ~clk;

// env_var intra_env[NUM_PUF], inter_env[NUM_PUF];
params par;
real p;

initial begin
    clk = 0;
    rstn = 0;
    en = 0;
    foreach (mem[i,j,k]) mem[i][j][k] = $random;
    foreach (rps[i]) rps[i] = '0;
    
    for (integer i=0; i<NUM_PUF; i=i+1) begin
        temp_st[i] = 25+(i*3)%60;
        volt_st[i] = 1.0 - (i%16)*0.025;
    end 
    
    par = new ();
    puf.initialize_mem (mem[0]);
    
    repeat (NUM_CH) begin
        foreach (ch[i]) ch[i] = $random % 2;
        for (int i=0; i<NUM_PUF; i=i+1) begin // for intra distance
            rstn = 0;
            en = 0;
//            puf.s1.sr.calc_err(temp_st[i], volt_st[i]);
            puf.change_cond (.temp(temp_st[i]), .volt(volt_st[i]));
            @(posedge clk) rstn = 1; en = 1;
            @(posedge done); rps[i] = rp; 
            p = puf.get_errProb ();
            $display("temp=%0f, volt=%0f, err Probability=%0f, rp=%h", temp_st[i], volt_st[i], p*100, rp);
            @(posedge clk);
        end
    
        par.calc_intra_dist (rps);
        par.calc_uf (rps);
        par.calc_rb ();
    end
    
    foreach (rps[i]) rps[i] = '0;
    puf.change_cond (.temp(25.0), .volt(1.0));
    
    repeat (NUM_CH) begin
        foreach(ch[i]) ch[i] = $random % 2;
        for (int i=0; i<NUM_PUF; i=i+1) begin
            rstn = 0;
            en = 0;
//            rand_temp = $urandom_range(200,300) / 10;
//            rand_volt = $urandom_range(90,110) / 100;
            puf.initialize_mem(mem[i]);
            // puf.load_mem(inter_env[i].mem);
            @(posedge clk) rstn = 1; en = 1;
            @(posedge done); rps[i] = rp;
            @(posedge clk);
        end
    
        par.calc_inter_dist (rps);
        par.calc_uf (rps);
        par.calc_uq ();
    end
//    foreach (intra_env[i]) intra_env[i].display();
    par.display();
    $finish;
end  

endmodule 

