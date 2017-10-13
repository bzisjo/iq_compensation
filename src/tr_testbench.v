`timescale 1us / 10ps

module tr_testbench ();
    
    localparam clk_period = 0.0625;
    localparam clk_period_half = 0.03125;
    localparam EXPECT_TAU = 3'd3;

    reg clk_16MHz, rst_b;


    reg signed [3:0] I_in, Q_in; //signed

    wire signed [5:0] e_k_out; //normalized to 8
    wire signed [2:0] tau_out; //normalized to 8
    
    reg [3:0] i_thread [0:8015];
    reg [3:0] q_thread [0:8015];
    
    integer sample_count;

    always begin : clock_toggle_16MHz
        #(clk_period_half);
        clk_16MHz = ~clk_16MHz;
    end

    timing_recovery DUT (
      .clk(clk_16MHz), //16MHz
      .rst_b(rst_b),
      .I_in(I_in), //signed or DC?
      .Q_in(Q_in),
      .e_k_out(e_k_out),
      .tau_out(tau_out)
    );

   
    initial begin : run_sim

        $readmemh("i_thread.bin", i_thread );
        $readmemh("q_thread.bin", q_thread );

        I_in = i_thread[0];
        Q_in = q_thread[0];

        sample_count = 0;
        clk_16MHz = 0;
        rst_b = 0;
        #(clk_period);

        #(7*clk_period);
        rst_b = 1;
        #(clk_period);

        while (sample_count < 8016) begin
            I_in = i_thread[sample_count];
            Q_in = q_thread[sample_count];

            sample_count = sample_count + 1;
            #(clk_period);
        end       

        $display("Current error is %d", e_k_out);
        $display("Expected error is %d", 0);
        $display("Current tau is %d", tau_out);
        $display("Expected tau is %d", EXPECT_TAU);
        $stop;
    end 

endmodule 