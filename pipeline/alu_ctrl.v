`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:22:32 11/25/2013 
// Design Name: 
// Module Name:    alu_ctrl 
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
module alu_ctrl(
    input [3:0] ff,
    input [5:0] aluOp,
    output reg [3:0] operation
    );
	 
	 always @(*) begin
		if(aluOp[5]) begin
			case (aluOp[4:2]) 
				3'b000: begin
						  operation <= 4'b0010; // ADD
						  end
				3'b001: begin
						  operation <= 4'b0010; // ADDI
						  end
				3'b010: begin
						  operation <= 4'b0111; // SLTI
						  end
				3'b011: begin
						  operation <= 4'b0111; // SLTIU
						  end
				3'b100: begin
						  operation <= 4'b0000; // AND
						  end
				3'b101: begin
						  operation <= 4'b0001; // OR
						  end
				3'b110: begin
						  operation <= 4'b0110; // XOR
						  end
				3'b111: begin
						  operation <= 4'b0010; // LUI
						  end
			endcase
		end
		else begin
			operation[0] <= (ff[0] || ff[3]) && (aluOp[1]);
			operation[1] <= ~(ff[2]) || ~(aluOp[1]);
			operation[2] <= (aluOp[1] && ff[1]) || aluOp[0];
			operation[3] <= 0;
		end
	end 
	
endmodule
