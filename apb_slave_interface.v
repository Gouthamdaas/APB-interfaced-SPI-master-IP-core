module apb_slave_interface(
             
      input pclk,presetn,pwrite,psel,penable,ss,receive_data,tip,
      input[7:0]pwdata,data_miso,
      input[2:0] paddr,
      output reg [7:0]prdata,data_mosi,
      output reg send_data,
      output  mastr,cpol,cphase,lsbfe,spiswai,
      output   sir,
      output pready,pslverr,
      output  [2:0] spr,sppr,
      output reg [1:0] spi_mode  
                              );
  
   localparam idle=2'b00;
   localparam setup=2'b01;
   localparam enable=2'b10;
    
   localparam spi_run=2'b00;
   localparam spi_wait=2'b01;
   localparam spi_stop=2'b10;
  
   localparam cr2_mask=8'b00011011;
   localparam br_mask=8'b01110111;
  
   reg[1:0] state;
   reg[1:0] next_state;
   reg[1:0] next_mode;  
  
   wire spie,sptie,spe,modf,ssoe,rd_enb,wr_enb;

   reg spif,sptef;
   reg[7:0] spi_cr_1;
   reg[7:0] spi_cr_2;
   reg[7:0] spi_br;
   reg[7:0] spi_sr;
   reg[7:0] spi_dr;
 
  always@(posedge pclk or negedge presetn)
   begin
     if(!presetn)
      state<=idle;
     else
      state<=next_state;
    end
 always@(*)
   begin
     case (state)
       idle: if(psel && !penable)
               next_state=setup;
             else 
               next_state=idle;
       setup: begin
              if(psel && penable)
               next_state=enable;
              else
                if(psel && !penable)
                 next_state=setup;
              else
                next_state=idle;
              end
       enable: begin
              if(psel)
                next_state=setup;
               else
                next_state=idle;
               end
       default:next_state=idle;
      endcase
    end
  
    assign pready=(state==enable)?1'b1:1'b0;
    assign pslverr=(state==enable)? ~tip:1'b0;

    assign wr_enb=(state==enable)&&pwrite;
    assign rd_enb=(state==enable)&& !pwrite;

  always@(posedge pclk or negedge presetn)
    begin
     if (!presetn)
       begin
        spi_cr_1 <=0;
        spi_cr_2 <=0;
        spi_br <=0;
        spi_dr <=0;
        send_data<=0;
        data_mosi<=0;
      end
    else
      begin
        if(wr_enb)
          begin
           case(paddr)
            3'b000 : spi_cr_1<=pwdata;
            3'b001 : spi_cr_2<=cr2_mask & pwdata;
            3'b010 : spi_br<= br_mask & pwdata;
            3'b101 : spi_dr<= pwdata;
           default : spi_dr<=pwdata;
          endcase
         end 
      
      
           
      else if((spi_dr==pwdata)&&(spi_dr !== data_miso)&&((spi_mode==spi_run) || 
                     (spi_mode == spi_wait)))
          begin
           send_data <= 1'b1;
           data_mosi <= spi_dr;
           spi_dr <=8'b00000000;
          end
    
      else if(receive_data &&(spi_mode==spi_run || spi_mode==spi_wait))
         begin
           spi_dr <= data_miso;
           send_data <=0;
         end
       else
         send_data<=0;
     
      end
 end

   always@(*)
    begin
    if (rd_enb)
     begin
      case(paddr)
            3'b000 : prdata<=spi_cr_1;
            3'b001 : prdata<=spi_cr_2;
            3'b010 : prdata<=spi_br;
            3'b011 : prdata<=spi_sr;
            3'b101 : prdata<=spi_dr;
           default : prdata<=8'b00000000;
        endcase
      end
       else
         prdata<=8'b00000000;
      end
   
   assign mastr=spi_cr_1[4];
   assign cpol=spi_cr_1[3];
   assign cphase=spi_cr_1[2];
   assign ssoe=spi_cr_1[1];
   assign lsbfe=spi_cr_1[0];
   assign spie=spi_cr_1[7];
   assign spe=spi_cr_1[6];
   assign sptie=spi_cr_1[5];
   assign modfen=spi_cr_2[4];
   assign spiswai=spi_cr_2[1];
   assign sppr=spi_br[6:4];
   assign spr=spi_br[2:0];
 
  assign modf=((!ss) && mastr && modfen && (!ssoe));
  
  assign sir = ( !spie && !sptie)? 0:
                                 (!spie && sptie)? sptef:
                                 (spie && !sptie)? (spif || modf):
                                 (spif||modf||sptef);
  
 always@(posedge pclk or negedge presetn)
    begin
        if(!presetn)
          spi_mode<=spi_run;
        else
          spi_mode<=next_mode;
    end
  
  always@(*)
   begin
    case(spi_mode)
       spi_run: next_mode=spe?spi_run:spi_wait;
       spi_wait: begin
                   if(spe)
                     next_mode=spi_run;
                 else if (spiswai)
                     next_mode=spi_stop;
                 end
       spi_stop: next_mode=spe?spi_run:spiswai?spi_stop:spi_wait;
       default: next_mode=spi_run;
    endcase
   end

 always@(*)
  begin
    if(!presetn) 
     begin
      sptef=0;
     spif=0;
     spi_sr<=8'b00000000;
     end
    else
     begin
      if(spi_dr==8'b00000000)
        sptef=1'b1;
      else
        sptef=0;
      if(spi_dr !== 8'b00000000)
        spif=1'b1;
      else
        spif=0;
     spi_sr <= {spif,1'b0,sptef,modf,4'b0000};
    end 
  end
 endmodule
 
        
      
