class ahb_generator;
   ahb_transaction tr;

   mailbox  #(ahb_transaction)mbxgd;
   mailbox #(bit [4:0]) mbxgm;
   event done,drvnext,sconext;
   int count=0;

   function new(mailbox #(ahb_transaction)mbxgd,mailbox #(bit [4:0]) mbxgm);
     this.mbxgd = mbxgd;
     this.mbxgm = mbxgm;
   endfunction

virtual task run();
endtask
endclass
