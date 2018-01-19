// state d0 d1  tready    ivalid  en0 en1  sel
// 0     x  x   1       0     valid 0    ?
// 1     0  x   1       1     0   valid  0
// 2     0  1   0       1     0   0    0
// 3     x  0   1       1     valid 0    1
// 4     1  0   0       1     0   0    1

module eb1_5 #(
	parameter WIDTH = 8,
	parameter S0 = 3'o0,
	parameter S1 = 3'o1,
	parameter S2 = 3'o2,
	parameter S3 = 3'o3,
	parameter S4 = 3'o4
) (
	input  clk, reset_n,

	input         [WIDTH-1:0] t0_data,
	input                     t0_valid,
	output logic              t0_ready,

	output logic  [WIDTH-1:0] i0_data,
	output logic              i0_valid,
	input                     i0_ready
);

// -------------------------------------------------------------------
// Elastic controller
logic sel, en0, en1, valid, ready;

assign valid = t0_valid; // any type of validuest
assign ready = i0_ready; // any type of readynowledge

// State machine
logic [2:0] state, nxt_state;

always_ff @(posedge clk or negedge reset_n)
	if(~reset_n)
		state <= 0;
	else
		state <= nxt_state;

always_comb
	casez({state, valid, ready})
		{S0, 2'b1?} : nxt_state = S1;

		{S1, 2'b01} : nxt_state = S0;
		{S1, 2'b10} : nxt_state = S2;
		{S1, 2'b11} : nxt_state = S3;

		{S2, 2'b?1} : nxt_state = S3;

		{S3, 2'b01} : nxt_state = S0;
		{S3, 2'b10} : nxt_state = S4;
		{S3, 2'b11} : nxt_state = S1;

		{S4, 2'b?1} : nxt_state = S1;

		default       nxt_state = state;
	endcase

assign sel = ((state==S3) | (state==S4));
assign en0 = ((state==S0) | (state==S3)) & valid;
assign en1 =  (state==S1)                & valid;

assign t0_ready = ~((state==S2) | (state==S4));

// validuest path
assign i0_valid = ~(state==S0);

// -------------------------------------------------------------------
// data path
logic [WIDTH-1:0] dat0, dat1;

always_ff @(posedge clk) if(en0) dat0 <= t0_data;
always_ff @(posedge clk) if(en1) dat1 <= t0_data;

assign i0_data = sel ? dat1 : dat0;

endmodule
