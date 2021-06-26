`define period 100
`timescale 1ns/100ps

`define SM_index 7:6
`define SM2_index 5
`define REN_index 4
`define tb8_index 3
`define rb8_index 2
`define TI_index 1
`define RI_index 0

`define addr_TH 8'h97
`define addr_TL 8'h96
`define addr_SCON 8'h99
`define addr_SBUF 8'h98

`define Timer_init  3
`define SM  2'b00
`define SM2 1'b0
`define REN 1'b0
`define tb8 1'b1

`define TX_data1     8'b1010_1001
`define TX_data2     8'b0101_1001
`define RxD_syn_data 8'b1010_0110

module uart_TB;
	
	reg rst_n;
	reg clk;
	reg [7:0] AB;
	reg rd;
	reg wr;
	
	wire [7:0] DB;
	
	reg [7:0] din;
	reg [7:0] dout;
	
	reg [15:0] Timer_data;
	
	wire TxD;
	wire RxD;
	wire Intuart;
	
	assign DB = (!wr) ? din : 8'bz;
	
	uart uuart(
		.rst_n    ( rst_n     ),
		.clk     ( clk      ),
		.AB      ( AB       ),
		.DB      ( DB       ),
		.rd      ( rd       ),
		.wr      ( wr       ),
		.TxD     ( TxD      ),
		.RxD     ( RxD      ),
		.Intuart ( Intuart  )
	);

	
	wire [1:0] SM = uuart.SM;
	
	wire REN = uuart.REN;
	reg TI, RI;
	reg rb8;
	
//generate RXD in data
// if mode1 or mode2, TxD data loop back to RxD
// if mode0, RxD input data is macro `RxD_syn_data

	reg RxDt;
	assign RxD = RxDt;
	reg [7:0] tt = `TX_data1;
	
	always @(*) begin
		if(SM != 2'b00)
			RxDt = #(`period * 9) TxD;
		else if((SM == 2'b00) && REN) begin
			RxDt <= tt[0];
			@(posedge TxD)
			tt <= {tt[0], tt[7:1]}; 
		end else
			RxDt = 1'bz;
	end


//record mode0 output data;
	reg [7:0] TxD_syn_data;

	/*
	always @(*)
		if((SM == 2'b00) && !REN) begin
			//@(negedge TxD);
			//repeat(8) begin
				@(posedge TxD) 
			//end
		end
		*/

	always @(posedge TxD) begin
		if((SM == 2'b00) && !REN) begin
			TxD_syn_data <= {RxD, TxD_syn_data[7:1]};
		end
	end

//clk generate		
	always #(`period/2) clk = !clk;    //100ns一个周期
		
	
	initial begin
		rst_n = 0;
		clk = 0;
		AB = 0;
		din = 0;
		rd = 1;
		wr = 1;
	  repeat(3) @(posedge clk);
	  #10 	rst_n = 1;					//210ns
// write THB
		Timer_data = - `Timer_init;

		@(negedge clk)
		AB = `addr_TH;
		din = Timer_data[15:8];
		wr = 0;
		@(negedge clk)
		wr = 1;
//write TLB		
		@(negedge clk)
		AB = `addr_TL;
		din = Timer_data[7:0];
		wr = 0;
		@(negedge clk)
		wr = 1;
//write SCON
		@(negedge clk)
		AB = `addr_SCON;
		din = {`SM, `SM2, `REN, `tb8, 3'b000}; 	// REN = 0
		wr = 0;
		@(negedge clk)
		wr = 1;
		
//write Sbuf
		@(negedge clk)
		AB = `addr_SBUF;						// 98H
		din = `TX_data1;
		wr = 0;
		@(negedge clk)
		wr = 1;
//set SCON REN
	if(SM != 2'b00) begin
	    repeat(5) @(posedge clk);
		@(negedge clk)
		AB = `addr_SCON;
		din = {`SM, `SM2, 1'b1, `tb8, 3'b000}; // mode 2  5th bit set 1
		wr = 0;
		@(negedge clk)
		wr = 1;
	end
	
		wait(Intuart);

//read SCON
		TI = 0;									// read UART_TI into TI
		while(!TI) begin
			@(negedge clk)
			AB = `addr_SCON;
			rd = 0;
			@(negedge clk)
			dout = DB;
			rd = 1;
			
			TI = dout[`TI_index];
		end
	
		din = dout & 8'b1111_1101;
//write SCON with TI is clear		
		@(negedge clk)
		AB = `addr_SCON;
		wr = 0;
		@(negedge clk)
		wr = 1;

//test if mode0, TX data
	
		$display("uart is work in %b mode\n verification result is", SM);
	
		if(SM == 2'b00)	begin
			$write($time, " mode0 TxD data is %h, received data is %h", `TX_data1, TxD_syn_data);
			if(TxD_syn_data == `TX_data1) 
				$display(" result is OK");
			else
				$display(" result is error");
		end
//if mode0, set REN, Receive data		

		if(SM == 2'b00)	begin
			@(negedge clk)
			AB = `addr_SCON;
			din = {`SM, `SM2, 1'b1, `tb8, 3'b000}; 
			wr = 0;
			@(negedge clk)
			wr = 1;
		end
//clear TI
//wait RI

		wait(Intuart);

		RI = 0;
		while(!RI) begin
			@(negedge clk)
			AB = `addr_SCON;
			rd = 0;
			@(negedge clk)
			dout = DB;
			rd = 1;
		
			RI = dout[`RI_index];
		end
		
		rb8 = dout[`rb8_index];

//read SBUF		
		@(negedge clk)
		AB = `addr_SBUF;
		rd = 0;
		@(negedge clk)
		dout = DB;
		rd = 1;
		
//test SBUF received data		
		$write($time, " TxD data is %h, received data is %h,", `TX_data1, dout);
		if(dout == `TX_data1) 
			$display(" result is OK");
		else
			$display(" result is error");
		
//test mode2 rb8

		if(SM == 2'b10) begin
			$write($time, " received rb8 is %h, ", rb8);
			if(rb8 == `tb8) 
				$display("rb8 result is OK");
			else
				$display("rb8 result is error");
		end
		
		repeat(20) @(posedge clk);
		$finish;
	end
	

		
endmodule