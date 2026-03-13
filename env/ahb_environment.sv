class ahb_environment;

   ahb_generator  gen;
   ahb_driver     drv;
   ahb_monitor    mon;
   ahb_scoreboard sco;

   mailbox #(ahb_transaction) mbxgd;
   mailbox #(ahb_transaction) mbxms;
   mailbox #(bit [4:0]) mbxgm;

   virtual ahb_interface vif;

   function new(virtual ahb_interface vif);
      this.vif = vif;
   endfunction

   function void build();
      mbxgd = new();
      mbxms = new();
      mbxgm = new();
      gen   = new(mbxgd, mbxgm);
      drv   = new(mbxgd, vif);
      mon   = new(mbxms, mbxgm, vif);
      sco   = new(mbxms);
   endfunction

   task run();
      fork
         drv.reset();
      join

      fork
         gen.run();
         drv.run();
         mon.run();
         sco.run();
      join_none

      @stop;
      repeat(10) @(posedge vif.clk);

      $display("--------------------------------------");
      $display("ENVIRONMENT: TEST COMPLETED");
      $display("--------------------------------------");

      $finish;
   endtask

endclass
