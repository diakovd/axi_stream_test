
interface axi_stream_intf #(
  parameter bw_data = 0,
  parameter bw_user = 0
);

  logic valid;
  logic ready;
  logic [bw_data - 1:0]  data;
  logic last;
  logic [bw_user - 1:0] user;

  modport Master (
	output data,
	output valid,  		
	output last,
	output user,	
	input  ready	
  );
  
  modport Slave (
	input data, 
	input valid,		
	input last,
	input user,
	output ready		
  );
endinterface
	
interface axi_stream_virtual_intf #(
  parameter int unsigned bw_data = 0,
  parameter int unsigned bw_user = 0
)
(
  input logic Clk
);	


  logic valid;
  logic ready;
  logic [bw_data - 1:0] data;
  logic last;
  logic [bw_user - 1:0] user;

  modport Master (
	output data,
	output valid,  		
	output last,
	output user,	
	input  ready	
  );
  
  modport Slave (
	input data, 
	input valid,		
	input last,
	input user,
	output ready		
  );
	
	

endinterface
