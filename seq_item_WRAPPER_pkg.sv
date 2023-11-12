package WRAPPER_seq_item_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	class WRAPPER_seq_item extends uvm_sequence_item;
		`uvm_object_utils(WRAPPER_seq_item);

		rand logic SS_n, rst_n;
		randc logic MOSI;
		logic MISO,MISO_expected;
		//signals used in constraining MOSI to send correct seuqences only
		logic [4:0] Mosi_sequence_counter=0; //counter keeps track of number of bits sent by MOSI
		logic is_CHK_CMD_or_after=0;
		logic ensure_correct_sequenece=0;
		logic read_address_saved=0;
		logic write_address_saved=0;
		logic prev_operation_type=0; // signal indicates what the previous operation is [ 0->Write , 1->Read]
		
		function  new(string name="WRAPPER_seq_item");
			super.new(name);
		endfunction : new

		function string convert2string();
			return $sformatf(" %s  reset=%0b , MOSI=%0b , SS_n=%0b, MISO=%0b MISO_expected=%0b"
			,super.convert2string(), rst_n, MOSI, SS_n, MISO, MISO_expected,);
		endfunction: convert2string

		function string convert2string_stimulus();
			return $sformatf("reset=%0b , MOSI=%0b , SS_n=%0b",rst_n, MOSI, SS_n);
		endfunction: convert2string_stimulus		

		constraint reset {
			rst_n dist {0:=1 , 1:=99};
		}

		//Correct_sequenece
		constraint Mosi_c {
			if(Mosi_sequence_counter==2 || Mosi_sequence_counter==3) //din[9:8] constrain
				MOSI==ensure_correct_sequenece;
			//Mosi bit the deterimenes read/write operation contrain
			if(Mosi_sequence_counter==1 && prev_operation_type && read_address_saved) // prev operation is read add then this operations should be read data
				MOSI==ensure_correct_sequenece;
		}
		//Correct_sequenece
		constraint Slave_select {
		// constraint slave_select to be active as long as din is sent to ram and to turn off after data is sent
			if(Mosi_sequence_counter >0 && Mosi_sequence_counter<12)
				SS_n ==0; 
			if(Mosi_sequence_counter==12 && (read_address_saved || !prev_operation_type) )// din[9:8]=2'b10
				SS_n==1;
			// if operation is read data wait 8-9 clk cycles more for parallel to serail conversion before
			// slave select turns off.
			else if(Mosi_sequence_counter>=12 && Mosi_sequence_counter<=21 && prev_operation_type && !read_address_saved)
				{
					if(Mosi_sequence_counter==21) // parallel to serial is finished!
						SS_n==1;
					else
						SS_n==0;	
				}
		}

		function void post_randomize(); 
			if(~SS_n && rst_n) 
				is_CHK_CMD_or_after=1;				
			else begin
				is_CHK_CMD_or_after=0;
				Mosi_sequence_counter=0;
			end
			if(~rst_n) begin
				write_address_saved=0;
				read_address_saved=0;
				prev_operation_type=0; //no write happened
			end
		endfunction : post_randomize

		function void pre_randomize();
			if(is_CHK_CMD_or_after && Mosi_sequence_counter>0 ) begin
				// sequenece
				if(Mosi_sequence_counter==1) begin //constrain the 10th bit sent
					ensure_correct_sequenece=MOSI;
					Mosi_sequence_counter++;
					prev_operation_type=MOSI;
				end
				else if(Mosi_sequence_counter==2) begin
					if(MOSI) begin
						if(read_address_saved) begin
							ensure_correct_sequenece=1;
							read_address_saved=0;
						end

						else begin
							ensure_correct_sequenece=0;
							read_address_saved=1;
						end
					end
					else begin
						if(write_address_saved) begin
							ensure_correct_sequenece=1;
							write_address_saved=0;
						end
						else begin
							ensure_correct_sequenece=0;
							write_address_saved=1;
						end
					end
					Mosi_sequence_counter++;
				end
				else
					Mosi_sequence_counter++;
			end
			if(is_CHK_CMD_or_after && Mosi_sequence_counter==0) begin // 11th bit deteremines read/write
				if(prev_operation_type && read_address_saved) begin // if the last RAM operation was read address then this operation should be read data 
					ensure_correct_sequenece=1;
				end
				else
					prev_operation_type=0;
				Mosi_sequence_counter++;
			end
		endfunction : pre_randomize



		
	endclass : WRAPPER_seq_item

endpackage : WRAPPER_seq_item_pkg