package WRAPPER_monitor_pkg;
	import uvm_pkg::*;
	import WRAPPER_seq_item_pkg::*;
	`include "uvm_macros.svh"
	class WRAPPER_monitor extends  uvm_monitor;
		`uvm_component_utils(WRAPPER_monitor);
		virtual WRAPPER_interface WRAPPER_monitor_vif;
		uvm_analysis_port #(WRAPPER_seq_item) monitor_ap;
		WRAPPER_seq_item WRAPPER_monitor_seq_item;

		function  new(string name="WRAPPER_monitor", uvm_component parent=null );
			super.new(name,parent);
		endfunction : new

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			monitor_ap= new("monitor_ap",this);
		endfunction: build_phase

		task run_phase(uvm_phase phase);
			super.run_phase(phase);
			forever begin
				WRAPPER_monitor_seq_item = WRAPPER_seq_item::type_id::create("WRAPPER_monitor_seq_item");

				@(negedge WRAPPER_monitor_vif.clk);
				WRAPPER_monitor_seq_item.rst_n = WRAPPER_monitor_vif.rst_n;
				WRAPPER_monitor_seq_item.MOSI = WRAPPER_monitor_vif.MOSI;
				WRAPPER_monitor_seq_item.SS_n = WRAPPER_monitor_vif.SS_n;
				WRAPPER_monitor_seq_item.MISO = WRAPPER_monitor_vif.MISO;
				WRAPPER_monitor_seq_item.MISO_expected = WRAPPER_monitor_vif.MISO_expected;
				monitor_ap.write(WRAPPER_monitor_seq_item);
				`uvm_info("run_phase",WRAPPER_monitor_seq_item.convert2string(),UVM_HIGH);
			end
		endtask : run_phase
	endclass : WRAPPER_monitor
endpackage : WRAPPER_monitor_pkg