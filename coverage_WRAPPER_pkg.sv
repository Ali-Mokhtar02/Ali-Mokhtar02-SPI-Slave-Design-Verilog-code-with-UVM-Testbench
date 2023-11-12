package WRAPPER_coverage_pkg;
	import uvm_pkg::*;
	import WRAPPER_seq_item_pkg::*;
	`include "uvm_macros.svh"
	class WRAPPER_coverage extends  uvm_component;
		`uvm_component_utils(WRAPPER_coverage);
		
		uvm_analysis_export #(WRAPPER_seq_item) coverage_exp;
		uvm_tlm_analysis_fifo #(WRAPPER_seq_item) coverage_fifo;
		WRAPPER_seq_item WRAPPER_coverage_seq_item;

		covergroup WRAPPER_cg();
			option.per_instance = 1;
			MOSI_cp: coverpoint WRAPPER_coverage_seq_item.MOSI
			{ 
				bins read_addr_sequence= (0,1 => 1 => 1 => 0 => 0,1[*9] );
				bins read_data_sequence= (0,1 => 1 => 1 => 1 => 0,1[*18]);
				bins write_addr_sequence= (0,1 => 0 => 0 => 0 => 0,1[*9]);
				bins write_data_sequence= (0,1 => 0 => 0 => 1 => 0,1[*9]);
				bins mosilow= {0};
				bins mosihigh= {1};
			}

			ss_n_cp: coverpoint WRAPPER_coverage_seq_item.SS_n
			{
				bins ss_trans1= (0[*12] =>1 );
				bins ss_trans2= (0[*21] =>1);
				bins ss_n_low= {0};
				bins ss_n_high = {1};
			}

			MOSI_Operations: cross MOSI_cp,ss_n_cp 
			{
				bins read_data_Sequenece= binsof(MOSI_cp.read_data_sequence) && binsof(ss_n_cp.ss_trans2) ;
				bins read_add_Sequenece= binsof(MOSI_cp.read_addr_sequence) && binsof(ss_n_cp.ss_trans1) ;
				bins write_add_Sequenece= binsof(MOSI_cp.write_addr_sequence) && binsof(ss_n_cp.ss_trans1) ;
				bins write_data_Sequenece= binsof(MOSI_cp.write_data_sequence) && binsof(ss_n_cp.ss_trans1) ;
				ignore_bins sshigh= binsof(ss_n_cp.ss_n_high);
				ignore_bins sslow= binsof(ss_n_cp.ss_n_low);
				ignore_bins MOSIlow= binsof(MOSI_cp.mosilow);
				ignore_bins MOSIhigh= binsof(MOSI_cp.mosihigh);
				ignore_bins writeadd_ign= binsof(MOSI_cp.write_addr_sequence) && binsof(ss_n_cp.ss_trans2);
				ignore_bins writedata_ign= binsof(MOSI_cp.write_data_sequence) && binsof(ss_n_cp.ss_trans2);
				ignore_bins readadd_ign= binsof(MOSI_cp.read_addr_sequence) && binsof(ss_n_cp.ss_trans2);
				ignore_bins readdata_ign= binsof(MOSI_cp.read_data_sequence) && binsof(ss_n_cp.ss_trans1);
			}
		endgroup

		function new(string name="WRAPPER_coverage", uvm_component parent=null );
			super.new(name,parent);
			WRAPPER_cg=new();
		endfunction : new

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			coverage_exp= new("coverage_exp",this);
			coverage_fifo= new("coverage_fifo",this);
		endfunction: build_phase

		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			coverage_exp.connect(coverage_fifo.analysis_export);

		endfunction: connect_phase

		task run_phase(uvm_phase phase);
			super.run_phase(phase);
			forever begin
				coverage_fifo.get(WRAPPER_coverage_seq_item);
				if(WRAPPER_coverage_seq_item.rst_n)
					WRAPPER_cg.sample();
			end
		endtask : run_phase

	endclass : WRAPPER_coverage
endpackage : WRAPPER_coverage_pkg