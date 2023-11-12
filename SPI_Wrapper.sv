module SPI_Wrapper(WRAPPER_interface.DUT WRAPPER_if);
logic MOSI, SS_n,clk,rst_n;
logic MISO;

assign MOSI= WRAPPER_if.MOSI;
assign SS_n= WRAPPER_if.SS_n;
assign clk= WRAPPER_if.clk;
assign rst_n= WRAPPER_if.rst_n;
assign WRAPPER_if.MISO= MISO;

wire [9:0] rxdata;
wire [7:0] txdata;
wire rx_valid,tx_valid;

//instantiation of spi slave and ram
SPI_RAM #(256,8) R (rxdata, rx_valid, clk, rst_n, txdata, tx_valid );
SIP_SLAVE  S (MOSI,MISO,SS_n,clk,rst_n,rxdata,rx_valid, txdata, tx_valid);
endmodule
