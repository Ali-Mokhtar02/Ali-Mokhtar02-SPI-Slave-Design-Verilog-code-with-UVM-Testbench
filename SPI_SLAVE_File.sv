module SIP_SLAVE (MOSI,MISO,SS_n,clk,rst_n,rx_data,rx_valid, tx_data, tx_valid);
input logic MOSI,SS_n,clk,rst_n,tx_valid;
input logic [7:0] tx_data;
output logic MISO;
output logic rx_valid; 
output logic [9:0] rx_data; 


//states
parameter IDLE=3'b000;
parameter READ_DATA=3'b001;
parameter READ_ADD=3'b011;
parameter CHK_CMD=3'b111;
parameter WRITE=3'b100;

reg [2:0] cs,ns;
reg rd_flag; // to check if READ_ADD state has been executed or not (high if executed)
reg [3:0] state_countout;
reg[3:0] MISO_CountOut;
wire counter_enable; // to count 10 clock cycles while recieving data
wire counter_done; // flag sent by the counter, high when 10 cycles are completed
wire MISO_CountEn; 
wire MISO_CountDone;
reg s_to_p_done; // signal added to correct rx_valid logic

//state logic
always@(posedge clk or negedge rst_n) begin
  if(~rst_n) begin
    cs<= IDLE;
    rd_flag<=0;
  end
  else begin
    cs<=ns;
  end
end  


//next state logic
always@(*) begin
  case(cs)
  IDLE: begin 
    if(~SS_n) 
      ns=CHK_CMD;
    else 
      ns=IDLE;
  end

  CHK_CMD:
    if(~SS_n) begin
      if(MOSI && ~rd_flag) begin
         ns=READ_ADD;
         //rd_flag=1;
        end
        else if(MOSI && rd_flag) begin
         ns=READ_DATA;
         //rd_flag=0;
        end
        else if(~MOSI) begin
         ns=WRITE;
        end
    end
    else if(SS_n) begin
      ns=IDLE;
    end

  READ_DATA:
    if(SS_n) begin
      ns=IDLE;
    end
    else begin
      ns=READ_DATA;
    end

  READ_ADD:
    if(SS_n) begin
      ns=IDLE;
    end
    else begin
      ns=READ_ADD;
    end
    
  WRITE:
     if(SS_n) begin
      ns=IDLE;
    end
    else begin
      ns=WRITE;
    end

    endcase
end
  
// output logic
always@ (posedge clk or negedge rst_n) begin //add asynchronous reset to output sensitivity list
  if(~rst_n) begin // add reset values for output ports
    MISO<=0;
    rx_data<=0;
    s_to_p_done<=0;
  end
  else begin
    if(counter_enable) begin
      rx_data<={rx_data[8:0], MOSI};
    end
    
    if(cs==READ_ADD && counter_done) begin
      rd_flag<=1;
    end
    else if (cs==READ_DATA && counter_done)begin
      rd_flag<=0;
    end
    if(MISO_CountEn) begin
      MISO<= tx_data[MISO_CountOut-1];
    end
  end
end

// counters logic
always@(posedge clk or negedge rst_n) begin  
  if(~rst_n) begin
    state_countout<=0;
    MISO_CountOut<=8; // counter_down, to send MSB firstly to master

  end
  else begin
    if(counter_enable) begin
      state_countout<=state_countout+1;
    end
    if(counter_done) begin
      state_countout<=0;
      s_to_p_done<=1;
    end
    else
      s_to_p_done<=0;

    if(MISO_CountEn) begin
      MISO_CountOut<=MISO_CountOut-1;
    end
    if (MISO_CountDone) begin
      MISO_CountOut<=8;
    end
  end  
end

// fixed counter enable logic
assign counter_enable=(cs != IDLE && cs!=CHK_CMD && !SS_n  && ~counter_done && !MISO_CountEn)?1:0; 
assign counter_done = (state_countout==4'b1010)?1:0;
// bug parallel to serial conversion keeps happening after it's supposed to be done fixed MISO_CountEn logic
assign MISO_CountEn=(tx_valid && cs==READ_DATA && !MISO_CountDone) ?1:0;
assign MISO_CountDone = (MISO_CountOut== 0)?1:0;

// rx_valid should be high for two clock cycles so the ram can function properly
assign rx_valid=( counter_done || s_to_p_done ) ? 1:0;

//S_P_or_P_S
//Rx_Tx_Ports
`ifdef SIM
  property tx_val;
    @(posedge clk) disable iff(~rst_n) (tx_valid && !SS_n) |=> $stable(tx_data); 
  endproperty

  property rx_val;
    @(posedge clk) disable iff(~rst_n) (rx_valid && !SS_n) |=> $stable(rx_data); 
  endproperty

  property write_add;
    @(posedge clk) disable iff(~rst_n) $fell(SS_n) ##1 (!MOSI) [*2] ##1 !MOSI |-> ##9 ( rx_valid && rx_data[9:8]== 2'b00); 
  endproperty

  property write_data;
    @(posedge clk) disable iff(~rst_n) $fell(SS_n) ##1 (!MOSI) [*2] ##1 MOSI |-> ##9 ( rx_valid && rx_data[9:8]== 2'b01); 
  endproperty

  property read_add;
    @(posedge clk) disable iff(~rst_n) $fell(SS_n) ##1 (MOSI) [*2] ##1 !MOSI |-> ##9 ( rx_valid && rx_data[9:8]== 2'b10); 
  endproperty

  property read_data;
    @(posedge clk) disable iff(~rst_n) $fell(SS_n) ##1 (MOSI)[*3] |->##9 ( rx_valid && rx_data[9:8]== 2'b11); 
  endproperty

    tx_val_ap: assert property (tx_val);
    tx_val_cp: cover property (tx_val);

    rx_val_ap: assert property (rx_val);
    rx_val_cp: cover property (rx_val);

    write_add_ap: assert property (write_add);
    write_add_cp: cover property (write_add);

    write_data_ap: assert property (write_data);
    write_data_cp: cover property (write_data);

    read_add_ap: assert property (read_add);
    read_add_cp: cover property (read_add);

    read_data_ap: assert property (read_data);
    read_data_cp: cover property (read_data);
`endif

endmodule