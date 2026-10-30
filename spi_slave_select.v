module spi_slave_select( 
             input pclk,presetn,mastr,spiswai,send_data,
             input [1:0] spi_mode,
             input[11:0] baud_rate_divisor,
             output reg receive_data,ss,
             output tip
                        );
     reg[15:0] count;
     wire[15:0] target;
     reg rcv;
  assign target = baud_rate_divisor * 8;
  assign tip = (!ss);
  
 always@(posedge pclk or negedge presetn)
  begin
   if(!presetn)
    begin
     count<=16'hffff;
     ss<=1;
     rcv<=0;
    end
   else
    if((spi_mode==2'b00)||((spi_mode==2'b01)&&spiswai)&& mastr)
      
       if(send_data)
        begin
         count<=0;
         ss<=0;
        end
       else
         
         if(count <= (target-1'b1))
          begin
           count <= count+1'b1;
           ss<=0;
           if(count == (target-1'b1))
            rcv <= 1;
          end          
         else
          begin
           count<=16'hffff;
           ss<=1'b1;
           rcv <= 0;
          end
     else
      begin
       count <= 16'hffff;
       ss<=1'b1;
       rcv<=0;
      end
    end

  always@(posedge pclk or negedge presetn)
   begin
    if(!presetn)
      receive_data<=0;
    else
     receive_data<=rcv;
   end
 endmodule
       
 
 

   