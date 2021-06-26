module baud_counter(
    input                   rst_n,
    input                   clk,
    input                   rd_n,
    input                   wr_n,                   
    input                   TEN,
    input                   REN,
    input       [1:0]       SM, 
    input       [7:0]       din,
    input       [7:0]       AB, 
    output      [7:0]       dout,               
    output                  TC                     
    );
    
    reg [7:0]               th, thB;
    reg [7:0]               tl, tlB;
    
    wire                    thselect, tlselect;     
    wire                    ENtimec;
    
    
    always @(posedge clk or negedge rst_n)
        if(!rst_n) begin
            thB <= 8'b0;
            tlB <= 8'b0;
        end else begin
            if(!wr_n && thselect) thB <= din;       //设置初值
            if(!wr_n && tlselect) tlB <= din;
        end
        
    always @(posedge clk)                           //六分频溢出
        if(!ENtimec || TC)                          //如果还没开始计数或者一次溢出，就重置T1为初值
            if(SM == 2'b00) begin
                th <= 8'b1111_1111;
                tl <= 8'b1111_1010;                 //方式0时直接用T1 6分频
            end else begin
                th <= thB;
                tl <= tlB;
            end
        else
            {th, tl} <= {th, tl} + 1'b1;           //T1计数


    assign  thselect = (AB == 8'h97);
    assign  tlselect = (AB == 8'h96);
    
    assign  dout = (!rd_n && thselect) ? thB : 
                   (!rd_n && tlselect) ? tlB : 8'b0;
                   
    assign  ENtimec = TEN || REN;                   //开始计数
    assign  TC = &{th, tl};                         //全一溢出脉冲一周期

endmodule