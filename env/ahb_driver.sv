class ahb_driver;

   virtual ahb_interface vif;
   mailbox #(ahb_transaction) mbxgd;
   ahb_transaction tr;

   function new(mailbox #(ahb_transaction) mbxgd,
                virtual ahb_interface vif);
      this.mbxgd = mbxgd;
      this.vif   = vif;
   endfunction

   task reset();
      vif.hresetn <= 0;
      vif.haddr   <= 0;
      vif.hwdata  <= 0;
      vif.hsize   <= 0;
      vif.hburst  <= 0;
      vif.hwrite  <= 0;
      vif.hsel    <= 0;
      vif.htrans  <= 2'b00;
      repeat(5) @(posedge vif.clk);
      vif.hresetn <= 1;
      $display("[DRV] RESET DONE");
      $display("--------------------------");
   endtask

   task single_write();
      @(posedge vif.clk);
      vif.hsel   <= 1;
      vif.hwrite <= 1;
      vif.hsize  <= 3'b010;
      vif.hburst <= 3'b000;
      vif.haddr  <= tr.haddr;
      vif.htrans <= 2'b10;

      @(posedge vif.clk);
      vif.hwdata <= tr.hwdata;

      @(posedge vif.clk);
      vif.htrans <= 2'b00;
      vif.hsel   <= 0;

      $display("[DRV] SINGLE WRITE addr=%0h data=%0h",
               tr.haddr, tr.hwdata);

      @(posedge vif.clk);
      d_flag = 1;
   endtask

   task single_read();
      @(posedge vif.clk);
      vif.hsel   <= 1;
      vif.hwrite <= 0;
      vif.hsize  <= 3'b010;
      vif.hburst <= 3'b000;
      vif.haddr  <= tr.haddr;
      vif.htrans <= 2'b10;

      @(posedge vif.clk);
      vif.htrans <= 2'b00;

      @(posedge vif.clk);
      $display("[DRV] SINGLE READ addr=%0h data=%0h",
               tr.haddr, vif.hrdata);
      vif.hsel <= 0;

      @(posedge vif.clk);
      d_flag = 1;
   endtask

   task burst_write(int beats);
      @(posedge vif.clk);
      vif.hsel   <= 1;
      vif.hwrite <= 1;
      vif.hsize  <= 3'b010;
      vif.hburst <= tr.hburst;
      vif.haddr  <= tr.haddr;
      vif.htrans <= 2'b10;

      @(posedge vif.clk);
      vif.hwdata <= tr.hwdata;

      $display("[DRV] BURST WRITE addr=%0h data=%0h",
               vif.haddr, vif.hwdata);

      repeat(beats-1)
      begin
         vif.htrans <= 2'b11;
         vif.haddr  <= vif.haddr + 4;
         vif.hwdata <= $urandom_range(1, 100);

         @(posedge vif.clk);

         $display("[DRV] BURST WRITE addr=%0h data=%0h",
                  vif.haddr, vif.hwdata);
      end

      vif.htrans <= 2'b00;
      vif.hsel   <= 0;

      @(posedge vif.clk);
      d_flag = 1;
   endtask

   task burst_read(int beats);
      @(posedge vif.clk);
      vif.hsel   <= 1;
      vif.hwrite <= 0;
      vif.hsize  <= 3'b010;
      vif.hburst <= tr.hburst;
      vif.haddr  <= tr.haddr;
      vif.htrans <= 2'b10;

      @(posedge vif.clk);
      $display("[DRV] BURST READ addr=%0h data=%0h",
               vif.haddr, vif.hrdata);

      repeat(beats-1)
      begin
         vif.htrans <= 2'b11;
         vif.haddr  <= vif.haddr + 4;

         @(posedge vif.clk);

         $display("[DRV] BURST READ addr=%0h data=%0h",
                  vif.haddr, vif.hrdata);
      end

      vif.htrans <= 2'b00;
      vif.hsel   <= 0;

      @(posedge vif.clk);
      d_flag = 1;
   endtask

   task run();
      forever
      begin
         mbxgd.get(tr);

         if(tr.hwrite)
         begin
            case(tr.hburst)
               3'b000: single_write();
               3'b001: burst_write(tr.ulen);
               3'b010: burst_write(4);
               3'b011: burst_write(4);
               3'b100: burst_write(8);
               3'b101: burst_write(8);
               3'b110: burst_write(16);
               3'b111: burst_write(16);
            endcase
         end
         else
         begin
            case(tr.hburst)
               3'b000: single_read();
               3'b001: burst_read(tr.ulen);
               3'b010: burst_read(4);
               3'b011: burst_read(4);
               3'b100: burst_read(8);
               3'b101: burst_read(8);
               3'b110: burst_read(16);
               3'b111: burst_read(16);
            endcase
         end
      end
   endtask

endclass
