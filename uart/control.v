module control(
    input wire              rst_n,
    input wire              clk,
    input wire  [7:0]       din,
    input wire  [7:0]       AB,
    input wire              set_rb8,
    input wire              rb8,
    input wire              rd_n,
    input wire              wr_n,
    input wire              TI,
    input wire              RI,
                        
    output wire             tb8,
    output wire             REN,
    output wire [7:0]       dout,
    output wire [1:0]       SM,
    output wire             SM2,                   
    output wire             SCON_RI,
    output wire             Intuart
    );
    
    reg [7:0]               SCON;
    
    wire                    SCON_select;
    

    always @(posedge clk or negedge rst_n)
        if(!rst_n)
            SCON <= 8'b0;
        else if(!wr_n && SCON_select)
            SCON <= din;
        else begin
            if(TI) SCON[1] <= 1'b1;      //收到Ti就给SCON的Ti位 置位
            if(RI) SCON[0] <= 1'b1;
            if(set_rb8) SCON[2] <= rb8;
        end
    
    assign  SCON_select = (AB == 8'h99);
    
    assign  dout = (!rd_n && SCON_select) ? SCON : 8'b0;
    
    assign  SM = SCON[7:6];
    assign  SM2 = SCON[5];
    assign  REN = SCON[4];
    assign  tb8 = SCON[3];
    assign  Intuart = SCON[1] || SCON[0];
    assign  SCON_RI = SCON[0];
    
            
endmodule