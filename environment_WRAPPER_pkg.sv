package WRAPPER_env_pkg;
	import uvm_pkg::*;
	import WRAPPER_agent_pkg::*;
	import WRAPPER_scoreboard_pkg::*;
	import WRAPPER_coverage_pkg::*;
	`include "uvm_macros.svh"
	class WRAPPER_env extends uvm_env;
		`uvm_component_utils(WRAPPER_env);
		WRAPPER_agent WRAPPER_env_agent;
		WRAPPER_scoreboard WRAPPER_env_sb;
		WRAPPER_coverage WRAPPER_env_coverage;
		function new(string name="WRAPPER_env", uvm_component parent = null );
			super.new(name,parent);
		endfunction : new

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			WRAPPER_env_agent=WRAPPER_agent::type_id::create("WRAPPER_env_agent",this);
			WRAPPER_env_sb= WRAPPER_scoreboard::type_id::create("WRAPPER_env_sb",this);
			WRAPPER_env_coverage=WRAPPER_coverage::type_id::create("WRAPPER_env_coverage",this);
		endfunction : build_phase 

		function void connect_phase(uvm_phase phase);
			WRAPPER_env_agent.agent_ap.connect(WRAPPER_env_sb.sb_exp);
			WRAPPER_env_agent.agent_ap.connect(WRAPPER_env_coverage.coverage_exp);
		endfunction : connect_phase 

	endclass : WRAPPER_env
endpackage : WRAPPER_env_pkg