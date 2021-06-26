module mem(      input                      wr,
                 input      [7:0]           DB,
				 input      [8:0]           in_adr,
                 input      [8:0]           out_adr,
                 input                      out_en,                       
				 input                      Clk,
				 input		                Rst,
                 input                      bit4,
                 output      [2:0]          out);
			  
			     reg        [511:0]          mem    ;
			    

         integer i; 
             always@                   (negedge Clk)
			            begin
			                  if          (Rst == 0)

					
			                           for(i = 0; i == 511; i = i+1) 
          
			                               mem [i]= 0;

			  
			                  else
                               if     (wr == 0)
                               if     (!bit4)
							        begin
                                       mem [in_adr] <= DB [0];
                                       mem [in_adr+1] <= DB [1];
									   mem [in_adr+2] <= DB [2];
									   mem [in_adr+3] <= DB [3];
									   mem [in_adr+4] <= DB [4];
									   mem [in_adr+5] <= DB [5];
									   mem [in_adr+6] <= DB [6];
									   mem [in_adr+7] <= DB [7];
								    end	   
                                else   
								    begin
								       mem [in_adr] <= DB [0];
                                       mem [in_adr+1] <= DB [1];
									   mem [in_adr+2] <= DB [2];
									   mem [in_adr+3] <= DB [3];
									end
						end

           reg     out0,out1,out2;

           always@      (out_en or out_adr)
			  begin
                  if(out_en)
				  begin
					  
			                     out0 <= mem [out_adr] ;
								 out1 <= mem [out_adr+1];
								 out2 <= mem [out_adr+2];
				  end
			  end
		   assign out= {out2, out1, out0};
 
endmodule