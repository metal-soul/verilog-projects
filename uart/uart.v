module uart(
    input           rst_n,
    input           clk,
    input   [7:0]   AB,
    inout   [7:0]   DB,
    inout   wire    RxD,   
    input           rd,
    input           wr,
    
    output  wire    TxD,
    output  wire    Intuart     
    );
    
    wire    [7:0]   din;
    wire    [7:0]   douttimer;
    wire    [7:0]   doutbuf;
    wire    [7:0]   doutcon;
    wire    [7:0]   dout;
    wire            TC;         
    wire            rb8;        

    wire    [1:0]   SM;        
    wire            SM2;
    wire            uart_select;
    
    wire            REN;
    wire            TEN;
    wire            tb8;
    wire            TI;
    wire            RxDo;       
    wire            set_rb8;
    wire            RI;
    wire            T7;
    wire            SCON_RI;
    wire            ENRxD;      
    
    assign  RxD = ENRxD ? RxDo : 1'bz;   
    assign  din = DB;
    assign  dout = douttimer | doutbuf | doutcon;
    
    assign  DB = (!rd && uart_select) ? dout : 8'bz;
    //判断地址是否选择了特殊功能寄存器                                                  
    assign  uart_select = (AB[7:4] == 4'b1001) & (   //
                          (AB[3:0] == 4'b0110) |     
                          (AB[3:0] == 4'b0111) |              
                          (AB[3:0] == 4'b1000) |     
                          (AB[3:0] == 4'b1001)        
                        );
                        
    baud_counter counter(
        .rst_n      (rst_n       ),
        .clk        (clk        ),
        .din        (din        ),
        .dout       (douttimer  ),
        .AB         (AB         ),
        .rd_n       (rd         ),
        .wr_n       (wr         ),
        .TEN        (TEN        ),
        .REN        (REN        ),
        .SM         (SM         ),
        .TC         (TC         )
    );
    
    fsm fsm1(
        .rst_n      (rst_n       ),
        .clk        (clk        ),
        .AB         (AB         ),
        .din        (din        ),
        .wr_n       (wr         ),
        .SM         (SM         ),
        .tb8        (tb8        ),
        .TC         (TC         ),
        .TI         (TI         ),
        .TxD        (TxD        ),
        .TEN        (TEN        ),
        .REN        (REN        ),
        .RxDo       (RxDo       ),
        .ENRxD      (ENRxD      ),
        .SCON_RI    (SCON_RI    ),
        .T7         (T7         )
    );
    
    receive receive1(
        .rst_n      (rst_n       ),
        .clk        (clk        ),
        .AB         (AB         ),
        .dout       (doutbuf    ),
        .rd_n       (rd         ),
        .SM         (SM         ),
        .SM2        (SM2        ),
        .set_rb8    (set_rb8    ),
        .rb8        (rb8        ),
        .TC         (TC         ),
        .RI         (RI         ),
        .RxD        (RxD        ),
        .REN        (REN        ),
        .SCON_RI    (SCON_RI    ),
        .T7         (T7         )
    );
    
    control control1(
        .rst_n      (rst_n       ),
        .clk        (clk        ),
        .din        (din        ),
        .dout       (doutcon    ),
        .AB         (AB         ),
        .rd_n       (rd         ),
        .wr_n       (wr         ),
        .SM         (SM         ),
        .SM2        (SM2        ),
        .REN        (REN        ),
        .tb8        (tb8        ),
        .set_rb8    (set_rb8    ),
        .rb8        (rb8        ),
        .TI         (TI         ),
        .RI         (RI         ),
        .SCON_RI    (SCON_RI    ),
        .Intuart    (Intuart    )
    );
    
endmodule