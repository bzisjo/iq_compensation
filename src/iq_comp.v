module iq_comp (
	input clk, RESETn, en, bypass,
	input [3:0] Ix, Qx,
	output reg signed [3:0] Iy, Qy,

	//Debugging signals
	output reg signed [3:0] Wr, Wj
);

wire signed [3:0] Ix_s;
wire signed [3:0] Qx_s;
wire M;

assign M = 

assign Ix_s = Ix - 4'd8;
assign Qx_s = Qx - 4'd8;

always @(posedge clk) begin
	if(~RESETn) begin
		Iy <= 0;
		Qy <= 0;
		Wr <= 0;
		Wj <= 0;
	end else begin
		if(bypass) begin
			Wr <= 0;
			Wj <= 0;
			Iy <= Ix_s;
			Qy <= Qx_s;
		end
	end
end

endmodule // iq_comp