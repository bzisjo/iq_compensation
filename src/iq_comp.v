module iq_comp (
	input clk, RESETn,
	input freeze_iqcomp,				//Should come from Start Signal FSM, freezes W values when on
	input [1:0] op_mode,
	input [3:0] Ix, Qx,
	input signed [12:0] Wr_in, Wj_in,	//Externally supplied W, used when op_mode = EXT_W
	output reg signed [3:0] Iy, Qy,		//Rotated and compensated IQ

	//Debugging signals
	output wire settled,				//Used to tell MCU to store W values
	output reg signed [12:0] Wr, Wj
);

//Declare mode parameters
localparam BYPASS = 2'b00;
localparam INT_W = 2'b01;
localparam EXT_W = 2'b10;

//Convert to signed I,Q
wire signed [3:0] Ix_s;
wire signed [3:0] Qx_s;

//Step value
wire [3:0] M;

//Signals for combinational math
wire signed [12:0] Wr_use;
wire signed [12:0] Wj_use;
wire signed [3:0] I_math;
wire signed [3:0] Q_math;
wire signed [12:0] Wr_math;
wire signed [12:0] Wj_math;

assign settled = freeze_iqcomp;		//Temporary solution

assign M = 4'd11;					//log2(2048) = 11, divide by 2048 -> arithmetic right shift by 11

assign Ix_s = Ix - 4'd8;
assign Qx_s = Qx - 4'd8;


//Choose W used to compensate
assign Wr_use = (op_mode == INT_W) ? Wr : Wr_in;
assign Wj_use = (op_mode == INT_W) ? Wj : Wj_in;

//Combinational logic for compensation calculation
assign I_math = Ix_s + $signed(((Wr_use * Ix_s) + (Wj_use * Qx_s))) >>> M;
assign Q_math = Qx_s + $signed(((Wj_use * Ix_s) - (Wr_use * Qx_s))) >>> M;

//Combinational logic for W update calculation
assign Wr_math = $signed(Wr - ((Iy + Qy) * (Iy - Qy)));
assign Wj_math = $signed(Wj - 2 * Iy * Qy);

always @(posedge clk) begin
	if(~RESETn) begin
		Iy <= 0;
		Qy <= 0;
		Wr <= 0;
		Wj <= 0;
	end else begin
		case (op_mode)
			BYPASS: begin
				Iy <= Ix_s;
				Qy <= Qx_s;
				Wr <= 0;
				Wj <= 0;
			end
			INT_W: begin 
				Iy <= I_math;
				Qy <= Q_math;
				if(freeze_iqcomp) begin 
					Wr <= Wr;
					Wj <= Wj;
				end else begin
					Wr <= Wr_math;
					Wj <= Wj_math;
				end
			end
			EXT_W: begin
				Iy <= I_math;
				Qy <= Q_math;
				Wr <= Wr_use;	//Output the same W that's fed in
				Wj <= Wj_use;	//Output the same W that's fed in
			end
			2'b11: begin		//Same as BYPASS
				Iy <= Ix_s;
				Qy <= Qx_s;
				Wr <= 0;
				Wj <= 0;
			end
			default : /* default */;
		endcase
	end
end


endmodule // iq_comp