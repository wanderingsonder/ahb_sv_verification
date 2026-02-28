class ahb_environment;
   ahb_generator gen;
   ahb_driver drv;
   ahb_monitor mon;
   ahb_scoreboard sco;
  
   mailbox #(ahb_transaction)mbxgd = new(1);
   mailbox #(ahb_transaction)mbxms = new();
   mailbox #(bit[4:0])mbxgm = new();
   
 virtual ahb_interface vif;

function new(virtual ahb_interface vif);
   this.vif = vif;
endfunction
 
 task build();
   gen = new(mbxgd,mbxgm);
   drv = new(mbxgd,vif);
   mon = new(mbxms,mbxgm,vif);
   sco = new(mbxms);
endtask

task run();
drv.reset();
   fork
      gen.run();
      drv.run();
      mon.run();
      sco.run();
   join_none;
   wait(stop.triggered);
   #40;
   $display("-------------------------------------");
   $finish;
endtask
endclass
