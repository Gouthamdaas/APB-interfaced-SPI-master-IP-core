module sclk_gen_tb();
 reg pclk,presetn,spiwai,cpol,cphase,ss;
   reg[2:0] sppr,spr;
   reg[1:0] spi_mode;
   wire sclk,miso_receive,mosi_send;
   wire [11:0] baud_rate_divisor;
 sclk_gen dut(pclk,presetn,spiwai,cpol,cphase,ss,sppr,spr,spi_mode,sclk,
          miso_receive,mosi_send,baud_rate_divisor);

  initial
   begin
    pclk<=0;
    #1;
   forever
     #5 pclk <= ~pclk;
   end
 task initialize();
   begin
     sppr=1;
     spr =1;
     spi_mode=00;
     ss=1;
     cpol=0;
     spiwai=0; 
    end
   endtask
 task rst();
   begin
    #1;
     presetn=0;
    #40
     presetn=1;
   end
  endtask
 task baudgen(input pol,phase,input[2:0]ppr,pr,input[1:0]cm);
   begin
    sppr<=ppr;
    spr <=pr;
    cpol<=pol;
    cphase<=phase;
    spi_mode<=cm;
    #10 ss=0;
   end
  endtask
initial
 begin
  initialize;
  rst;
  baudgen(0,1,2,2,0);
  #800;
  ss=1;
  #30;
  baudgen(1,1,1,1,1);
  #300;
  spiwai=1;
  #250;
  $finish;
 end
endmodule
 
 
     
     
 
    