module fsm(
    input wire          rst_n,
    input wire          clk,
    input wire  [7:0]   din,
    input wire  [7:0]   AB,
    input wire          wr_n,
    input wire  [1:0]   SM,
                        
    input wire          tb8,
    input wire          TC,

    output reg          TI,
    output reg          TxD,
    output reg          TEN,
    input               REN,
    input               SCON_RI,
    output wire         RxDo,
    output wire         ENRxD,
    output              T7
    );
    
    reg [3:0]           Tbaud_counter;
    wire                Tbaud;
    wire                T0;

    reg                 TxDclk;
    reg [2:0]           Tstate,
                        Next_Tstate;
    
    `define idle        3'b000
    `define start       3'b001
    `define data        3'b010
    `define crc         3'b011
    `define stop        3'b100
    
    reg [2:0]           data_counter;
    wire                data_counter_end;
    reg [7:0]           TBUF;
    wire                TBUF_select;

    assign  ENRxD = !REN && TEN && (SM==2'b00);         // 方式0
    assign  RxDo = TBUF[0];                             // 方式0，RxD的输出
    
    assign  TBUF_select = (AB == 8'h98);


    always @(posedge clk)
        if((Tstate==`data)) begin
            if(((SM!=2'b00) && Tbaud) || ((SM==2'b00) && T8))
                TBUF <= TBUF >> 1;
        end
        else if(!wr_n && TBUF_select)
            TBUF <= din;
            
    always @(posedge clk or negedge rst_n)
        if(!rst_n)
            TEN <= 1'b0;
        else if((!wr_n && TBUF_select)|| (SM==2'b0 && REN))   //或者SM==0且REN为1
            TEN <= 1'b1;
        else if((Next_Tstate==`idle) && Tbaud)
            TEN <= 1'b0;
            
    always @(posedge clk or negedge rst_n)
        if(!rst_n)
            Tstate <= `idle;
        else if(Tbaud)
            Tstate <= Next_Tstate;
            
    always @(*)
        case(Tstate)
            `idle,
            `stop:      TxD = 1'b1;
            `start:     TxD = 1'b0;
            `data:    
                begin
                    if(SM == 2'b00)
                        TxD = TxDclk;                           //方式0 TxD用于传送同步时钟
                    else                        
                        TxD = TBUF[0];                          //方式1、2，传送数据
                end
            `crc:       TxD = tb8;
            default:    TxD = 1'bx;
        endcase      
          
    always @(*)
        case(Tstate)
            `idle:begin
                if(!TEN)
                    Next_Tstate = `idle;
                else if(SM == 2'b00)            //若为方式0，需要判断是在读还是在写
                    case (REN)
                        1'b1:   if(!SCON_RI)    Next_Tstate = `data;
                                else            Next_Tstate = `idle;  //RI置1后不再读取
                        1'b0:                   Next_Tstate = `data;
                        default : /* default */;
                    endcase
                else
                    Next_Tstate = `start;      //若为方式1、2，需要传送起始位
            end
            `start:                     //方式1、2传送起始位
                Next_Tstate = `data;
            `data:begin
                if(data_counter_end)
                    case(SM)
                        2'b00:Next_Tstate = `idle;          //方式0
                        2'b01:Next_Tstate = `stop;          //方式1直接传输停止位
                        2'b10,
                        2'b11:Next_Tstate = `crc;           //crc:奇偶校验，方式2需要再多传输一个tb8
                        default:;
                    endcase
                else
                    Next_Tstate = `data;
            end
            `crc:
                Next_Tstate = `stop;
            `stop:
                Next_Tstate = `idle;
            default:
                Next_Tstate = 3'bx;
        endcase
        
    always @(posedge clk)
        if(!TEN)
            Tbaud_counter <= 4'b0000;
        else if(TC)
            Tbaud_counter <= Tbaud_counter+1'b1;
            
    assign  Tbaud = (Tbaud_counter == 4'b1111) && TC;
    assign  T7 = (Tbaud_counter == 4'b0111) && TC;         
    assign  T8 = (Tbaud_counter == 4'b1000) && TC;
    
    assign  data_counter_end = (data_counter==3'b111);
    
    always @(posedge clk)
        if(Tstate!=`data)
            data_counter <= 0;
        else if(Tbaud)
            data_counter <= data_counter+1'b1;
    
    always @(posedge clk)
        if(SM==2'b10)
            TI = (Tstate==`crc) && Tbaud;
        else if((SM==2'b00) && REN)                         // 方式0接受不要发TI中断
            TI = 1'b0;
        else
            TI = data_counter_end && Tbaud;                 // 方式0，1发送数据结束发中断
            
    always @(posedge clk)
        if(Tstate!=`data)
            TxDclk <= 1'b0;
        else if(T7 || Tbaud)
            TxDclk <= !TxDclk;
            
    
endmodule