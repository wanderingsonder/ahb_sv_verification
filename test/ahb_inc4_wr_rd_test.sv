class ahb_inc4_wr_rd_test extends ahb_generator;
   ahb_transaction tr;

function new(mailbox #(ahb_transaction)mbxgd,mailbox #(bit[4:0])mbxgm);
   super.new(mbxgd,mbxgm);
endfunction

task run();
   tr = new();
  
      assert(tr.randomize with{tr.hwrite==1'b1;tr.hburst==3'b011;tr.haddr==55;tr.hwdata==32'hA5B5_C5D5;});
      $display("--------------------");
      $display("[inc4_wr_rd]=> Data sent to DRV");
      mbxgd.put(tr);
      mbxgm.put(tr.ulen);
      wait(d_flag==1);
      d_flag=0;
      #1;

      assert(tr.randomize with {tr.hwrite==1'b0; tr.hburst==3'b011;tr.haddr==55;});
      $display("--------------------");
      $display("[inc4_wr_rd]=> Data sent to DRV");
      mbxgd.put(tr);
      mbxgm.put(tr.ulen);
      wait(d_flag==1);
      d_flag=0;
      #1;
   ->stop;
   endtask

endclass

