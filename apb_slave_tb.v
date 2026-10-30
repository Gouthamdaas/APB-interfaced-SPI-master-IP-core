module apb_slave();
  reg pclk,presetn,pwrite,psel,penable,ss,receive_data,tip;
  reg[7:0] pwdata,data_miso;
  reg[2:0] paddr;
  wire[7:0] prdata,data_mosi;
  //wire[7:0] var1,var2;
  wire send_data,mstr,cpol,cphase,lsbfe,spiswai, 
         sir, pready,pslverr;
  wire [2:0] spr,sppr;
  wire [1:0] spi_mode;

 apb_slave_interface dut(  pclk,presetn,pwrite,psel,penable,ss,receive_data,
                          tip, pwdata,data_miso,paddr,prdata,data_mosi,
                          send_data,  mstr,cpol,cphase,lsbfe,spiswai,sir,
                           pready,pslverr, spr,sppr, spi_mode);

   initial 
    begin
     pclk=0;
     forever 
       #5 pclk<= ~pclk;
     end
   
 //assign var1[7:0] = dut.spi_cr_1;
 //assign var2[7:0] = dut.spi_dr; 


  task reset();
   begin
    @(negedge pclk)
       presetn <=0;
     #10;
      @(negedge pclk)
     presetn  <= 1;
   end
  endtask
  
  task initialize();
   begin 
    @(negedge pclk)
    penable<=0;
    psel <=0;
    ss<=1'b1;
    tip<=1'b0;
    data_miso<=0;
    receive_data<=0;
   end
  endtask
 
 task write(input [2:0]addr, input[7:0]data);
   begin
    @(negedge pclk)
    paddr <= addr;
    pwrite<=1'b1;
    psel <= 1'b1;
    pwdata <= data;
   @(negedge pclk)
    penable <=  1'b1;
    tip<=1'b1;
   @(negedge pclk)
    penable <=0;
    tip<=1'b0;
   end
  endtask
  
 task read(input[2:0] adr);
   begin
    @(negedge pclk)
    paddr <= adr;
    pwrite <= 1'b0;
    psel <= 1'b1;
    @(negedge pclk)
    penable<=1;
    tip<=1'b1;
    @(negedge pclk)
    penable <= 0;
    tip<=1'b0;
   end
endtask
 
 initial
  begin
   reset;
   initialize;
   write(3'b000,8'b11110100);
   write(3'b001,8'b11000010);
   write(3'b010,8'b00100111);
   write(3'b101,8'b11001111);
   #30;
   data_miso<=8'b10101100;
   receive_data<=1;
   #5;
   read(3'b101);
   #30 ;
   $finish;
  end
endmodule
   
 
 
    
   
      
 
