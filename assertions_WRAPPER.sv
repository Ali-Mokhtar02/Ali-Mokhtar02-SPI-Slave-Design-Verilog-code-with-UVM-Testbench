module Wrapper_Assertions( WRAPPER_interface.DUT WRAPPER_if);
	
	logic MOSI, SS_n, rst_n, MISO;
	logic clk;

	assign MOSI= WRAPPER_if.MOSI;
	assign SS_n= WRAPPER_if.SS_n;
	assign clk = WRAPPER_if.clk;
	assign rst_n = WRAPPER_if.rst_n;
	assign MISO = WRAPPER_if.MISO;

		always_comb begin
			if(!rst_n)
				Asynchronous_reset:assert final (MISO==0);
		end
	//Correct_sequenece
		// Master sends correct write operations
	property MOSI_Write;
		@(posedge clk) disable iff(~rst_n) ($fell(SS_n) ) ##1  (!MOSI) |=> !MOSI ; 		
	endproperty

	// Master sends correct read operations
	property MOSI_read;
		@(posedge clk) disable iff(~rst_n) ($fell(SS_n) ) ##1  (MOSI) |=> MOSI ; 		
	endproperty

	// Master activates slave select for write operations correctly
	property SS_correct_sequence_write;
		@(posedge clk) disable iff(~rst_n) ($fell(SS_n) ) ##1  (!MOSI && ~SS_n) |=> (!MOSI && ~SS_n)  ##1 ~SS_n[*9]  ##1 SS_n ; 		
	endproperty

	// Master activates slave select for read address operations correctly
	property SS_correct_sequence_Readadd;
		@(posedge clk) disable iff(~rst_n) ($fell(SS_n) ) ##1  (MOSI && ~SS_n) ##1 ( MOSI && ~SS_n) ##1 ( ~MOSI && ~SS_n) |-> ##1  ~SS_n[*8]  ##1 SS_n; 		
	endproperty

// Master activates slave select for read data operations correctly
	property SS_correct_sequence_ReadData;

		@(posedge clk) disable iff(~rst_n) ($fell(SS_n) ) ##1  (MOSI && ~SS_n) ##1 ( MOSI && ~SS_n) ##1 ( MOSI && ~SS_n) |->  ##1 ~SS_n[*17]  ##1 SS_n ; 		

	endproperty

	MOSI_Write_ap: assert property(MOSI_Write);
	MOSI_Write_cp: cover property(MOSI_Write);

	MOSI_read_ap: assert property(MOSI_read);
	MOSI_read_cp: cover property(MOSI_read);

	SS_correct_sequence_ReadData_ap: assert property(SS_correct_sequence_ReadData);
	SS_correct_sequence_ReadData_cp: cover property(SS_correct_sequence_ReadData);

	SS_correct_sequence_write_ap: assert property(SS_correct_sequence_write);
	SS_correct_sequence_write_cp: cover property(SS_correct_sequence_write);

	SS_correct_sequence_Readadd_ap: assert property(SS_correct_sequence_Readadd);
	SS_correct_sequence_Readadd_cp: cover property(SS_correct_sequence_Readadd);


endmodule : Wrapper_Assertions