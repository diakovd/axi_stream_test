package test_pkg;

  class AXI_to_file #(
    //parameter string file = "out.txt",
    parameter bw_data = 32,
	parameter bw_user = 0,	
	parameter SIGNED = 0 // 1 - signed axi.data, 0 - unsigned axi.data 
  );

    virtual axi_stream_virtual_intf #(
      .bw_data(bw_data),
      .bw_user(bw_user)
    ) axi;

    function new(
      virtual axi_stream_virtual_intf #(
      .bw_data(bw_data),
      .bw_user(bw_user)
      ) axi
    );
      this.axi = axi;
    endfunction

    task write_file(input string file = "out.txt");
	
		int fout;
		int write = 1;
		fout = $fopen(file,"w");
	
		//@(posedge axi.clk_i);
		
		do begin
			@(posedge axi.clk_i);
			if(axi.valid  & axi.ready) begin
				if(SIGNED == 1) $fwrite(fout,"%d \n", $signed (axi.data)); 
				else       $fwrite(fout,"%d \n", axi.data); 
			end
			if(axi.last) write = 0;
		end	
		while(write); 	
		$fclose(fout);	
    endtask

 endclass


 class read_Test_Data #(
    // parameter string file_data = "file_name_data.txt",
    // parameter string file_sittings = "file_name_sittings.txt",
    parameter int bw_data = 32, 		// data bit widht
	parameter int depth = 1, 	//size of data buffer
	parameter int SW = 4	
  );

	task read_data(
		input string file_data,
		output logic [bw_data-1:0] data [0:depth -1],
		output int Size);
		int j, fd, dat;
		$readmemh(file_data, data);
		
		fd = $fopen(file_data,"r");
		while(! $feof(fd)) begin
			$fscanf (fd,"%x\n", dat);
			j = j + 1;
		end
		$fclose(fd);
		Size = j;		
    endtask

	task read_sittings( input  string file_sittings,  input string sett_name[SW], output int sett_value[SW]);
		int fd, idx, i;
		string str;
		
		fd = $fopen(file_sittings,"r");
		while(! $feof(fd)) begin
			$fscanf (fd,"%s = %d\n",str, idx);
			
			for( i = 0; i < SW; i = i + 1) begin
				if(str == sett_name[i])   sett_value[i] = idx;	
			end

		end
		$fclose(fd);		
    endtask

 endclass

endpackage
