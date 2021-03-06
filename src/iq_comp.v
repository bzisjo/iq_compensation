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
localparam CONT_W = 2'b11;				//Not yet implemented. Same as Bypass.

//Convert to signed I,Q
wire signed [3:0] Ix_s;
wire signed [3:0] Qx_s;

//Step value
wire [3:0] M;

//Signals for combinational math
wire signed [12:0] Wr_use;
wire signed [12:0] Wj_use;
reg signed [3:0] I_math;
reg signed [3:0] Q_math;
wire signed [12:0] Wr_math;
wire signed [12:0] Wj_math;

wire signed [25:0] I_math_intermediate1;
wire signed [25:0] Q_math_intermediate1;
wire signed [4:0] I_math_intermediate2;
wire signed [4:0] Q_math_intermediate2;
wire signed [25:0] Ix_s_shifted;
wire signed [25:0] Qx_s_shifted;

assign settled = freeze_iqcomp;		//Temporary solution

assign M = 4'd9;					//log2(512) = 9, divide by 512 -> arithmetic right shift by 9

assign Ix_s = Ix - 4'd8;
assign Qx_s = Qx - 4'd8;

//Choose W used to compensate
assign Wr_use = (op_mode == INT_W) ? Wr : Wr_in;
assign Wj_use = (op_mode == INT_W) ? Wj : Wj_in;

assign Ix_s_shifted = $signed(Ix_s) <<< M;
assign Qx_s_shifted = $signed(Qx_s) <<< M;

assign I_math_intermediate1 = Ix_s_shifted + $signed(((Wr_use * Ix_s) + (Wj_use * Qx_s)));
assign Q_math_intermediate1 = Qx_s_shifted + $signed(((Wj_use * Ix_s) - (Wr_use * Qx_s)));

assign I_math_intermediate2 = $signed(I_math_intermediate1) >>> M;
assign Q_math_intermediate2 = $signed(Q_math_intermediate1) >>> M;

// assign I_math = Ix_s + $signed($signed(((Wr_use * Ix_s) + (Wj_use * Qx_s))) >>> M);
// assign Q_math = Qx_s + $signed($signed(((Wj_use * Ix_s) - (Wr_use * Qx_s))) >>> M);

always @(*) begin
	if($signed(I_math_intermediate2) < $signed(0-5'd8)) begin
		I_math = $signed(-4'd8);
	end
	else if($signed(I_math_intermediate2) > $signed(5'd7)) begin
		I_math = $signed(4'd7);
	end
	else begin
		I_math = $signed(I_math_intermediate2);
	end

	if($signed(Q_math_intermediate2) < $signed(0-5'd8)) begin
		Q_math = $signed(-4'd8);
	end
	else if($signed(Q_math_intermediate2) > $signed(5'd7)) begin
		Q_math = $signed(4'd7);
	end
	else begin
		Q_math = $signed(Q_math_intermediate2);
	end
end

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
			CONT_W: begin		//Same as BYPASS
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


//Combinational logic for compensation calculation
/*wire signed [18:0] product1;
wire signed [18:0] product2;
wire signed [18:0] product3;
wire signed [18:0] product4;
wire signed [18:0] sum1;
wire signed [18:0] sum2;
wire signed [18:0] shifted1;
wire signed [18:0] shifted2;

assign product1 = Wr_use * Ix_s;
assign product2 = Wj_use * Qx_s;
assign product3 = Wj_use * Ix_s;
assign product4 = Wr_use * Qx_s;

assign sum1 = (product1 + product2);
assign sum2 = (product3 - product4);

assign shifted1 = $signed($signed(sum1) >>> M);
assign shifted2 = $signed($signed(sum2) >>> M);

assign I_math = Ix_s + shifted1;
assign Q_math = Qx_s + shifted2;*/

//Combinational logic for W update calculation
/*wire signed [4:0] IplusQ;
wire signed [4:0] IminusQ;
wire signed [12:0] IQprod1;
wire signed [12:0] IQprod2;

assign IplusQ = Iy + Qy;
assign IminusQ = Iy - Qy;
assign IQprod1 = IplusQ * IminusQ;
assign IQprod2 = 2 * Iy * Qy;

assign Wr_math = Wr - IQprod1;
assign Wj_math = Wj - IQprod2;*/