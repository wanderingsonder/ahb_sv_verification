class ahb_coverage;
ahb_transaction tr;

function new();
   ahb_cover=new();
   tr=new();
endfunction

function collect(ahb_transaction tr);
   this.tr=tr;
   ahb_cover.sample();
endfunction

covergroup ahb_cover;

coverpoint tr.hwdata  iff(!tr.hresetn) {bins hwdata1[10]= {[1:50]};}
coverpoint tr.haddr   iff(!tr.hresetn) {bins haddr1={55};}
coverpoint tr.hwrite  iff(!tr.hresetn) {bins hwr_1={1}; bins hwr_0= {0};}
coverpoint tr.hsize   iff(!tr.hresetn) {bins hs_4={3'b10};}
coverpoint tr.hburst  iff(!tr.hresetn) {bins hburst1[]= {[0:7]};}
coverpoint tr.htrans  iff(!tr.hresetn) {bins zero={2'b00}; bins one={2'b01};}
endgroup
endclass
