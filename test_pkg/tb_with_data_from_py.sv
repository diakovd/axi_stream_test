
`define top
`timescale 1 ns / 1 ns

module module_tb;

 parameter depth = 65536;
 parameter bw_tx = 32;
 parameter bw_rx = 24;
 parameter userSize = 4;  
 parameter fNameOutData = "output.txt";  
 parameter fnameInData = "stimuli.mem";
 parameter fnameInSett = "sittings_input.txt";
 
 localparam bw_pkt = $clog2(depth);

 logic Clk = 0;
 logic Rst;
 
 logic [bw_tx-1:0] data [0:depth -1];
 logic [bw_pkt - 1:0] pktSize_in; 

 logic TstLast = 0;
 logic tx_end = 0; 


 logic [6:0] count_preambles;
 logic no_prach_detected;


// input setting data
 parameter SW = 4;  

 logic [6:0] num_preambl;
 logic [1:0] preamble_format;
 logic [3:0] zeroCorrelationZone;
 logic [11:0] ROOT_SEQ;	
 logic tst_data_rd;
 
 string sett_name[SW];
 int sett_value[SW];

 initial begin
	sett_name[0] = "zeroCorrelationZone";
	sett_name[1] = "preamble_format";
	sett_name[2] = "num_preambl";
	sett_name[3] = "ROOT_SEQ";
 end
 
 assign zeroCorrelationZone = sett_value[0];
 assign preamble_format 	= sett_value[1];
 assign num_preambl 		= sett_value[2];
 assign ROOT_SEQ 			= sett_value[3];	

 typedef test_pkg::read_Test_Data #( .bw_data(bw_tx) , .depth(depth),.SW(SW) 
  ) read_Data; 
 
 
 always #4 Clk <= ~Clk;  

 initial begin
	Rst = 1;
	#100;
	Rst = 0;
 end   
  
 typedef axi_stream_test::axi_stream_driver #(
    .bw_data(bw_rx)  ,
    .bw_user(4)  ,
	.size_pkt(depth)
  ) AXI_driver_rx;

 typedef axi_stream_test::axi_stream_driver #(
    .bw_data(bw_tx)  ,
    .bw_user(4)  ,
	.size_pkt(depth)
  ) AXI_driver_tx;


  axi_stream_virtual_intf_DV #(
    .bw_data ( bw_tx ),
    .bw_user ( userSize )
  ) axi_tx_vi (Clk);

  axi_stream_virtual_intf_DV #(
    .bw_data ( bw_rx ),
    .bw_user ( userSize )
  ) axi_rx_vi (Clk);

  axi_stream_virtual_intf #(
    .bw_data (  bw_tx ),
    .bw_user ( userSize )
  ) axi_tx();

  axi_stream_virtual_intf #(
    .bw_data ( bw_rx ),
    .bw_user ( userSize )
  ) axi_rx ();
  
 assign axi_tx.data = axi_tx_vi.data;
 assign axi_tx.valid = axi_tx_vi.valid;
 assign axi_tx.last = axi_tx_vi.last;
 assign axi_tx.user = axi_tx_vi.user;
 assign axi_tx_vi.ready = axi_tx.ready;

 assign axi_rx_vi.data  = axi_rx.data;
 assign axi_rx_vi.valid = axi_rx.valid;
 assign axi_rx_vi.last  = axi_rx.last;
 assign axi_rx_vi.user  = axi_rx.user;
 assign axi_rx.ready    = axi_rx_vi.ready;

`ifndef top

 module_top 
 module_top_inst
 (
 	.axiRx(axi_tx),
	.axiTx(axi_rx),
 
    .num_preambl(num_preambl),
    .preamble_format(preamble_format),
    .zeroCorrelationZone(zeroCorrelationZone),
    .ROOT_SEQ(ROOT_SEQ),	

    .count_preambles(count_preambles),
    .no_prach_detected(no_prach_detected),
 
	.Clk(Clk),
	.Rst(Rst)	
 );
`else

 module_top 
 module_top_inst
 (
 	.axiRx_Im(axi_tx.data[bw_tx   - 1 : bw_tx/2]),
	.axiRx_Re(axi_tx.data[bw_tx/2 - 1 : 0]),
	.axiRx_Valid(axi_tx.valid),		
	.axiRx_Last(axi_tx.last),
	.axiRx_User(axi_tx.user),
	.axiRx_Ready(axi_tx.ready),
	
	.axiTx_Data_RA_PreambleIdxs(axi_rx.data[23 : 16]), 
	.axiTx_Data_TA(axi_rx.data[15 : 0]), 
	.axiTx_Valid(axi_rx.valid),		
	.axiTx_Last(axi_rx.last),
	.axiTx_User(axi_rx.user),
	.axiTx_Ready(axi_rx.ready),	

    .num_preambl(num_preambl),
    .preamble_format(preamble_format),
    .zeroCorrelationZone(zeroCorrelationZone),
    .ROOT_SEQ(ROOT_SEQ),	

    .count_preambles(count_preambles),
    .no_prach_detected(no_prach_detected),
	
	.Clk(Clk),
	.Rst(Rst)
 );	

`endif
 

 task read_stimuli; 
    static read_Data readDt = new();

    readDt.read_data(fnameInData, data, pktSize_in);
    readDt.read_sittings(fnameInSett, sett_name, sett_value);

    @(posedge Clk);
    tst_data_rd = 1;
    @(posedge Clk);
    tst_data_rd = 0;
 endtask  
  
  
 task test1;
	
    static AXI_driver_tx axi_stream_driver = new ( axi_tx_vi );


	@(posedge Clk);
	@(posedge Clk);
	
	//Write 
	axi_stream_driver.send_pkt(data, pktSize_in);

	@(posedge Clk);
	@(posedge Clk);

 endtask  
  
 
 initial begin : proc_axi_master
	
    static AXI_driver_tx axi_stream_driver = new ( axi_tx_vi );
	
    axi_stream_driver.reset_master();
	
    @(negedge Rst);

	while(!TstLast) begin
		read_stimuli();
		test1();
		if(!TstLast) begin
			$display("Tx_last_marker");
			$stop(1);
		end
		else tx_end = 1;
	end
	
	$display("Finish marker");
	$finish;

 end  
 
 AXI_stream #(.bw_data(48), .bw_user(0)) axi_rx_f();
 assign axi_rx_f.data = axi_rx.data;
 assign axi_rx_f.valid = axi_rx.valid;
 assign axi_rx_f.last = axi_rx.last;
 assign axi_rx_f.ready = axi_rx.ready;

 AXI_stream_to_file #(
   .bw_data(48), .UW(0),
   .path("./outdata"),
   .fname("DDC0_out"),
   .idx_a_s("None"),
   .use_idx_a_s(0),
   .idx_b_s("None"),
   .use_idx_b_s(0),
   .SIGNED(0)
 ) AXI_stream_to_file_LLR_bkwd_wr (
   .axi_st_rx(axi_rx_f),
   .index_a(),
   .index_b(),
   .Clk(Clk),
   .Rst(Rst)		
 );   
 
 initial begin : timeout
    //#150000;
    //$display("!@# TEST FAILED - TIMEOUT #@!");
    //$finish;
 end	
  
endmodule