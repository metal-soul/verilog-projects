module store(    input                         wr,
                 input         [7:0]           DB,
				 input         [5:0]           AB,
				 input                         Clk,
				 input		                   Rst,
				 input                         forward,
				 input                         start,
			     output reg    [23:0]          cache,
				 output reg                    fin);
			  
			    reg            [7:0]           mem     [65:0];
			    reg            [5:0]           rd_mem_adr ;
                integer                        i;

			    always@(rd_mem_adr)
				    begin
						if          (!Rst)
						             fin = 0;
						else			 
                            if      (rd_mem_adr == 63)
									 fin = 1;
							else     fin = 0;
				    end

                always           @            (wr or Rst or forward or DB)
			            begin
			                  if              (Rst == 0)
			                        for(i = 0; i == 65; i = i+1) 
			                            begin           
			                                mem [i]= 8'b00000000;
					                    end //清空寄存器
			                  else
                               if             (wr == 0)
                                               mem [AB] [7:0] = DB [7:0];
										 else            mem [AB] [7:0] = DB [7:0];
						end

			always        @      (*)
			    begin
				    if        (start)
                           rd_mem_adr = 0;					 
					 else    if(forward == 1)
						         rd_mem_adr = rd_mem_adr+3;
								else rd_mem_adr = rd_mem_adr;
			    end
			  
            always        @      (rd_mem_adr or start)
			    begin
			                     cache [7:0]   <= mem [rd_mem_adr] ;
								 cache [15:8]  <= mem [rd_mem_adr+1];
								 cache [23:16] <= mem [rd_mem_adr+2];
			    end 
endmodule
								 
			   
