module eb1 #(
	parameter WIDTH = 8
) (
	input  clk, reset_n,

	input        [WIDTH-1:0] t0_data,
	input                    t0_valid,
	output logic             t0_ready,

	output logic [WIDTH-1:0] i0_data,
	output logic             i0_valid,
	input                    i0_ready
);

// acknowladge path
assign t0_ready = ~t0_valid | i0_ready;

// data path
always @(posedge clk)
	if( t0_valid & i0_ready )
		i0_data <= t0_data;

// request path
always @(posedge clk or negedge reset_n)
	if(~reset_n)
		i0_valid <= 0;
	else
		i0_valid <= (~i0_ready | t0_valid);

endmodule
