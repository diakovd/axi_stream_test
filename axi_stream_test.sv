//`timescale 1 ns / 1 size_pkt
package axi_stream_test;

  class axi_stream_driver #(
    parameter bw_data = 32  ,
    parameter bw_user = 32  ,
    parameter size_pkt = 32  // packet size for packet transfer
 );

    virtual axi_stream_virtual_intf #(
      .bw_data(bw_data),
      .bw_user(bw_user)
    ) axi_st;

    function new(
      virtual axi_stream_virtual_intf #(
      .bw_data(bw_data),
      .bw_user(bw_user)
      ) axi_st
    );
      this.axi_st = axi_st;
    endfunction

	function void reset_master();
      axi_st.data  <= '0;
      axi_st.valid <= '0;
	  axi_st.user	<= '0;
      axi_st.last  <= '0;
    endfunction
	
	function void reset_slave();
      axi_st.ready  <= '0;
    endfunction

    task send_byte(
      input logic [bw_data-1:0] data,
      input logic [bw_user-1:0] user,
	  input logic last
    );
      axi_st.data  = data;
      axi_st.valid = 1;
	  axi_st.user	= user;
      axi_st.last  = last;	

	  if(axi_st.ready != 1) begin
		while (axi_st.ready != 1)  @(posedge axi_st.Clk);
	  end
	  else 	@(posedge axi_st.Clk);
      axi_st.valid = '0;
      axi_st.data  = '0;
	  axi_st.user	= '0;
      axi_st.last  = '0;
    endtask

    /// Wait for a beat on the W channel.
    task receive_byte (
      output [bw_data-1:0]   data,
      output logic [bw_user-1:0] user,
	  output logic last
    );

      axi_st.ready = 1;
	  if(axi_st.valid != 1)
		while (axi_st.valid != 1) @(posedge axi_st.Clk);
	  else @(posedge axi_st.Clk);
      data = axi_st.data;
      user = axi_st.user;
	  last = axi_st.last;
      axi_st.ready = 0;
    endtask

    task send_pkt (
      input logic [bw_data-1:0] data [size_pkt],
      //input logic [bw_user-1:0] user,
	  input int pkt_size
	  //input logic last
    );
		int i;
		for(i = 0; i < pkt_size; i = i + 1) begin
			send_byte(data[i],0,((i == pkt_size - 1)? 1 : 0)); 
		end
    endtask
	
 endclass

endpackage
