module video_clk(input clk, input reset, output vclk);

	//25MHz clock
	reg clk_count;

	always @ (posedge clk, posedge reset)
	begin
		if (reset) clk_count <= 0;
		else
			clk_count <= ~clk_count;
	end

	assign vclk = clk_count;

	

	/*reg [15:0] clk_count;

	always @ (posedge clk, posedge reset)
	begin		
		if (reset) clk_count <= 16'b0;
		else
			if (clk_count >= 16'd39722)
			begin
				vclk <= 1;
				clk_count <= clk_count - 16'd39722; //~39,7ns (~25.175MHz)	
			end
			else
			begin
				vclk <= 0;
				clk_count <= clk_count+16'd20000; //20ns (50MHz)
			end
	end*/
endmodule
