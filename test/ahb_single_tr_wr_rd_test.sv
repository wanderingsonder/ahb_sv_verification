class ahb_single_tr_wr_rd_test extends ahb_generator;
   ahb_transaction tr;

function new(mailbox #(ahb_transaction)mbxgd,mailbox #(bit[4:0])mbxgm);
   super.new(mbxgd,mbxgm);
endfunction

task run();
   tr = new();
   for(int i=1; i<=2; i++) begin
      if(i==1) tr.randomize with{tr.hwrite==1'b1;tr.hburst==3'b000;tr.haddr==55;tr.hwdata==32'hA5B5_C5D5;};
      else tr.randomize with {tr.hwrite==1'b0; tr.hburst==3'b000;tr.haddr==55;};
      $display("--------------------");
      $display("[single_tr_wr_rd]=> Data sent to DRV");
      mbxgd.put(tr);
      mbxgm.put(tr.ulen);
     // @(sconext);
      wait(s_flag==1);
      s_flag=0;
      #1;
   end
   ->stop;
   endtask
endclass
