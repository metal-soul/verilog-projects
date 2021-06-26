module top (input                     start,
            input                     Rst,
            input                     Clk,
			input                     wr,
			input        [5:0]        AB,
            input        [7:0]        DB,
            output       [2:0]        Out);
            
            wire                      forward;
            wire         [23:0]       cache;
			wire                      cache_adr;
			wire                      fin;
				store mem(
				              .wr         (wr),
								  .DB         (DB),
								  .AB         (AB),
								  .Clk        (Clk),
								  .Rst        (Rst),
								  .start      (start),
								  .forward    (forward),
								  .cache      (cache),
								  .fin        (fin));
				counter counter1(
				                  .start      (start),
								  .Clk        (Clk),
								  .Rst        (Rst),
								  .fin        (fin),
								  .cache_adr  (cache_adr),
								  .forward    (forward));
				cache cache1(
				                  .cache_adr  (cache_adr),
								  .cache      (cache),
								  .Out        (Out));
endmodule          