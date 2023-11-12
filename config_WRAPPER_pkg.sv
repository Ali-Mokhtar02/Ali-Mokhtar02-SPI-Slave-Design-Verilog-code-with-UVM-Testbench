package WRAPPER_config_obj_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	class WRAPPER_config_obj extends  uvm_object;

		`uvm_object_utils(WRAPPER_config_obj);

		virtual WRAPPER_interface WRAPPER_config_obj_vif;
		uvm_active_passive_enum active;

		function new(string name="WRAPPER_config_obj");
			super.new(name);
		endfunction : new
		
	endclass : WRAPPER_config_obj
endpackage : WRAPPER_config_obj_pkg