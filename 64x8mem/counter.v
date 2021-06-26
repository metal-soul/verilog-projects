module     counter(      input                           start,
                         input                           Clk,
						 input                           Rst,
						 input                           fin,
						 output                          cache_adr,
						 output                          forward);
						 
						 reg                 [2:0]       counter = 0;
						 reg                             rideon;
                         reg                             iner_fw;
                         assign                          forward = iner_fw;
						 always        @                (*)
						      begin
								   if                     (Rst == 0)
									                        rideon = 0;
									else
									   if                  (fin == 1 && counter == 2)
										                    rideon = 0;
									else								
						            if                  (start == 1)
									                        rideon = 1;
										else                 rideon = rideon;
						      end
						 always     @                   (Clk)
						      begin
								   if                     (rideon == 1)
						            if                  (counter == 7)
										      begin
										                       counter = 0;
												               iner_fw = 1;
												end
										else  begin          counter = counter+1;
										                     iner_fw = 0;
                                    end
								end
						 assign                          cache_adr = 3*counter;
endmodule