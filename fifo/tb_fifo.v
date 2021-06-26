`timescale 1ns/1ps 
module tb_fifo();


    reg Clk;

        initial 
        begin
            Clk = 1'b1;
        forever #(5) Clk = ~Clk;
        end

    reg Rst;

        initial begin
            Rst <= 1'b0;
            #1
            Rst <= 1'b1;
        end

    reg bit4;
        initial 
        begin
            bit4        =              0;
            #6440
            bit4        =              1;
        end

    reg               [7:0]            DB;
    wire              [2:0]            out;
    wire overflow;
    reg wr;

    top top1(.Clk                     (Clk),
             .Rst                     (Rst),
             .bit4                    (bit4),
             .DB                      (DB),
             .wr                      (wr),
             .overflow                (overflow),
             .out                     (out));
              integer id;

        initial begin 
            DB          <=             0;
            #4
            wr          <=             0;
            DB          <=             1;
           
            for (id = 1; id < 64; id = id + 1)
                begin
                    #10
                    DB  <=             id+1;
                end
            #10 DB <=0;
            for (id = 1; id < 64; id = id + 1)
                begin
                    #10
                    DB  <=             id+1;
                end
            
            repeat(175)@(posedge Clk);
            $finish;
        end

    initial
    	begin
      		$dumpfile("wave.vcd");
            $dumpvars(0, tb_fifo);
    	end
endmodule
