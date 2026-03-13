class ahb_monitor;

   virtual ahb_interface vif;
   mailbox #(ahb_transaction) mbxms;
   mailbox #(bit [4:0]) mbxgm;
   ahb_transaction tr;
   bit [4:0] burst_len;

   function new(mailbox #(ahb_transaction) mbxms,
                mailbox #(bit [4:0]) mbxgm,
                virtual ahb_interface vif);
      this.mbxms = mbxms;
      this.mbxgm = mbxgm;
      this.vif   = vif;
   endfunction

   task single_write();
      tr        = new();
      tr.haddr  = vif.haddr;
      @(posedge vif.clk);
      tr.hwdata = vif.hwdata;
      tr.hwrite = 1;
      mbxms.put(tr);
      $display("[MON] SINGLE WRITE addr=%0h data=%0h",
               tr.haddr, tr.hwdata);
   endtask

   task single_read();
      tr        = new();
      tr.haddr  = vif.haddr;
      tr.hwrite = 0;
      @(posedge vif.clk);
      tr.hrdata = vif.hrdata;
      mbxms.put(tr);
      $display("[MON] SINGLE READ addr=%0h data=%0h",
               tr.haddr, tr.hrdata);
   endtask

   task burst_write(int beats);
      tr        = new();
      tr.haddr  = vif.haddr;
      tr.hwdata = vif.hwdata;
      tr.hwrite = 1;
      mbxms.put(tr);
      $display("[MON] BURST WRITE addr=%0h data=%0h",
               tr.haddr, tr.hwdata);

      repeat(beats-1)
      begin
         tr = new();
         @(posedge vif.clk);
         tr.haddr  = vif.haddr;
         tr.hwdata = vif.hwdata;
         tr.hwrite = 1;
         mbxms.put(tr);
         $display("[MON] BURST WRITE addr=%0h data=%0h",
                  tr.haddr, tr.hwdata);
      end
   endtask

   task burst_read(int beats);
      tr        = new();
      tr.haddr  = vif.haddr;
      tr.hwrite = 0;
      @(posedge vif.clk);
      tr.hrdata = vif.hrdata;
      mbxms.put(tr);
      $display("[MON] BURST READ addr=%0h data=%0h",
               tr.haddr, tr.hrdata);

      repeat(beats-1)
      begin
         tr        = new();
         tr.haddr  = vif.haddr;
         tr.hwrite = 0;
         @(posedge vif.clk);
         tr.hrdata = vif.hrdata;
         mbxms.put(tr);
         $display("[MON] BURST READ addr=%0h data=%0h",
                  tr.haddr, tr.hrdata);
      end
   endtask

   task run();
      forever
      begin
         @(posedge vif.clk);

         if(vif.hresetn && vif.hsel &&
            (vif.htrans inside {2'b10, 2'b11}))
         begin
            case(vif.hburst)
               3'b000:
                  if(vif.hwrite) single_write();
                  else           single_read();

               3'b001:
               begin
                  mbxgm.get(burst_len);
                  if(vif.hwrite) burst_write(burst_len);
                  else           burst_read(burst_len);
               end

               3'b010:
                  if(vif.hwrite) burst_write(4);
                  else           burst_read(4);

               3'b011:
                  if(vif.hwrite) burst_write(4);
                  else           burst_read(4);

               3'b100:
                  if(vif.hwrite) burst_write(8);
                  else           burst_read(8);

               3'b101:
                  if(vif.hwrite) burst_write(8);
                  else           burst_read(8);

               3'b110:
                  if(vif.hwrite) burst_write(16);
                  else           burst_read(16);

               3'b111:
                  if(vif.hwrite) burst_write(16);
                  else           burst_read(16);
            endcase
         end
      end
   endtask

endclass
