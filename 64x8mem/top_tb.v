
`timescale 1ns/1ps

module tb_project (); /* this is automatically generated */

    // clock
    reg Clk;
    initial begin
        Clk = 1'b0;
        forever #(5) Clk = ~Clk;
    end

    // asynchronous reset
    reg Rst;
    initial begin
        Rst <= 1'b0;
        #1
        Rst <= 1'b1;
    end

    // (*NOTE*) replace reset, clock, others

    reg        start;
    reg [5: 0] AB;
    reg [7: 0] DB;
    reg        wr;
    wire [2: 0] out;
    integer idx1;

    top inst_project
        (
            .start (start),
            .Rst   (Rst),
            .Clk   (Clk),
            .AB    (AB),
            .DB    (DB),
            .wr    (wr),
            .Out   (out)
        );

    initial begin
        // do something
        AB    <= 0;
        DB    <= 0;
        start <= 0;
        wr    <= 0;
        repeat(2)@(posedge Clk);
        #2
        AB    <= 0;
        DB    <= 0;
        #9
        AB    <= 0;
        DB    <= 1;
        for (idx1 = 1; idx1 < 64; idx1 = idx1 + 1)
        begin
            #10
            AB <= idx1;
            DB <= idx1+1;
        end
        #9
        #2
        start  <= 1;
        #10
        start  <= 0;
        #8

        wr     <= 0;

        repeat(175)@(posedge Clk);
        $finish;
    end
integer i;
    initial
    	begin
      		$dumpfile("wave2.vcd"); 
            for(i=0;i<65;i=i+1)
                $dumpvars(0, tb_project,tb_project.inst_project.mem.mem[i]);

    	end



endmodule
