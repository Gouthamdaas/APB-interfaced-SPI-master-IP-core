module spi_slave_tb();
  reg pclk,presetn,mastr,spiswai,send_data;
  reg [1:0] spi_mode;
  reg [11:0] baud_rate_divisor;
  wire receive_data,ss,tip;

 spi_slave_select dut( pclk,presetn,mastr,spiswai,send_data, spi_mode,
             baud_rate_divisor, receive_data,ss, tip);
  
  initial
   begin
    pclk=0;
    forever
     #5 pclk <= ~pclk;
   end
  
 task reset();
  begin
   presetn=0;
  #20;
   presetn=1;
  end
 endtask
  
 task initialize();
  begin
   spi_mode=10;
   spiswai=0;
   mastr=0;
   send_data=0;
   baud_rate_divisor=0;
  end
 endtask
  
 task stimulus(input [11:0]bds);
  begin
   spi_mode=00;
   mastr=1;
   send_data=1;
   baud_rate_divisor=bds;
  #10;
  @(posedge pclk)
    send_data<=0;
  end
 endtask
 
 task stop();
  begin
   spi_mode=10;
   send_data=0;
  end
 endtask
 
 initial
  begin
   initialize;
   reset;
   stimulus(4);
   #400;
   stop;
   #100;
   $finish;
  end
 
 endmodule
   
   
