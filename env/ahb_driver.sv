class ahb_driver;
   virtual ahb_interface vif;
   ahb_transaction tr;
  // event drvnext;
   mailbox #(ahb_transaction)mbxgd; 

function new(mailbox #(ahb_transaction)mbxgd,virtual ahb_interface vif);
     this.mbxgd = mbxgd;
     this.vif = vif;
endfunction

task reset();
   vif.hresetn <= 1'b0;
   vif.hwdata  <= 0;
   vif.haddr   <= 0;
   vif.hsize   <= 0;
   vif.hwrite  <= 0;
   vif.hsel    <= 0;
   vif.htrans  <= 0;
   repeat(5) @(posedge vif.clk)
      vif.hresetn <= 1'b1;
      $display("[DRV] => RESET DONE");
      $display("------------------------");
endtask

task single_tr_wr();
   @(posedge vif.clk);
   vif.hresetn <= 1'b1;
   vif.hburst  <= 3'b000;
   vif.hsel    <= 1'b1;
   vif.hwrite  <= 1;
   vif.hwdata  <= tr.hwdata;
   vif.hsize   <= 3'b010;
   vif.haddr   <= tr.haddr;
   vif.htrans  <= 2'b00;
   @(posedge vif.hready);
   @(posedge vif.clk);
   $display("[DRV] single transaction write haddr=%0d hwdata=%0d",tr.haddr,tr.hwdata);
endtask

task single_tr_rd();
   @(posedge vif.clk);
   vif.hresetn <= 1'b1;
   vif.hburst  <= 3'b000;
   vif.hsel    <= 1'b1;
   vif.hwrite  <= 1'b0;
   vif.hsize   <= 3'b010;
   vif.hwdata  <= 0;
   vif.haddr   <= tr.haddr;
   vif.htrans  <= 2'b00;
   vif.hrdata  <= tr.hrdata;
   @(posedge vif.hready);
   @(posedge vif.clk);
   $display("[DRV] single transaction read haddr=%0d hrdata=%0d ",tr.haddr,tr.hrdata);
endtask

task unspec_len_wr();
   @(posedge vif.clk);
   vif.hresetn <= 1'b1;
   vif.hburst  <= 3'b001;
   vif.hsel    <= 1'b1;
   vif.hwrite  <= 1;
   vif.hwdata  <= tr.hwdata;
   vif.hsize   <= 3'b010;
   vif.haddr   <= tr.haddr;
   vif.htrans  <= 2'b00;
   @(posedge vif.hready);
   @(posedge vif.clk);
   $display("[DRV] unspecified length write haddr=%0d hwdata=%0d",vif.haddr,vif.hwdata);

   repeat(tr.ulen-1) begin
      vif.hwdata <= tr.hwdata;//$urandom_rang(1,50);
      vif.htrans <= 2'b01;
      @(posedge vif.hready);
      @(posedge vif.clk);
      $display("[DRV] unspecified length write haddr=%0d hwdata=%0d",vif.haddr,vif.hwdata);
   end
   d_flag = 1;
endtask

task unspec_len_rd();
   @(posedge vif.clk);
   vif.hresetn <= 1'b1;
   vif.hburst  <= 3'b001;
   vif.hsel    <= 1'b1;
   vif.hwrite  <= 1'b0;
   vif.hsize   <= 3'b010;
   vif.hwdata  <= $urandom_range(1,50);//0;
   vif.haddr   <= tr.haddr;
   vif.htrans  <= 2'b00;
   vif.hrdata  <= tr.hrdata;
   @(posedge vif.hready);
   @(posedge vif.clk);
   $display("[DRV] unspecified length read haddr=%0d hrdata=%0d ",vif.haddr,vif.hrdata);

   repeat(tr.ulen-1) begin
      vif.hwdata <= tr.hwdata;//$urandom_range(1,50);
      vif.htrans <= 2'b01;
      @(posedge vif.hready);
      @(posedge vif.clk);
      $display("[DRV] unspecified length read haddr=%0d hwdata=%0d",vif.haddr,vif.hrdata);
   end
   d_flag = 1;
endtask

task wrap4_wr();
   @(posedge vif.clk);
   vif.hresetn <= 1'b1;
   vif.hburst  <= 3'b010;
   vif.hsel    <= 1'b1;
   vif.hwrite  <= 1;
   vif.hwdata  <= tr.hwdata;
   vif.hsize   <= 3'b010;
   vif.haddr   <= tr.haddr;
   vif.htrans  <= 2'b00;
   @(posedge vif.hready);
   @(posedge vif.clk);
   $display("[DRV] wrap4 write haddr=%0h hwdata=%0d",vif.haddr,vif.hwdata);

   repeat(3) begin
      vif.hwdata <= tr.hwdata;//$urandom_rang(1,50);
      vif.htrans <= 2'b01;
      @(posedge vif.hready);
      @(posedge vif.clk);
      $display("[DRV] wrap4 write haddr=%0h hwdata=%0d",vif.haddr,vif.hwdata);
   end
   //return to idle
   vif.hsel<=1'b0;
   vif.htrans<=2'b00;
   d_flag = 1;
endtask

task wrap4_rd();
   @(posedge vif.clk);
   vif.hresetn <= 1'b1;
   vif.hburst  <= 3'b010;
   vif.hsel    <= 1'b1;
   vif.hwrite  <= 1'b0;
   vif.hsize   <= 3'b010;
   vif.hwdata  <= $urandom_range(1,50);
   vif.haddr   <= tr.haddr;
   vif.htrans  <= 2'b00;
   vif.hrdata  <= tr.hrdata;
   @(posedge vif.hready);
   @(posedge vif.clk);
   $display("[DRV] wrap4 read haddr=%0h hrdata=%0d ",vif.haddr,vif.hrdata);

   repeat(3) begin
      vif.hwdata <= tr.hwdata;//$urandom_range(1,50);
      vif.htrans <= 2'b01;
      @(posedge vif.hready);
      @(posedge vif.clk);
      $display("[DRV] wrap4 read haddr=%0h hwdata=%0d",vif.haddr,vif.hrdata);
   end
    vif.hsel<=1'b0;
   vif.htrans<=2'b00;

   d_flag = 1;
endtask

task incr4_wr();
   @(posedge vif.clk);
   vif.hresetn <= 1'b1;
   vif.hburst  <= 3'b011;
   vif.hsel    <= 1'b1;
   vif.hwrite  <= 1;
   vif.hwdata  <= tr.hwdata;
   vif.hsize   <= 3'b010;
   vif.haddr   <= tr.haddr;
   vif.htrans  <= 2'b00;
   @(posedge vif.hready);
   @(posedge vif.clk);
   $display("[DRV] incr4 write haddr=%0h hwdata=%0d",vif.haddr,vif.hwdata);

   repeat(3) begin
      vif.hwdata <= tr.hwdata;//$urandom_rang(1,50);
      vif.htrans <= 2'b01;
      @(posedge vif.hready);
      @(posedge vif.clk);
      $display("[DRV] incr4 write haddr=%0h hwdata=%0d",vif.haddr,vif.hwdata);
   end
   d_flag = 1;
endtask

task incr4_rd();
   @(posedge vif.clk);
   vif.hresetn <= 1'b1;
   vif.hburst  <= 3'b011;
   vif.hsel    <= 1'b1;
   vif.hwrite  <= 1'b0;
   vif.hsize   <= 3'b010;
   vif.hwdata  <= $urandom_range(1,50);
   vif.haddr   <= tr.haddr;
   vif.htrans  <= 2'b00;
   vif.hrdata  <= tr.hrdata;
   @(posedge vif.hready);
   @(posedge vif.clk);
   $display("[DRV] incr4 read haddr=%0h hrdata=%0d ",vif.haddr,vif.hrdata);

   repeat(3) begin
      vif.hwdata <= tr.hwdata;//$urandom_range(1,50);
      vif.htrans <= 2'b01;
      @(posedge vif.hready);
      @(posedge vif.clk);
      $display("[DRV] incr4 read haddr=%0h hwdata=%0d",vif.haddr,vif.hrdata);
   end
   d_flag = 1;
endtask


task wrap8_wr();
   @(posedge vif.clk);
   vif.hresetn <= 1'b1;
   vif.hburst  <= 3'b100;
   vif.hsel    <= 1'b1;
   vif.hwrite  <= 1;
   vif.hwdata  <= tr.hwdata;
   vif.hsize   <= 3'b010;
   vif.haddr   <= tr.haddr;
   vif.htrans  <= 2'b00;
   @(posedge vif.hready);
   @(posedge vif.clk);
   $display("[DRV] wrap8 write haddr=%0h hwdata=%0d",vif.haddr,vif.hwdata);

   repeat(7) begin
      vif.hwdata <= tr.hwdata;//$urandom_rang(1,50);
      vif.htrans <= 2'b01;
      @(posedge vif.hready);
      @(posedge vif.clk);
      $display("[DRV] wrap8 write haddr=%0h hwdata=%0d",vif.haddr,vif.hwdata);
   end
    vif.hsel<=1'b0;
   vif.htrans<=2'b00;

   d_flag = 1;
endtask


task wrap8_rd();
   @(posedge vif.clk);
   vif.hresetn <= 1'b1;
   vif.hburst  <= 3'b100;
   vif.hsel    <= 1'b1;
   vif.hwrite  <= 1'b0;
   vif.hsize   <= 3'b010;
   vif.hwdata  <= 0;//$urandom_range(1,50);
   vif.haddr   <= tr.haddr;
   vif.htrans  <= 2'b00;
   vif.hrdata  <= tr.hrdata;
   @(posedge vif.hready);
   @(posedge vif.clk);
   $display("[DRV] wrap8 read haddr=%0h hrdata=%0d ",vif.haddr,vif.hrdata);

   repeat(7) begin
      vif.hwdata <= tr.hwdata;//$urandom_range(1,50);
      vif.htrans <= 2'b01;
      @(posedge vif.hready);
      @(posedge vif.clk);
      $display("[DRV] wrap8 read haddr=%0h hwdata=%0d",vif.haddr,vif.hrdata);
   end
    vif.hsel<=1'b0;
   vif.htrans<=2'b00;

   d_flag = 1;
endtask

task incr8_wr();
   @(posedge vif.clk);
   vif.hresetn <= 1'b1;
   vif.hburst  <= 3'b101;
   vif.hsel    <= 1'b1;
   vif.hwrite  <= 1;
   vif.hwdata  <= tr.hwdata;
   vif.hsize   <= 3'b010;
   vif.haddr   <= tr.haddr;
   vif.htrans  <= 2'b00;
   @(posedge vif.hready);
   @(posedge vif.clk);
   $display("[DRV] incr8 write haddr=%0h hwdata=%0d",vif.haddr,vif.hwdata);

   repeat(7) begin
      vif.hwdata <= tr.hwdata;//$urandom_rang(1,50);
      vif.htrans <= 2'b01;
      @(posedge vif.hready);
      @(posedge vif.clk);
      $display("[DRV] incr8 write haddr=%0h hwdata=%0d",vif.haddr,vif.hwdata);
   end
   d_flag = 1;
endtask


task incr8_rd();
   @(posedge vif.clk);
   vif.hresetn <= 1'b1;
   vif.hburst  <= 3'b101;
   vif.hsel    <= 1'b1;
   vif.hwrite  <= 1'b0;
   vif.hsize   <= 3'b010;
   vif.hwdata  <= 0;//$urandom_range(1,50);
   vif.haddr   <= tr.haddr;
   vif.htrans  <= 2'b00;
   vif.hrdata  <= tr.hrdata;
   @(posedge vif.hready);
   @(posedge vif.clk);
   $display("[DRV] incr8 read haddr=%0h hrdata=%0d ",vif.haddr,vif.hrdata);

   repeat(7) begin
      vif.hwdata <= tr.hwdata;//$urandom_range(1,50);
      vif.htrans <= 2'b01;
      @(posedge vif.hready);
      @(posedge vif.clk);
      $display("[DRV] incr8 read haddr=%0h hwdata=%0d",vif.haddr,vif.hrdata);
   end
   d_flag = 1;
endtask


task wrap16_wr();
   @(posedge vif.clk);
   vif.hresetn <= 1'b1;
   vif.hburst  <= 3'b110;
   vif.hsel    <= 1'b1;
   vif.hwrite  <= 1;
   vif.hwdata  <= tr.hwdata;
   vif.hsize   <= 3'b010;
   vif.haddr   <= tr.haddr;
   vif.htrans  <= 2'b00;
   @(posedge vif.hready);
   @(posedge vif.clk);
   $display("[DRV] wrap16 write haddr=%0h hwdata=%0d",vif.haddr,vif.hwdata);

   repeat(15) begin
      vif.hwdata <= $urandom_range(1,50);
      vif.htrans <= 2'b01;
      @(posedge vif.hready);
      @(posedge vif.clk);
      $display("[DRV] wrap16 write haddr=%0h hwdata=%0d",vif.haddr,vif.hwdata);
   end
    vif.hsel<=1'b0;
   vif.htrans<=2'b00;

   d_flag = 1;
endtask


task wrap16_rd();
   @(posedge vif.clk);
   vif.hresetn <= 1'b1;
   vif.hburst  <= 3'b110;
   vif.hsel    <= 1'b1;
   vif.hwrite  <= 1'b0;
   vif.hsize   <= 3'b010;
   vif.hwdata  <= $urandom_range(1,50);
   vif.haddr   <= tr.haddr;
   vif.htrans  <= 2'b00;
   vif.hrdata  <= tr.hrdata;
   @(posedge vif.hready);
   @(posedge vif.clk);
   $display("[DRV] wrap16 read haddr=%0h hrdata=%0d ",vif.haddr,vif.hrdata);

   repeat(15) begin
      vif.hwdata <= $urandom_range(1,50);
      vif.htrans <= 2'b01;
      @(posedge vif.hready);
      @(posedge vif.clk);
      $display("[DRV] wrap16 read haddr=%0h hwdata=%0d",vif.haddr,vif.hrdata);
   end
    vif.hsel<=1'b0;
   vif.htrans<=2'b00;

   d_flag = 1;
endtask

task incr16_wr();
   @(posedge vif.clk);
   vif.hresetn <= 1'b1;
   vif.hburst  <= 3'b111;
   vif.hsel    <= 1'b1;
   vif.hwrite  <= 1;
   vif.hwdata  <= tr.hwdata;
   vif.hsize   <= 3'b010;
   vif.haddr   <= tr.haddr;
   vif.htrans  <= 2'b00;
   @(posedge vif.hready);
   @(posedge vif.clk);
   $display("[DRV] incr16 write haddr=%0h hwdata=%0d",vif.haddr,vif.hwdata);

   repeat(15) begin
      vif.hwdata <= $urandom_range(1,50);
      vif.htrans <= 2'b01;
      @(posedge vif.hready);
      @(posedge vif.clk);
      $display("[DRV] incr16 write haddr=%0h hwdata=%0d",vif.haddr,vif.hwdata);
   end
   d_flag = 1;
endtask


task incr16_rd();
   @(posedge vif.clk);
   vif.hresetn <= 1'b1;
   vif.hburst  <= 3'b111;
   vif.hsel    <= 1'b1;
   vif.hwrite  <= 1'b0;
   vif.hsize   <= 3'b010;
   vif.hwdata  <= $urandom_range(1,50);
   vif.haddr   <= tr.haddr;
   vif.htrans  <= 2'b00;
   vif.hrdata  <= tr.hrdata;
   @(posedge vif.hready);
   @(posedge vif.clk);
   $display("[DRV] incr16 read haddr=%0h hrdata=%0d ",vif.haddr,vif.hrdata);

   repeat(15) begin
      vif.hwdata <= $urandom_range(1,50);
      vif.htrans <= 2'b01;
      @(posedge vif.hready);
      @(posedge vif.clk);
      $display("[DRV] incr16 read haddr=%0h hwdata=%0d",vif.haddr,vif.hrdata);
   end
   d_flag = 1;
endtask

task run();
   forever begin
   mbxgd.get(tr);
   if(tr.hwrite == 1'b1)begin
   case(tr.hburst)
      3'b000:single_tr_wr();
      3'b001:unspec_len_wr();
      3'b010:wrap4_wr();
      3'b011:incr4_wr();
      3'b100:wrap8_wr();
      3'b101:incr8_wr();
      3'b110:wrap16_wr();
      3'b111:incr16_wr();
   endcase
   end
  else begin
     case(tr.hburst)
      3'b000:single_tr_rd();
      3'b001:unspec_len_rd();
      3'b010:wrap4_rd();
      3'b011:incr4_rd();
      3'b100:wrap8_rd();
      3'b101:incr8_rd();
      3'b110:wrap16_rd();
      3'b111:incr16_rd();
   endcase
   end
end
endtask
endclass
