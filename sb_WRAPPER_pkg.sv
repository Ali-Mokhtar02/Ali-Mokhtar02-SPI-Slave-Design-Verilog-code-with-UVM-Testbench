package WRAPPER_scoreboard_pkg;
	import uvm_pkg::*;
	import WRAPPER_seq_item_pkg::*;
	`include "uvm_macros.svh"
	class WRAPPER_scoreboard extends  uvm_scoreboard;
		`uvm_component_utils(WRAPPER_scoreboard);
		uvm_analysis_export #(WRAPPER_seq_item) sb_exp;
		uvm_tlm_analysis_fifo #(WRAPPER_seq_item) sb_fifo;
		WRAPPER_seq_item WRAPPER_sb_seq_item;

		int error_count=0;
		int correct_count=0;

		function  new(string name="WRAPPER_scoreboard", uvm_component parent=null );
			super.new(name,parent);
		endfunction : new

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			sb_exp= new("sb_exp",this);
			sb_fifo= new("sb_fifo",this);
		endfunction: build_phase

		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			sb_exp.connect(sb_fifo.analysis_export);

		endfunction: connect_phase

		task run_phase(uvm_phase phase);
			super.run_phase(phase);
			forever begin
				sb_fifo.get(WRAPPER_sb_seq_item);
				if(WRAPPER_sb_seq_item.MISO !== WRAPPER_sb_seq_item.MISO_expected) begin
					error_count++;
					`uvm_error("sb_run_phase", $sformatf("error happened with dout signal input values are %s dout is %0h and the golden model output is %0h", WRAPPER_sb_seq_item.convert2string_stimulus(),WRAPPER_sb_seq_item.MISO ,WRAPPER_sb_seq_item.MISO_expected) )
				end
				else
					correct_count++;
			end
		endtask : run_phase

		function void report_phase(uvm_phase phase);
			super.report_phase(phase);
			`uvm_info("report_phase",$sformatf("total success are %0d",correct_count),UVM_LOW);
			`uvm_info("report_phase",$sformatf("total erorrs are %0d",error_count),UVM_LOW);
		endfunction: report_phase

	endclass : WRAPPER_scoreboard
endpackage : WRAPPER_scoreboard_pkg