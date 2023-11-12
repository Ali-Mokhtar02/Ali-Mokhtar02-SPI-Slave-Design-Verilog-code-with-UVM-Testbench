module SPI_golden_model (MOSI,MISO,SS_n,clk,rst_n,rx_data,rx_valid,tx_data,tx_valid);
input MOSI, clk, rst_n, tx_valid, SS_n;
input[7:0] tx_data;
output reg MISO, rx_valid;
output reg[9:0] rx_data;
reg recieved_address;


(* fsm_encoding = "sequential" *)
reg[2:0] cs,ns;
reg[3:0] counter;

parameter IDLE=3'b000;
parameter CHK_CMD=3'b111;
parameter WRITE=3'b100;
parameter READ_DATA=3'b001;
parameter READ_ADD=3'b011;

// State Memory Logic
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		cs<=IDLE;		
	end
	else begin
		cs<=ns;
	end
end


// Next State Logic

always @(cs,MOSI,SS_n) begin
	case(cs)
		IDLE: begin
			if(SS_n)
				ns=IDLE;
			else
				ns=CHK_CMD;
		end
		CHK_CMD: begin
			if(MOSI) begin
				if(recieved_address) begin
					ns=READ_DATA;
					// recieved_address=0;
				end
				else begin
					ns=READ_ADD;
					// recieved_address=1;
				end
			end
			else begin
				ns=WRITE;
			end
		end

		READ_ADD: begin //serial to parallel conversion
			if(SS_n)
				ns=IDLE;
			else begin
				ns=READ_ADD;
			end
		end

		
		READ_DATA: begin
			if(SS_n)
				ns=IDLE;
			else begin
				ns=READ_DATA;
			end
		end

		WRITE: begin
			if(SS_n)
				ns=IDLE;
			else begin
				ns=WRITE;
			end	
		end

		default: ns<=IDLE;
	endcase
end

// Output Logic Block

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		rx_data<=0;
		rx_valid<=0;	
		MISO<=0;
		counter=0;
		recieved_address<=0;
	end
	else begin
		if(cs==IDLE) begin
			counter<=0;
			rx_valid=0;
		end
		else if(cs==READ_DATA) begin
			recieved_address<=0;
			if(tx_valid && counter>=3) begin
				MISO<=tx_data[counter-3];
				counter<=counter-1;
				rx_valid<=0;
			end
			else if(counter<=9 && !SS_n) begin
 				rx_data<= {rx_data[8:0],MOSI };
 				rx_valid<=0;
 				counter<=counter+1;
 			end
 			//after the conversion of last bit rasie rx_valid
			if(counter >= 9 && ~tx_valid) begin
				rx_valid<=1;
			end
 		end
 		else if(cs==READ_ADD) begin
 			recieved_address<=1;
 			if(counter<=9) begin
 				rx_data<= {rx_data[8:0],MOSI };
 				rx_valid<=0;
 				counter<=counter+1;
 			end
 			//after the conversion of last bit rasie rx_valid
			if(counter>=9) begin
				rx_valid<=1;
			end
 		end		
 		else if(cs==WRITE) begin
 			if(counter<=9) begin
 				rx_data<= {rx_data[8:0],MOSI };
 				rx_valid<=0;
 				counter<=counter+1;
 			end
 			//after the conversion of last bit rasie rx_valid
			if(counter>=9) begin
				rx_valid<=1;
			end
 		end
	end
end
endmodule