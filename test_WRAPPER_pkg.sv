package WRAPPER_test_pkg;
	import uvm_pkg::*;
	import WRAPPER_env_pkg::*;
	import WRAPPER_config_obj_pkg::*;
	import WRAPPER_reset_sequence_pkg::*;
	import WRAPPER_main_sequence_pkg::*;
	import WRAPPER_seq_item_pkg::*;
	`include "uvm_macros.svh"
	class WRAPPER_test extends uvm_test;
		`uvm_component_utils(WRAPPER_test);
		WRAPPER_env WRAPPER_test_env;
		WRAPPER_config_obj WRAPPER_test_cfg;
		WRAPPER_reset_sequence WRAPPER_test_rst_seq;
		WRAPPER_main_sequence WRAPPER_test_main_seq;

		function  new(string name="WRAPPER_test", uvm_component parent=null );
			super.new(name,parent);
		endfunction : new

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			WRAPPER_test_cfg= WRAPPER_config_obj::type_id::create("WRAPPER_test_cfg",this);
			WRAPPER_test_env= WRAPPER_env::type_id::create("WRAPPER_test_env",this);
			WRAPPER_test_main_seq= WRAPPER_main_sequence::type_id::create("WRAPPER_test_main_seq",this);
			WRAPPER_test_rst_seq= WRAPPER_reset_sequence::type_id::create("WRAPPER_test_rst_seq",this);
			if(! uvm_config_db#(virtual WRAPPER_interface)::get(this, "", "WRAPPER_if",WRAPPER_test_cfg.WRAPPER_config_obj_vif) )
				`uvm_fatal("build_phase", "get of WRAPPER interface failed in test");

			uvm_config_db#( uvm_active_passive_enum)::set(this, "*", "WRAPPER_agent_type",UVM_ACTIVE);
			uvm_config_db#( WRAPPER_config_obj)::set(this, "*", "WRAPPER_CFG",WRAPPER_test_cfg);
		endfunction : build_phase 

		task run_phase(uvm_phase phase);
			super.run_phase(phase);
			phase.raise_objection(this);
			`uvm_info("run_phase","Reset asserted", UVM_LOW);
			WRAPPER_test_rst_seq.start(WRAPPER_test_env.WRAPPER_env_agent.WRAPPER_agent_sqr);
			`uvm_info("run_phase", "Reset deasserted", UVM_LOW);
			`uvm_info("run_phase", "Stimulus generation starts", UVM_LOW);
			WRAPPER_test_main_seq.start(WRAPPER_test_env.WRAPPER_env_agent.WRAPPER_agent_sqr);
			`uvm_info("run_phase", "Stimulus generation ends", UVM_LOW);
			phase.drop_objection(this);
		endtask : run_phase
	endclass : WRAPPER_test
endpackage : WRAPPER_test_pkg