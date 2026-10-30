module spi_top(
               input pclk,presetn,pwrite,psel,penable,miso,
               input[2:0]paddr,input[7:0]pwdata,
               output ss,sclk,mosi,sir,pready,pslverr,
               output[7:0]prdata 
                                 );
   wire spiswai,cpol,cphase,miso_receive,
        mosi_send,send_data,receive_data,lsbfe,tip,mastr;
   wire[1:0]spi_mode;
   wire[2:0]sppr,spr;
   wire[7:0]data_mosi,data_miso;
   wire[11:0]baud_rate_divisor;
  
   sclk_gen scg( pclk,presetn,spiswai,cpol,cphase,ss,
                 sppr,spr,spi_mode,sclk,miso_receive,
                 mosi_send, baud_rate_divisor);
   
   shift_register shr(  pclk,presetn,ss,send_data,receive_data,lsbfe,
                       mosi_send,miso_receive,miso,data_mosi, mosi,
                       data_miso    );
 
   apb_slave_interface asi( pclk,presetn,pwrite,psel,penable,ss,receive_data,
                            tip,pwdata,data_miso,paddr,prdata,data_mosi,
                           send_data, mastr,cpol,cphase,lsbfe,spiswai,
                           sir, pready,pslverr, spr,sppr, spi_mode  );
  
   spi_slave_select sps(  pclk,presetn,mastr,spiswai,send_data, spi_mode,
                      baud_rate_divisor, receive_data,ss, tip );
 
endmodule
 
  