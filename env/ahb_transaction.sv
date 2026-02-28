class ahb_transaction;
   rand bit [31:0] hwdata;
   rand bit [31:0] haddr;
   rand bit [2:0]  hsize;
   rand bit [2:0]  hburst;
   rand bit        hwrite;
        bit [1:0]  htrans;
        bit        hresetn;
        bit        hsel;
        bit [1:0]  hresp;
        bit        hready;
        bit [31:0] hrdata;
   rand bit [4:0]  ulen;

   constraint write_c {soft hwrite dist {1:/1,0:/1};}
   constraint size_c {soft hsize inside{[2:0]};}
   constraint burst_c {soft hburst ==6;}
   constraint addr_c {soft haddr ==6;}
   constraint ulen_c {soft ulen==5;}
    
endclass

