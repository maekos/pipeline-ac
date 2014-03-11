`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23/03/2014 
// Design Name: 
// Module Name:    pipeline 
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
 
module pipeline(
		input clk,
		input rst,
		input enable
    );
	 
	 wire stop;
	 wire [6:0] pc_out;
	 wire [6:0] branch_pc ;
	 wire [31:0] DR;
	 wire stop_enable;
	 wire [31:0] data1;
	 wire [31:0] data2;
	 wire [31:0] ext_sig;
	 wire [11:0] palabra;
	 wire equals;
	 assign equals = ((data1 ~^ data2) & palabra[11]); // Para chequear que los datos son iguales en la salida del banco de registros.
	
	 
	 assign stop_enable = enable & (~stop);
	 
	 /* Bloque de busqueda de instruccion */
	fetch_stage ifetch (
		.clk(~clk), // conectado
		.dec(equals), // conectado
		.rst(rst), 
		.enbl(stop_enable),
		.pc_mux(branch_pc), // conectado
		.pc_out(pc_out),  // conectado
		.DR(DR) // conectado
	); 
	
	 
	 /* Latch entre ifetch e idecode*/
	 wire ena_id;
	 wire [6:0] next_pc_reg;
	 wire [31:0] instruction_reg;
	 
	 latch_if_id if_id (
		.clk(clk), //conectado
		.rst(rst),
		.ena(enable),
		.stop(stop),
		.next_pc(pc_out), // conectado
		.instruction(DR), // conectado
		.ena_if_id_reg(ena_id), //conectado
		.next_pc_reg(next_pc_reg), //conectado
		.instruction_reg(instruction_reg) //conectado
	);
	
	/* bloque de etapa decode */
	 wire reg_write_in;
	 wire [4:0] WR;
	 wire [31:0] WD;
	 
	 
	 decode_stage decode (
		.clk(~clk), 
		.rst(rst),
		.stop(stop),
		.ena(ena_id),
		.reg_write_in(reg_write_in), // conectado
		.instruccion(instruction_reg), //conectado
		.WR(WR), // Conectado
		.WD(WD), // Conectado
		.data1(data1), // Conectado
		.data2(data2), // Conectado
		.ext_sig(ext_sig), // Conectado
		.palabra_salida(palabra) //  VERIFICAR!!
	);
	
	branch_sum next_hop (
		.rst(rst),
		.pc_next(next_pc_reg), 
		.pc_branch(ext_sig[6:0]), 
		.branch_pc(branch_pc)
	 );
	
	/* Latch entre idecode e iexecute */
	 wire [4:0] rs;
	 wire [4:0] rt;
	 wire [31:0] data1_ex;
	 wire [31:0] data2_ex;
	 wire [31:0] sign_extend_ex;
	 wire mem_write_ex;
	 wire mem_to_reg_ex;
	 wire reg_dst_ex;
	 wire reg_write_ex;
	 wire alu_src_ex;
	 wire [5:0] alu_op_ex;
	 wire [4:0] reg1_ex;
	 wire [4:0] reg2_ex;
	 
	latch_id_ex id_ex (
		.alu_op(palabra[5:0]), // Conectado
		.reg_dst(palabra[8]), // Conectado
		.alu_src(palabra[6]), // Conectado
		.mem_write(palabra[10]), // Conectado
		.reg_write(palabra[7]), // Conectado 
		.mem_to_reg(palabra[9]), // Conectado
		.data1(data1), // Conectado
		.data2(data2), // Conectado
		.sign_extend(ext_sig), // Conectado 
		.reg1(instruction_reg[20:16]),  // Conectado
		.reg2(instruction_reg[15:11]), // Conectado
		.rs(instruction_reg[25:21]),
		.rt(instruction_reg[20:16]),
		.clk(clk), // Conectado
		.rst(rst),
		.alu_op_reg(alu_op_ex), //Conectado 
		.reg_dst_reg(reg_dst_ex), //Conectado
		.alu_src_reg(alu_src_ex), //Conectado
		.mem_write_reg(mem_write_ex), //Conectado
		.reg_write_reg(reg_write_ex), //Conectado
		.mem_to_reg_reg(mem_to_reg_ex), //Conectado
		.data1_reg(data1_ex), //Conectado
		.data2_reg(data2_ex), //Conectado
		.sign_extend_reg(sign_extend_ex), //Conectado 
		.reg1_reg(reg1_ex), //Conectado
		.reg2_reg(reg2_ex), //Conectado
		.rs_reg(rs),
		.rt_reg(rt)
	);
	/* Wires de la unidad de cortocircuito */
	wire [1:0] cortoA;
	wire [1:0] cortoB;
	wire [31:0] cortoA_out;
	wire [31:0] cortoB_out;
	
	/* bloque de etapa execute */
	wire [31:0] alu_result;
	wire [31:0] data2_out;
	wire [4:0] dst;

	execute_stage execute (
		.rst(rst),
		.alu_src(alu_src_ex), //Conectado
		.alu_op(alu_op_ex), //Conectado
		.reg_dst(reg_dst_ex), //Conectado 
		.data1(cortoA_out), //Conectado 
		.data2(cortoB_out), //Conectado
		.sign_extend(sign_extend_ex), //Conectado 
		.reg1(reg1_ex), //Conectado 
		.reg2(reg2_ex), //Conectado
		.alu_result(alu_result), //Conectado
		.data2_out(data2_out), //Conectado
		.dst(dst) //Conectado
	);
	

	/* Latch etapa execute memory */
	wire mem_to_reg_m; 
   wire reg_write_m; 
	wire mem_write_m; 
	wire [31:0] alu_result_m; 
	wire [31:0] data2_m; 
	wire [4:0] dst_m;
	
	latch_ex_m ex_m (
		.mem_to_reg(mem_to_reg_ex), //Conectado
		.reg_write(reg_write_ex), //Conectado
		.mem_write(mem_write_ex), //Conectado
		.alu_result(alu_result), //Conectado 
		.data2(data2_out), //Conectado 
		.dst(dst), //Conectado
		.clk(clk), //Conectado
		.rst(rst),
		.mem_to_reg_reg(mem_to_reg_m), //Conectado
		.reg_write_reg(reg_write_m), //Conectado
		.mem_write_reg(mem_write_m), //Conectado
		.alu_result_reg(alu_result_m), //Conectado
		.data2_reg(data2_m), //Conectado
		.dst_reg(dst_m) //Conectado
	);
	
	/* bloque de etapa memoria */
	wire [31:0] data_out;
	
	mem_stage mem (
		.no_clk(~clk), //Conectado 
		//.rst(rst),
		.mem_write(mem_write_m), //Conectado
		.address(alu_result_m[4:0]), //Conectado 
		.write_data(data2_m), //Conectado 
		.data_out(data_out) //Conectado
	);
	
	/* Latch imem e iwb */
	wire mem_to_reg_wb;
	wire [31:0] alu_result_wb;
	wire [31:0] data_load_wb;
	
	latch_m_wb m_wb (
		.reg_write(reg_write_m), //Conectado 
		.mem_to_reg(mem_to_reg_m), //Conectado
		.alu_result(alu_result_m), //Conectado 
		.data_load(data_out), //Conectado 
		.dst(dst_m), //Conectado
		.clk(clk), //Conectado 
		.rst(rst),
		.reg_write_reg(reg_write_in), // conectado 
		.mem_to_reg_reg(mem_to_reg_wb), //Conectado
		.alu_result_reg(alu_result_wb), //Conectado
		.data_load_reg(data_load_wb), //Conectado
		.dst_reg(WR) // Conectado
	);
	
	/* bloque de etapa write back */
	
	wb_stage wb (
		.rst(rst),
		.mem_to_reg(mem_to_reg_wb), //Conectado 
		.data_in(data_load_wb), //Conectado 
		.dir(alu_result_wb), //Conectado 
		.data_out(WD) // Conectado
	);
	
	//_-_-_-_-_-_-_Unidad de Cortocircuito_-_-_-_-_-_-_-_//
	
	forwarding unidadCorto(
		.rs(rs), 
		.rt(rt), 
		.dst_mem(dst_m), 
		.dst_wb(WR), 
		.wb_mem(reg_write_m), 
		.wb_wb(reg_write_in), 
		.cortoA(cortoA), 
		.cortoB(cortoB)
	);
	
	mux4 rs_cortoA (
		.rst(rst),
		.in00(data1_ex), 
		.in01(alu_result_m), 
		.in02(WD), 
		.in03(alu_result_m), 
		.signal(cortoA), 
		.out_mux4(cortoA_out)
	);
	
	mux4 rt_cortoB (
		.rst(rst),
		.in00(data2_ex), 
		.in01(alu_result_m), 
		.in02(WD), 
		.in03(alu_result_m), 
		.signal(cortoB), 
		.out_mux4(cortoB_out)
	);

	//_-_-_-_-_-_-_-_-Unidad de Detección de Riesgos de Datos-_-_-_-_-_-_-_-_-_//

	hazard data_hazard (
		.rst(rst),
		.instruction(instruction_reg[31:16]), 
		.rt_ex(rt), 
		.mem_to_reg_ex(mem_to_reg_ex), 
		.stop(stop)
	);

endmodule