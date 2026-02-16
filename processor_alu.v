`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:21:03 02/09/2026 
// Design Name: 
// Module Name:    processor_alu 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module processor_alu #(
	DATA_WIDTH = 32
	)(
	input wire [DATA_WIDTH-1:0] A,
	input wire [DATA_WIDTH-1:0] B,
	input wire [2:0] aluctrl,
	output reg [DATA_WIDTH-1:0] Z,
	output reg overflow
	);

	always @(*) begin
		Z = {DATA_WIDTH{1'b0}};
		overflow = 1'b0;
		
		case (aluctrl)
			3'b000 : begin
				Z = A + B;
				overflow = A[DATA_WIDTH-1] & B[DATA_WIDTH-1];
			end
			3'b001 : begin
				Z = A - B;
			end
			3'b010 : begin
				Z = A & B;
			end
			3'b011 : begin
				Z = A | B;
			end
			3'b100 : begin
				Z = A ^ B;
			end
			3'b101 : begin
				Z = A == B;
			end
			3'b110 : begin
				Z = {A[DATA_WIDTH-2:0], {1'b0}};
			end
			3'b111 : begin
				Z = {{1'b0}, A[DATA_WIDTH-1:1]};
			end
			default : begin
				Z = {DATA_WIDTH{1'b0}};
				overflow = 1'b0;
			end
		
		endcase
	end

endmodule
