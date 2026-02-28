class ahb_monitor;
   virtual ahb_interface vif;
   ahb_transaction tr;
  
   int len=0;
   bit [4:0] temp;
   mailbox #(ahb_transaction)mbxms;
   mailbox #(bit [4:0]) mbxgm;

   function new(mailbox #(ahb_transaction)mbxms,mailbox #(bit [4:0]) mbxgm,virtual ahb_interface vif);
     this.mbxms = mbxms;
     this.mbxgm = mbxgm;
     this.vif   = vif;
   endfunction

task single_tr_wr();
   @(posedge vif.hready);
   @(posedge vif.clk);
   tr.hwrite  = 1;
   tr.hwdata  = vif.hwdata;
   tr.haddr   = vif.haddr;
   tr.hsize   = vif.hsize;
   tr.htrans  = vif.htrans;
   tr.hburst  = vif.hburst;
   tr.hsel    = vif.hsel;
   mbxms.put(tr);
   $display("[MON] single transaction write haddr=%0d hwdata=%0d",tr.haddr,tr.hwdata);
   @(posedge vif.clk);
endtask

task single_tr_rd();
   @(posedge vif.hready);
   @(posedge vif.clk);
   tr.hwrite  = 1'b0;
   tr.haddr   = vif.haddr;
   tr.hrdata  = vif.hrdata;
   tr.hsize   = vif.hsize;
   tr.htrans  = vif.htrans;
   tr.hwdata  = vif.hwdata;
   tr.hburst  = vif.hburst;
   tr.hsel    = vif.hsel;
   mbxms.put(tr);
   $display("[MON] single transaction read haddr=%0d hrdata=%0d",tr.haddr,tr.hrdata);
   @(posedge vif.clk);
endtask

task unspec_len_wr();
   mbxgm.get(temp);
   repeat(temp)begin
   @(posedge vif.hready);
   @(posedge vif.clk);
   tr.hwrite  = 1'b1;
   tr.haddr   = vif.next_addr;
   tr.hrdata  = vif.hrdata;
   tr.hsize   = vif.hsize;
   tr.htrans  = vif.htrans;
   tr.hwdata  = vif.hwdata;
   tr.hburst  = vif.hburst;
   tr.hsel    = vif.hsel;
   mbxms.put(tr);
   $display("[MON] unspecified length write haddr=%0d hwdata=%0d",tr.haddr,tr.hwdata);
   @(posedge vif.clk);
   end
endtask

task unspec_len_rd();
   mbxgm.get(temp);
   repeat(temp)begin
   @(posedge vif.hready);
   @(posedge vif.clk);
   tr.hwrite  = 1'b0;
   tr.haddr   = vif.next_addr;
   tr.hrdata  = vif.hrdata;
   tr.hsize   = vif.hsize;
   tr.htrans  = vif.htrans;
   tr.hwdata  = vif.hwdata;
   tr.hburst  = vif.hburst;
   tr.hsel    = vif.hsel;
   mbxms.put(tr);
   $display("[MON] unspecified length read haddr=%0d hrdata=%0d",tr.haddr,tr.hrdata);
   @(posedge vif.clk);
   end
endtask

task wrap4_wr();
   mbxgm.get(temp);
   repeat(4)begin
   @(posedge vif.hready);
   @(posedge vif.clk);
   tr.hwrite  = 1'b1;
   tr.haddr   = vif.next_addr;
   tr.hrdata  = vif.hrdata;
   tr.hsize   = vif.hsize;
   tr.htrans  = vif.htrans;
   tr.hwdata  = vif.hwdata;
   tr.hburst  = vif.hburst;
   tr.hsel    = vif.hsel;
   mbxms.put(tr);
   $display("[MON] wrap4 write haddr=%0h hwdata=%0d",tr.haddr,tr.hwdata);
   @(posedge vif.clk);
   end
endtask

task wrap4_rd();
   mbxgm.get(temp);
   repeat(4)begin
   @(posedge vif.hready);
   @(posedge vif.clk);
   tr.hwrite  = 1'b0;
   tr.haddr   = vif.next_addr;
   tr.hrdata  = vif.hrdata;
   tr.hsize   = vif.hsize;
   tr.htrans  = vif.htrans;
   tr.hwdata  = vif.hwdata;
   tr.hburst  = vif.hburst;
   tr.hsel    = vif.hsel;
   mbxms.put(tr);
   $display("[MON] wrap4 read haddr=%0h hrdata=%0d",tr.haddr,tr.hrdata);
   @(posedge vif.clk);
   end
endtask

task incr4_wr();
   mbxgm.get(temp);
   repeat(4)begin
   @(posedge vif.hready);
   @(posedge vif.clk);
   tr.hwrite  = 1'b1;
   tr.haddr   = vif.next_addr;
   tr.hrdata  = vif.hrdata;
   tr.hsize   = vif.hsize;
   tr.htrans  = vif.htrans;
   tr.hwdata  = vif.hwdata;
   tr.hburst  = vif.hburst;
   tr.hsel    = vif.hsel;
   mbxms.put(tr);
   $display("[MON] incr4 write haddr=%0h hwdata=%0d",tr.haddr,tr.hwdata);
   @(posedge vif.clk);
   end
endtask

task incr4_rd();
   mbxgm.get(temp);
   repeat(4)begin
   @(posedge vif.hready);
   @(posedge vif.clk);
   tr.hwrite  = 1'b0;
   tr.haddr   = vif.next_addr;
   tr.hrdata  = vif.hrdata;
   tr.hsize   = vif.hsize;
   tr.htrans  = vif.htrans;
   tr.hwdata  = vif.hwdata;
   tr.hburst  = vif.hburst;
   tr.hsel    = vif.hsel;
   mbxms.put(tr);
   $display("[MON] incr4 read haddr=%0h hrdata=%0d",tr.haddr,tr.hrdata);
   @(posedge vif.clk);
   end
endtask

task wrap8_wr();
   mbxgm.get(temp);
   repeat(8)begin
   @(posedge vif.hready);
   @(posedge vif.clk);
   tr.hwrite  = 1'b1;
   tr.haddr   = vif.next_addr;
   tr.hrdata  = vif.hrdata;
   tr.hsize   = vif.hsize;
   tr.htrans  = vif.htrans;
   tr.hwdata  = vif.hwdata;
   tr.hburst  = vif.hburst;
   tr.hsel    = vif.hsel;
   mbxms.put(tr);
   $display("[MON] wrap8 write haddr=%0h hwdata=%0d",tr.haddr,tr.hwdata);
   @(posedge vif.clk);
   end
endtask

task wrap8_rd();
   mbxgm.get(temp);
   repeat(8)begin
   @(posedge vif.hready);
   @(posedge vif.clk);
   tr.hwrite  = 1'b0;
   tr.haddr   = vif.next_addr;
   tr.hrdata  = vif.hrdata;
   tr.hsize   = vif.hsize;
   tr.htrans  = vif.htrans;
   tr.hwdata  = vif.hwdata;
   tr.hburst  = vif.hburst;
   tr.hsel    = vif.hsel;
   mbxms.put(tr);
   $display("[MON] wrap8 read haddr=%0h hrdata=%0d",tr.haddr,tr.hrdata);
   @(posedge vif.clk);
   end
endtask

task incr8_wr();
   mbxgm.get(temp);
   repeat(8)begin
   @(posedge vif.hready);
   @(posedge vif.clk);
   tr.hwrite  = 1'b1;
   tr.haddr   = vif.next_addr;
   tr.hrdata  = vif.hrdata;
   tr.hsize   = vif.hsize;
   tr.htrans  = vif.htrans;
   tr.hwdata  = vif.hwdata;
   tr.hburst  = vif.hburst;
   tr.hsel    = vif.hsel;
   mbxms.put(tr);
   $display("[MON] incr8 write haddr=%0h hwdata=%0d",tr.haddr,tr.hwdata);
   @(posedge vif.clk);
   end
endtask

task incr8_rd();
   mbxgm.get(temp);
   repeat(8)begin
   @(posedge vif.hready);
   @(posedge vif.clk);
   tr.hwrite  = 1'b0;
   tr.haddr   = vif.next_addr;
   tr.hrdata  = vif.hrdata;
   tr.hsize   = vif.hsize;
   tr.htrans  = vif.htrans;
   tr.hwdata  = vif.hwdata;
   tr.hburst  = vif.hburst;
   tr.hsel    = vif.hsel;
   mbxms.put(tr);
   $display("[MON] incr8 read haddr=%0h hrdata=%0d",tr.haddr,tr.hrdata);
   @(posedge vif.clk);
   end
endtask

task wrap16_wr();
   mbxgm.get(temp);
   repeat(16)begin
   @(posedge vif.hready);
   @(posedge vif.clk);
   tr.hwrite  = 1'b1;
   tr.haddr   = vif.next_addr;
   tr.hrdata  = vif.hrdata;
   tr.hsize   = vif.hsize;
   tr.htrans  = vif.htrans;
   tr.hwdata  = vif.hwdata;
   tr.hburst  = vif.hburst;
   tr.hsel    = vif.hsel;
   mbxms.put(tr);
   $display("[MON] wrap16 write haddr=%0h hwdata=%0d",tr.haddr,tr.hwdata);
   @(posedge vif.clk);
   end
endtask

task wrap16_rd();
   mbxgm.get(temp);
   repeat(16)begin
   @(posedge vif.hready);
   @(posedge vif.clk);
   tr.hwrite  = 1'b0;
   tr.haddr   = vif.next_addr;
   tr.hrdata  = vif.hrdata;
   tr.hsize   = vif.hsize;
   tr.htrans  = vif.htrans;
   tr.hwdata  = vif.hwdata;
   tr.hburst  = vif.hburst;
   tr.hsel    = vif.hsel;
   mbxms.put(tr);
   $display("[MON] wrap16 read haddr=%0h hrdata=%0d",tr.haddr,tr.hrdata);
   @(posedge vif.clk);
   end
endtask

task incr16_wr();
   mbxgm.get(temp);
   repeat(16)begin
   @(posedge vif.hready);
   @(posedge vif.clk);
   tr.hwrite  = 1'b1;
   tr.haddr   = vif.next_addr;
   tr.hrdata  = vif.hrdata;
   tr.hsize   = vif.hsize;
   tr.htrans  = vif.htrans;
   tr.hwdata  = vif.hwdata;
   tr.hburst  = vif.hburst;
   tr.hsel    = vif.hsel;
   mbxms.put(tr);
   $display("[MON] incr16 write haddr=%0h hwdata=%0d",tr.haddr,tr.hwdata);
   @(posedge vif.clk);
   end
endtask

task incr16_rd();
   mbxgm.get(temp);
   repeat(16)begin
   @(posedge vif.hready);
   @(posedge vif.clk);
   tr.hwrite  = 1'b0;
   tr.haddr   = vif.next_addr;
   tr.hrdata  = vif.hrdata;
   tr.hsize   = vif.hsize;
   tr.htrans  = vif.htrans;
   tr.hwdata  = vif.hwdata;
   tr.hburst  = vif.hburst;
   tr.hsel    = vif.hsel;
   mbxms.put(tr);
   $display("[MON] incr16 read haddr=%0h hrdata=%0d",tr.haddr,tr.hrdata);
   @(posedge vif.clk);
   end
endtask

  task run();
   tr = new();
   forever begin
   @(posedge vif.clk);
   if(vif.hresetn && vif.hsel && vif.hwrite) begin
    case(vif.hburst)
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

   if(vif.hresetn && vif.hsel && vif.hwrite==1'b0) begin
   case(vif.hburst)
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
