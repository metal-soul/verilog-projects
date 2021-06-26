module control(input                              Clk,
               input                              Rst,
               input                              bit4,
               input                              wr,
               output               reg           out_en,
               output               wire          overflow,
               output               reg   [8:0]   out_adr=9'b000000000,
               output               reg   [8:0]   in_adr=9'b000000000); 

reg            overflow1            =             0;
assign         overflow             =             overflow1;
 

always                              @             (posedge Clk)
    begin
        if                                            (!wr) 
            begin
                if(!bit4)
                in_adr              =              in_adr+8;
            else
                in_adr              =              in_adr+4;    
            end 
    end

always                              @             (posedge Clk)
    if                                            (out_en) 
    begin
        out_adr=out_adr+3;    
    end

always                              @             (posedge Clk)
    begin
        if (in_adr>out_adr+384 || (in_adr<out_adr && out_adr<in_adr+96)) 
        overflow1                   =               1;  
        else
        overflow1                   =               0;
    end
always                              @              (posedge Clk)
        begin
            if                                     (in_adr>out_adr+128)
            out_en                  =               1;
        end
endmodule