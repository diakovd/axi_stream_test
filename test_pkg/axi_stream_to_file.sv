
 module AXI_stream_to_file
 #(
	parameter bw_data = 32,
	parameter bw_user = 0,
	parameter string path    = "./outdata",
	parameter string fname   = "Out_data",
	parameter string idx_a_s = "inter",
	parameter use_idx_a_s = 1,
	parameter string idx_b_s = "qart",
	parameter use_idx_b_s = 1,
	parameter SIGNED = 0
 )
  (
	AXI_stream.Slave axi_st_rx, // input axi steram data

	input int index_a, //
	input int index_b, //

	input Clk,
	input Rst		
 );
 
 typedef test_pkg::AXI_to_file #(.bw_data(bw_data) ,.bw_user(bw_user), .SIGNED(SIGNED))
 file_wr; 
 
 axi_stream_virtual_intf #( .bw_data ( bw_data ), .bw_user ( bw_user )
  ) axi_st_rx_vi (Clk);


 initial begin
    static file_wr toFile = new ( axi_st_rx_vi );
	string f_name; 
	
	@(negedge Rst);
	
	while(1) begin

		f_name = {path ,"/", fname}; 
	
		if(use_idx_a_s) f_name ={f_name , "_",  idx_a_s, $sformatf("%0d",index_a)}; 
		if(use_idx_b_s) f_name ={f_name , "_",  idx_b_s, $sformatf("%0d",index_b)}; 

		f_name = {f_name ,".txt"}; 

		toFile.write_file(f_name);
	end
 end

 assign axi_st_rx_vi.data  = axi_st_rx.data;
 assign axi_st_rx_vi.valid = axi_st_rx.valid;
 assign axi_st_rx_vi.ready = axi_st_rx.ready;
 assign axi_st_rx_vi.last  = axi_st_rx.last;
 
 
 endmodule