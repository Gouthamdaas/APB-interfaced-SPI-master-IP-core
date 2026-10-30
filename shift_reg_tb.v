module shift_reg_tb();

                   
  reg pclk,presetn,ss,send_data,receive_data,lsbfe;
  wire mosi_send,miso_receive,mosi;
   reg [7:0]data_mosi;
   reg miso,spiwai,cpol,cphase;
   wire[7:0]data_miso;
  reg[2:0] sppr,spr;
   reg[1:0] spi_mode;
   wire [11:0] baud_rate_divisor;
  wire[7:0] var1,var2;
 integer i;

 shift_register dut(pclk,presetn,ss,send_data,receive_data,lsbfe,
                     mosi_send,miso_receive,miso,data_mosi,mosi,data_miso);
 
 sclk_gen test(pclk,presetn,spiwai,cpol,cphase,ss,sppr,spr,spi_mode,sclk,
          miso_receive,mosi_send,baud_rate_divisor);

 assign var1=dut.temp_reg; 
 assign var2=dut.shift_reg;
  initial
   begin
    pclk<=0;
    #1;
   forever
     #5 pclk <= ~pclk;
   end
 task initialize();
   begin
     send_data=0;
     receive_data=0;
     miso=0;
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
   @(posedge pclk)
    sppr<=ppr;
    spr <=pr;
    cpol<=pol;
    cphase<=phase;
    spi_mode<=cm;
   end
  endtask
task sample(input[7:0] data,input lsb);
 begin
  @(posedge pclk)
   data_mosi=data;
   send_data=1;
  @(posedge pclk)
   send_data<=0;
   lsbfe<=lsb;
   ss<=0;
 @(posedge pclk)
  repeat(8)
   @(posedge sclk);
  @(negedge sclk)
   ss<=1;
   receive_data=1;
  @(posedge pclk)
  @(posedge pclk)
   receive_data=0;

 end
 endtask

task slave();
 begin
 repeat(3)
 @(posedge pclk);
 
 for(i=0;i<8;i=i+1)
  begin
 @(negedge sclk)
  miso<=i;
 end
 end
endtask
   
  
   



initial
 begin
  initialize;
  rst;
  baudgen(1,1,2,2,0);
 fork
  sample(8'b11010010,1);
  slave;
 join
  baudgen(1,1,1,2,0);
 fork
  sample(8'b10110010,0);
  slave;
 join
  #100;
  $finish;
 end
endmodule 