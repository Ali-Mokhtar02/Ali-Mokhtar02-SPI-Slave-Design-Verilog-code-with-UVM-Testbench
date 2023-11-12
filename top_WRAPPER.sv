module Top_WRAPPER ();
	import uvm_pkg::*;
	import WRAPPER_test_pkg::*;
	`include "uvm_macros.svh"
	logic clk;
	initial begin
		clk=0;
		forever
			#1 clk=~clk;
	end
	WRAPPER_interface WRAPPER_if (clk);
	SPI_Wrapper WRAPPER_insta(WRAPPER_if);
	WRAPPER_golden_Model golden_WRAPPER_insta(WRAPPER_if);
	bind WRAPPER_insta Wrapper_Assertions wrap_sva_insta(WRAPPER_if);

	initial begin
		uvm_config_db#(virtual WRAPPER_interface )::set(null, "uvm_test_top", "WRAPPER_if",WRAPPER_if);
		run_test("WRAPPER_test");
	end

endmodule : Top_WRAPPER