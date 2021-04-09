// create module
module top (
	input logic clk,      // 50MHz input clock
	output logic[7:0] LED //  array of 8 LEDs
);

logic[31:0] cnt;

initial begin
	cnt <= 32'h00000000; // start at zero
end

always @(posedge clk) begin
	cnt <= cnt + 1; // count up
end

assign LED = cnt[28:21];

endmodule
