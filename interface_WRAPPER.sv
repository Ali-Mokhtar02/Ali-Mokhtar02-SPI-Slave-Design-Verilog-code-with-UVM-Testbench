interface WRAPPER_interface (clk);
	input clk;

	logic MOSI, SS_n, rst_n, MISO;
	logic MISO_expected;

	modport DUT (input clk, rst_n, SS_n, MOSI, output MISO);
	modport GOLD (input clk, rst_n, SS_n, MOSI, output MISO_expected);

endinterface : WRAPPER_interface