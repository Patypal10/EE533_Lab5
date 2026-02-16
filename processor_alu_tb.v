`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:37:09 02/09/2026
// Design Name:   processor_alu
// Module Name:   C:/Documents and Settings/student/Desktop/lab5_alu/processor_alu_tb.v
// Project Name:  lab5_alu
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: processor_alu
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module processor_alu_tb;

	// Inputs
	reg [31:0] A, B;
	wire [31:0] Z;
	reg [2:0] aluctrl;
	wire overflow;

	// Instantiate the Unit Under Test (UUT)
	processor_alu uut (
		.A(A),
		.B(B),
		.Z(Z),
		.aluctrl(aluctrl),
		.overflow(overflow)
	);

	initial begin
		// Initialize Inputs
		A = 0;
		B = 0;
		aluctrl = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		A = 32'h0123;
		B = 32'h2222;
		aluctrl = 3'b000;
		#20;
		A = 32'hAAAA;
		B = 32'h5555;
		aluctrl = 3'b001;
		#20;
		A = 32'hF0F0;
		B = 32'h68CD;
		aluctrl = 3'b010;
		#20
		A = 32'hF0A1;
		B = 32'h4F81;
		aluctrl = 3'b011;
		#20;
		A = 32'h0006;
		B = 32'h000C;
		aluctrl = 3'b100;
		#20;
		A = 32'h1111;
		B = 32'h1111;
		aluctrl = 3'b101;
		#20;
		A = 32'h0001;
		B = 32'h0000;
		aluctrl = 3'b110;
		#20;
		A = 32'h8000;
		B = 32'h0000;
		aluctrl = 3'b111;
		#20;
		$finish;

	end
      
endmodule

