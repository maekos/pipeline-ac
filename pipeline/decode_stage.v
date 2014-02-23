`timescale 1ns / 1ps
////////////////////////////////////////////////
// Module Name:    decode_stage 
// Description: 	Etapa de decodificacion de
//						de la instruccion que proviene
//						desde la etapa fetch.
////////////////////////////////////////////////
module decode_stage(
	 input clk,
	 input rst,
	 input ena,
	 input stop,
	 // Entradas al decode stage
	 input reg_write_in,
	 input [31:0] instruccion,
    input [4:0] WR,
    input [31:0] WD,
	 // Salidas desde el banco de registros
    output [31:0] data1,
    output [31:0] data2,
	 // Salida del modulo extension de signo
    output [31:0] ext_sig,
	 // Salidas de la unidad de control
	 //output Jump, 
	 output [11:0] palabra_salida
    ); 
	 	 
	 register_bank banco (
		.clk(clk),
		.rst(rst),
		.read_register1(instruccion[25:21]), 
		.read_register2(instruccion[20:16]), 
		.write_register(WR), 
		.write_data(WD), 
		.Reg_write(reg_write_in), 
		.busA(data1), 
		.busB(data2)
	);
	
	sign_extended extension_signo (
		.rst(rst),
		.clk(clk),
		.offset(instruccion[15:0]), 
		.extension(ext_sig)
	);
	
	ctrl_unit unidad_control (
		.clk(clk),
		.rst(rst),
		.ena(ena),
		.opcode(instruccion[31:26]),
		.Branch(branch),
		.MemWrite(mem_write), 
		.MemtoReg(mem_to_reg), 
		.RegDst(reg_dst), 
		.RegWrite(reg_write_out), 
		.ALUSrc(alu_src), 
		.AluOp(alu_op)
	);
	
	mux #(.nbits(12)) mux1(
		.rst(rst),
		.dec(stop),
		.msb({branch, mem_write, mem_to_reg, reg_dst, reg_write_out, alu_src, alu_op}),
		.lsb(12'b0),
		.out(palabra_salida)
	);	
	
endmodule