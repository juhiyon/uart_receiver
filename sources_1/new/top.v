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
reg rxd_in=1'b1;//1bit�� �����Ƿ� 1bit�� �޴´�, Ŭ���� ������� ������ �� ����
reg [2:0] rx_st=0;//max : 3
reg d;
reg [2:0] rx_index=0;//max : 7
reg [7:0] rxd_result=0;//�̰� ���ʿ� �迭 

//clk�� ������� rxd�� ���� ���� rx_data�� ����
always @* begin
    rxd_in<=rxd;
end

//data �������Ϳ� ����Ʈ
always@(posedge clk)//Ŭ���� ����
begin
    case(rx_st)
    IDLE_ST :
        begin 
            d <= 1;//�ƹ� �� ���� �� 1�� ��� ���� �Ǵ� IDLE_ST
            clk_cnt <= 0;
            
            if(rxd_in == 1'b0)
            begin
                rx_st <= START_ST;//��ŸƮ ��Ʈ ������ START_ST��
            end
            else
                rx_st <= IDLE_ST;//�״��
        end//clk�� ���� ���� �κ�
        
    START_ST :
        begin
            d <= 0;//start bit
            if(clk_cnt == 1084)
            begin
                clk_cnt<=0;
                rx_st<=DATA_ST;//�� Ŭ�� �ڿ� data�� �̵�
            end
            else
                clk_cnt <= clk_cnt +1;
        end
        
    DATA_ST :
        begin
            d <= rxd_in;//������ ����
            if(clk_cnt == 1084)
            begin//Ŭ������ ���� ��ġ�� ���� ���� ��ġ�� �̵�
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