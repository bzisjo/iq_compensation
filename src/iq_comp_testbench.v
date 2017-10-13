`timescale 1us / 10ps
module iq_comp_testbench();

	localparam clk_period = 0.0625;
	localparam clk_period_half = 0.03125;

	integer sample_count;

	reg clk_16MHz, RESETn;

	reg [3:0] Ix, Qx;
	reg freeze_iqcomp;
	reg [1:0] op_mode;
	reg signed [12:0] Wr_in, Wj_in;
	wire signed [3:0] Iy, Qy;
	wire settled;
	wire signed [12:0] Wr, Wj;

	reg [3:0] i_thread [0:4999];
	reg [3:0] q_thread [0:4999];
	reg signed [3:0] i_out_thread [0:4999];
	reg signed [3:0] q_out_thread [0:4999];

	always begin : clock_toggle_16MHz
		#(clk_period_half);
		clk_16MHz = ~clk_16MHz;
	end // clock_toggle_16MHz

	iq_comp DUT(
		.clk          (clk_16MHz),
		.RESETn       (RESETn),
		.freeze_iqcomp(freeze_iqcomp),
		.op_mode      (op_mode),
		.Ix           (Ix),
		.Qx           (Qx),
		.Wr_in        (Wr_in),
		.Wj_in        (Wj_in),
		.Iy           (Iy),
		.Qy           (Qy),
		.settled      (settled),
		.Wr           (Wr),
		.Wj           (Wj)
	);

	initial begin : run_sim

		$readmemh("i_thread.dat", i_thread);
		$readmemh("q_thread.dat", q_thread);

		Ix = i_thread[0];
		Qx = q_thread[0];

		sample_count = 0;
		clk_16MHz = 1;
		RESETn = 0;
		freeze_iqcomp = 0;
		op_mode = 2'b01;
		Wr_in = 13'd0;
		Wj_in = 13'd0;
		#(clk_period);

		#(7*clk_period);
		RESETn = 1;
		#(clk_period);
		while (sample_count < 5000) begin
			Ix = i_thread[sample_count];
			Qx = q_thread[sample_count];
			sample_count = sample_count + 1;
			#(clk_period);
			i_out_thread[sample_count] = Iy;
			q_out_thread[sample_count] = Qy;
		end // while (sample_count < 5000)

		$writememh("i_out_thread.dat", i_out_thread);
		$writememh("q_out_thread.dat", q_out_thread);

	end

endmodule // iq_comp_testbench