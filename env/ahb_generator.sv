class ahb_generator;

   mailbox #(ahb_transaction) mbxgd;
   mailbox #(bit [4:0]) mbxgm;
   ahb_transaction tr;
   int count = 1;

   function new(mailbox #(ahb_transaction) mbxgd,
                mailbox #(bit [4:0]) mbxgm);
      this.mbxgd = mbxgd;
      this.mbxgm = mbxgm;
   endfunction

   virtual task run();
      repeat(count)
      begin
         tr = new();
         if(!tr.randomize())
            $fatal("Randomization failed");
         mbxgd.put(tr);
         if(tr.hburst == 3'b001)
            mbxgm.put(tr.ulen);
      end
   endtask

endclass
