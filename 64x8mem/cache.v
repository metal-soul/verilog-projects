module    cache(  input                                  cache_adr,
                  input                  [23:0]          cache,
						output                 [2:0]           Out);
                        reg                    [2:0]           iner_out;
						always@(cache or cache_adr)
						         begin               
									                              iner_out [0] = cache [cache_adr];
																  iner_out [1] = cache [cache_adr+1];
																  iner_out [2] = cache [cache_adr+2];
							      end
                  assign                                  Out = iner_out;
endmodule