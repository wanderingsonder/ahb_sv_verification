class ahb_transaction;

   ////////////////////////////////////////////////////////////
   // RANDOMIZED FIELDS
   ////////////////////////////////////////////////////////////

   rand bit [31:0] hwdata;
   rand bit [31:0] haddr;
   rand bit [2:0]  hsize;
   rand bit [2:0]  hburst;
   rand bit        hwrite;

   ////////////////////////////////////////////////////////////
   // NON-RANDOM FIELDS (captured from bus)
   ////////////////////////////////////////////////////////////

   bit [1:0]  htrans;
   bit        hresetn;
   bit        hsel;
   bit [1:0]  hresp;
   bit        hready;
   bit [31:0] hrdata;

   rand bit [4:0] ulen;   // unspecified burst length


   ////////////////////////////////////////////////////////////
   // CONSTRAINTS
   ////////////////////////////////////////////////////////////

   // write / read distribution
   constraint write_c
   {
      soft hwrite dist {1 := 1, 0 := 1};
   }

   // supported transfer sizes
   constraint size_c
   {
      soft hsize inside {3'b000,3'b001,3'b010};
   }

   // valid burst types
   constraint burst_c
   {
      soft hburst inside {[0:7]};
   }

   // safe memory address range (word aligned)
   constraint addr_c
   {
      soft haddr inside {[0:252]};
      haddr % 4 == 0;
   }

   // unspecified burst length
   constraint ulen_c
   {
      soft ulen inside {[3:10]};
   }


   ////////////////////////////////////////////////////////////
   // DISPLAY METHOD (DEBUG)
   ////////////////////////////////////////////////////////////

   function void display(string name="TRANS");

      $display("------------------------------------");
      $display("[%s]",name);
      $display("haddr  = %0h",haddr);
      $display("hwdata = %0h",hwdata);
      $display("hrdata = %0h",hrdata);
      $display("hwrite = %0b",hwrite);
      $display("hsize  = %0b",hsize);
      $display("hburst = %0b",hburst);
      $display("ulen   = %0d",ulen);
      $display("------------------------------------");

   endfunction


endclass
