package WRAPPER_agent_pkg;
	import uvm_pkg::*;
	import WRAPPER_seq_item_pkg::*;
	import WRAPPER_config_obj_pkg::*;
	import WRAPPER_driver_pkg::*;
	import WRAPPER_monitor_pkg::*;
	import WRAPPER_sequencer_pkg::*;
	`include "uvm_macros.svh"
	class WRAPPER_agent extends  uvm_agent;
		`uvm_component_utils(WRAPPER_agent);

		WRAPPER_config_obj WRAPPER_agent_cfg;
		WRAPPER_driver WRAPPER_agent_driver;
		WRAPPER_monitor WRAPPER_agent_monitor;
		WRAPPER_sequencer WRAPPER_agent_sqr;
		uvm_analysis_port #(WRAPPER_seq_item) agent_ap;

		function  new(string name="WRAPPER_agent", uvm_component parent=null );
			super.new(name,parent);
		endfunction : new

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			WRAPPER_agent_cfg=WRAPPER_config_obj::type_id::create("WRAPPER_agent_cfg",this);
			if(! uvm_config_db #(WRAPPER_config_obj)::get(this, "", "WRAPPER_CFG",WRAPPER_agent_cfg) )
				`uvm_fatal("build_phase", "get of WRAPPER cfg failed in agent");
			if(! uvm_config_db #(uvm_active_passive_enum)::get(this, "", "WRAPPER_agent_type",WRAPPER_agent_cfg.active) )
				`uvm_fatal("build_phase", "get of WRAPPER agent type failed in agent");
			if(WRAPPER_agent_cfg.active==UVM_ACTIVE) begin
				WRAPPER_agent_driver= WRAPPER_driver::type_id::create("WRAPPER_agent_driver",this);
				WRAPPER_agent_sqr= WRAPPER_sequencer::type_id::create("WRAPPER_agent_sqr",this);
			end
			WRAPPER_agent_monitor= WRAPPER_monitor::type_id::create("WRAPPER_agent_monitor",this);
			agent_ap=new("agent_ap",this);

		endfunction: build_phase

		function void connect_phase( uvm_phase phase);
			super.connect_phase(phase);
			if(WRAPPER_agent_cfg.active==UVM_ACTIVE) begin
				WRAPPER_agent_driver.WRAPPER_driver_vif=WRAPPER_agent_cfg.WRAPPER_config_obj_vif;
				WRAPPER_agent_driver.seq_item_port.connect(WRAPPER_agent_sqr.seq_item_export);
			end
			WRAPPER_agent_monitor.WRAPPER_monitor_vif=WRAPPER_agent_cfg.WRAPPER_config_obj_vif;
			WRAPPER_agent_monitor.monitor_ap.connect(agent_ap);
		endfunction : connect_phase

	endclass : WRAPPER_agent
endpackage : WRAPPER_agent_pkg