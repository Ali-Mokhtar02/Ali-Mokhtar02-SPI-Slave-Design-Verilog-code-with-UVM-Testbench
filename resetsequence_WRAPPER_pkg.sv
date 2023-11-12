package WRAPPER_reset_sequence_pkg;
	import uvm_pkg::*;
	import WRAPPER_seq_item_pkg::*;
	`include "uvm_macros.svh"
	class WRAPPER_reset_sequence extends uvm_sequence #(WRAPPER_seq_item);
		`uvm_object_utils(WRAPPER_reset_sequence);
		WRAPPER_seq_item seq_item;

		function  new(string name="WRAPPER_reset_sequence");
			super.new(name);
		endfunction : new

		task body;
			repeat(5) begin
				seq_item= WRAPPER_seq_item::type_id::create("seq_item");
				start_item(seq_item);
				seq_item.rst_n = 0;
				seq_item.MOSI = $random;
				seq_item.SS_n = $random;
				finish_item(seq_item);
			end
		endtask : body

	endclass : WRAPPER_reset_sequence

endpackage : WRAPPER_reset_sequence_pkg