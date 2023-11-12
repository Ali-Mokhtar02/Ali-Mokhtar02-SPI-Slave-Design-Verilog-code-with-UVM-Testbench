module WRAPPER_golden_Model(WRAPPER_interface.GOLD WRAPPER_if);
	logic MOSI,SS_n,clk,rst_n;
	logic MISO;

assign MOSI= WRAPPER_if.MOSI;
assign SS_n= WRAPPER_if.SS_n;
assign clk= WRAPPER_if.clk;
assign rst_n= WRAPPER_if.rst_n;
assign WRAPPER_if.MISO_expected= MISO;


wire[9:0] rx_data;
wire[7:0] tx_data;
wire tx_valid;
wire rx_valid;

SPI_golden_model golden_SPI_inst (MOSI,MISO,SS_n,clk,rst_n,rx_data,rx_valid,tx_data,tx_valid);

RAM_golden_model golden_RAM_inst (rx_data, rx_valid, clk, rst_n, tx_data, tx_valid );

endmodule