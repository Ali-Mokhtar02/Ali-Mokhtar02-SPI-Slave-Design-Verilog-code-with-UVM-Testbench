package WRAPPER_main_sequence_pkg;
	import uvm_pkg::*;
	import WRAPPER_seq_item_pkg::*;
	`include "uvm_macros.svh"
	class WRAPPER_main_sequence extends uvm_sequence #(WRAPPER_seq_item);
		`uvm_object_utils(WRAPPER_main_sequence);
		WRAPPER_seq_item seq_item;
		function  new(string name="WRAPPER_main_sequence");
			super.new(name);
		endfunction : new

		task body;
			seq_item= WRAPPER_seq_item::type_id::create("seq_item");
			repeat(20000) begin
				start_item(seq_item);
				assert(seq_item.randomize());
				finish_item(seq_item);
			end
		endtask : body
	endclass : WRAPPER_main_sequence
endpackage : WRAPPER_main_sequence_pkg