`timescale 1ns / 1ps
module top(clk, rst, rxd, ld6r, ld6g, ld6b) ;
input clk, rst, rxd;
output reg ld6r, ld6g, ld6b;

parameter IDLE_ST=3'b000,
          START_ST=3'b001,
          DATA_ST=3'b010,
          STOP_ST=3'b011;
          
reg rxclk;
reg [10:0] clk_cnt=0;//max : 542
reg rxd_in=1'b1;//1bit씩 보내므로 1bit씩 받는다, 클럭에 관계없이 들어오는 갑 저장
reg [2:0] rx_st=0;//max : 3
reg d;
reg [2:0] rx_index=0;//max : 7
reg [7:0] rxd_result=0;//이건 애초에 배열 

//clk에 상관없이 rxd로 들어온 값을 rx_data에 적재
always @* begin
    rxd_in<=rxd;
end

//data 레지스터에 시프트
always@(posedge clk)//클럭에 따라
begin
    case(rx_st)
    IDLE_ST :
        begin 
            d <= 1;//아무 값 없을 때 1로 계속 전송 되니 IDLE_ST
            clk_cnt <= 0;
            
            if(rxd_in == 1'b0)
            begin
                rx_st <= START_ST;//스타트 비트 받으면 START_ST로
            end
            else
                rx_st <= IDLE_ST;//그대로
        end//clk에 관계 없는 부분
        
    START_ST :
        begin
            d <= 0;//start bit
            if(clk_cnt == 1084)
            begin
                clk_cnt<=0;
                rx_st<=DATA_ST;//한 클럭 뒤에 data로 이동
            end
            else
                clk_cnt <= clk_cnt +1;
        end
        
    DATA_ST :
        begin
            d <= rxd_in;//데이터 저장
            if(clk_cnt == 1084)
            begin//클럭에서 현재 위치에 따른 다음 위치로 이동
                clk_cnt<=0;
                rxd_result[rx_index] <= rxd_in;
                
                if(rx_index < 7)
                begin
                    rx_index <= rx_index + 1;
                end
                else
                begin
                    rx_index <= 0;
                    rx_st<=STOP_ST;
                end
            end
            else
                clk_cnt <= clk_cnt +1;
        end
        
    STOP_ST : 
        begin
            d<=1'b1;//stop bit
            if(clk_cnt == 1084)
            begin
                clk_cnt<=0;
                rx_st<=IDLE_ST;
            end
            else
                clk_cnt <= clk_cnt +1;
        end
             
    default :
        rx_st <= IDLE_ST;
        
    endcase
end

always@(rxd_result)
begin
if(rxd_result == 8'h72)
begin
    ld6r<=1;
    ld6g<=0;
    ld6b<=0;
end
else if(rxd_result == 8'h67)
begin
    ld6r<=0;
    ld6g<=1;
    ld6b<=0;
end
else if(rxd_result == 8'h62)
begin
    ld6r<=0;
    ld6g<=0;
    ld6b<=1;
end
else
begin
    ld6r<=0;
    ld6g<=0;
    ld6b<=0;
end
end

endmodule