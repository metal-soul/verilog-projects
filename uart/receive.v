module receive(
    input wire           rst_n,
    input wire           clk,
    input wire  [7: 0]   AB,
    output wire [7: 0]   dout,
    input wire           rd_n,
    input wire  [1: 0]   SM,
    input wire           SM2,
    output reg           set_rb8,
                         rb8,
                        
    input wire           TC,
    output reg           RI,
    input wire           SCON_RI,
    input wire           RxD,
    
    input wire           REN,
    input wire           T7
    );
   
    reg         [3: 0]   Rbaud_counter;
    wire                 Rbaud;
    wire                 R7,R8,R9;
    
    reg         [2: 0]   Rstate,
                         Next_Rstate;
    

    reg                 Rxdin;                  
    reg         [2: 0]  data_capture;
    reg                 Rvalid;  
    reg         [2: 0]  data_counter;
    wire                data_counter_end;
    reg         [7: 0]  Rshift,
                        RBUF;

    wire                RBUF_select;
    wire                recvJudge;    



    `define idle         3'b000
    `define start        3'b001
    `define data         3'b010
    `define crc          3'b011
    `define stop         3'b100 

    always @(posedge clk or negedge rst_n)
        if(!rst_n)
            Rvalid <= 1'b0;
        else if(SM == 2'b00)
            Rvalid <= REN;
        else case (Rstate)
            `idle:  if(REN)
                        Rvalid <= !RxD;
            `start: if(Rbaud)
                        Rvalid <= !Rxdin;
            `crc:   if(Rbaud)
                        Rvalid <= recvJudge;
            `stop:  if((SM == 2'b01) && Rbaud)
                        Rvalid <= recvJudge;
            default :;
        endcase

    always @(posedge clk)
        if(!REN)
            data_capture <= 3'b111;
        else if(R7 || R8 || R9) begin                //采样
            data_capture[0] <= RxD;
            data_capture[2:1] <= data_capture[1:0];
        end
    
    always @(data_capture)
        case(data_capture)
            3'b111, 3'b011, 3'b110, 3'b101 : Rxdin = 1'b1;
            default:Rxdin = 1'b0;
        endcase
        
    always @(posedge clk or negedge rst_n)
        if(!rst_n)
            Rstate <= `idle;
        else if(Rbaud)
            Rstate <= Next_Rstate;


    always @(*)
        case(Rstate)
            `idle:begin
                if(!REN)
                    Next_Rstate = `idle;
                else if(SM == 2'b00)
                    /*
                    case (SCON_RI)
                        1'b0:   Next_Rstate = `data;
                        1'b1:   Next_Rstate = `idle;
                        default :  default ;
                    endcase*/
                    if(!SCON_RI)
                        Next_Rstate = `data;
                    else
                        Next_Rstate = `idle;

                else if(Rvalid)
                    Next_Rstate = `start;
                else
                    Next_Rstate = `idle;
            end
            `start:begin
                if(!Rxdin)
                    Next_Rstate = `data;
                else
                    Next_Rstate = `idle;
            end
            `data:begin
                if(data_counter_end)
                    case(SM)
                        2'b00,
                        2'b01 : Next_Rstate = `stop;

                        2'b10,
                        2'b11 : Next_Rstate = `crc;
                        default: ;
                    endcase
                else
                    Next_Rstate = Rstate;
            end
            `crc:   if(recvJudge)
                        Next_Rstate = `stop;
                    else
                        Next_Rstate = `idle;
            `stop:  Next_Rstate = `idle;
            default: ;
        endcase
    

    always @(posedge clk)
        if(Rstate != `data)
            data_counter <= 3'b000;
        else if((Rstate == `data) && Rbaud)
            data_counter <= data_counter + 1'b1;

    
    always @(posedge clk) begin
        if((Rstate == `data) && Rbaud)
            Rshift <= {Rxdin, Rshift[7: 1]};
    end

    
    always @(posedge clk)
        if((Rstate == `stop) && Rbaud)
            case (SM)
                2'b01:  if(recvJudge)
                            RBUF <= Rshift;
                default:    RBUF <= Rshift;
            endcase
                
    
    always @(*)
        if(Rstate == `crc && recvJudge) begin
            set_rb8 = Rbaud;
            rb8     = Rxdin;
        end else begin
            set_rb8 = 0;
            rb8     = 0;
        end
    
    always @(posedge clk)
        if(!REN)                              //复位 Rbaud不然下一个数据无法接收
            Rbaud_counter <= 4'b1111;
        else if(Rvalid && TC)
            Rbaud_counter <= Rbaud_counter + 1'b1;
        else if(!Rvalid)
            Rbaud_counter <= 4'b1111;


    assign  Rbaud = (SM == 2'b00)? (T7) : ((Rbaud_counter == 4'b1111) && TC);
    assign  R7 = (Rbaud_counter == 4'b0111) && TC;
    assign  R8 = (Rbaud_counter == 4'b1000) && TC;
    assign  R9 = (Rbaud_counter == 4'b1001) && TC;
    
    always @(posedge clk)
        RI <= (Rstate == `stop) && Rbaud;

    assign  data_counter_end = (data_counter == 3'b111);
    assign  RBUF_select = (AB == 8'h98);
    assign  dout = (!rd_n && RBUF_select) ? RBUF : 8'b0;
    assign recvJudge    = (Rxdin || !SM2) && !SCON_RI; 


endmodule