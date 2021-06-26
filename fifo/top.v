module top(input Clk,
           input Rst,
           input bit4,
           input [7:0] DB,
           input wr,
           output overflow,
           output  wire [2:0] out);

           wire     out_en;
           wire     [8:0] out_adr,in_adr;

           control control1(.Clk(Clk),
                            .wr(wr),
                            .Rst(Rst),
                            .bit4(bit4),
                            .out_en(out_en),
                            .overflow(overflow),
                            .out_adr(out_adr),
                            .in_adr(in_adr));
           mem mem1(.DB(DB),
                    .wr(wr),
                    .in_adr(in_adr),
                    .out_adr(out_adr),
                    .out_en(out_en),
                    .Clk(Clk),
                    .Rst(Rst),
                    .bit4(bit4),
                    .out(out));
endmodule