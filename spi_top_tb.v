module spi_top_tb();
 
 reg pclk,presetn,pwrite,psel,penable,miso;
 reg[2:0]paddr;
 reg[7:0]pwdata;
 wire ss,sclk,mosi,sir,pready,pslverr;
 wire[7:0]prdata;
 integer i;
// wire var;
 //assign var = spt.scg.count;
 
 spi_top spt( pclk,presetn,pwrite,psel,penable,miso,
            paddr,pwdata,
             ss,sclk,mosi,sir,pready,pslverr,
              prdata);
 
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
    paddr<=0;
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
   @(negedge pclk)
    penable <=0;
   end
  endtask
 
 task slave(input[7:0] slave_data);
  begin
 wait(!ss)
 for(i=0;i<8;i=i+1)
 // begin
  // if(spt.asi.cpol==spt.asi.cphase)
  //  begin
  //   @(negedge sclk)
  //   miso<=slave_data[i];
  //  end
  // else
    begin
     @(posedge sclk)
     miso<=slave_data[i];
    end
 // end
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
    @(negedge pclk)
    penable <= 0;
   end
endtask
 
 initial
  begin
   reset;
   initialize;
   write(3'b000,8'b11110100);
   write(3'b001,8'b11000010);
   write(3'b010,8'b00010000);
   write(3'b101,8'b11001111);
   slave(8'b10110010);
   wait(spt.sps.receive_data)
   read(3'b101);
   #80 ;
   $finish;
  end
endmodule
   
 
