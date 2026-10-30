module shift_register(
                      input pclk,presetn,ss,send_data,receive_data,lsbfe,
                            mosi_send,miso_receive,miso,
                      input[7:0]data_mosi,
                      output reg mosi,
                      output[7:0]data_miso
                                          );
  reg[7:0] shift_reg,temp_reg;
  reg[2:0] count_ls,count_lr,count_ms,count_mr;


 always@(posedge pclk or negedge presetn)
  begin
   if(!presetn)
	 shift_reg<=0;
	else
    if(send_data)
      shift_reg<=data_mosi;
    end
 
 assign data_miso=receive_data?temp_reg:7'b0;
 
 always@(posedge pclk or negedge presetn)
  begin
   if(!presetn)
    begin
     count_ls<=0;
     count_lr<=0;
     count_ms<=7;
     count_mr<=7;
     mosi<=0;
     temp_reg<=0;
    end
   else
    if(!ss)
     begin
      if(lsbfe)
       begin
       
          if(mosi_send)
            begin
             mosi<=shift_reg[count_ls];
             count_ls<=count_ls+1'b1;
            end
    

        
          if(miso_receive)
            begin
             temp_reg[count_lr]<=miso;
             count_lr<=count_lr+1'b1;
            end
          
       end
    else
     begin
        
          if(mosi_send)  
            begin
             mosi<=shift_reg[count_ms];
             count_ms<=count_ms-1'b1;
            end
          

       
          if(miso_receive)
            begin
             temp_reg[count_mr]<=miso;
             count_mr<=count_mr-1'b1;
            end
        
       end
     end 
	  else
	   begin
     count_ls<=0;
     count_lr<=0;
     count_ms<=7;
     count_mr<=7;
    end
	  
 end 
endmodule
      
        
                      
