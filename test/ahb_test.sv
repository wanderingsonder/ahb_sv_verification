`include "ahb_single_tr_wr_rd_test.sv"
`include "ahb_unspec_len_wr_rd_test.sv"
`include "ahb_wrap4_wr_rd_test.sv"
`include "ahb_inc4_wr_rd_test.sv"
`include "ahb_wrap8_wr_rd_test.sv"
`include "ahb_inc8_wr_rd_test.sv"
`include "ahb_wrap16_wr_rd_test.sv"
`include "ahb_inc16_wr_rd_test.sv"

class ahb_test;

   virtual ahb_interface vif;
   ahb_environment env;

   ahb_single_tr_wr_rd_test  single_tr_wr_rd;
   ahb_unspec_len_wr_rd_test unspec_len_wr_rd;
   ahb_wrap4_wr_rd_test      wrap4_wr_rd;
   ahb_inc4_wr_rd_test       incr4_wr_rd;
   ahb_wrap8_wr_rd_test      wrap8_wr_rd;
   ahb_inc8_wr_rd_test       incr8_wr_rd;
   ahb_wrap16_wr_rd_test     wrap16_wr_rd;
   ahb_inc16_wr_rd_test      incr16_wr_rd;

   function new(virtual ahb_interface vif);
      this.vif = vif;
   endfunction

   task build_and_run();

      env = new(vif);
      env.build();

      if ($test$plusargs("ahb_single_tr_wr_rd_test"))
      begin
         $display("Running TEST: ahb_single_tr_wr_rd_test");
         single_tr_wr_rd = new(env.mbxgd, env.mbxgm);
         env.gen = single_tr_wr_rd;
         env.run();
      end

      if ($test$plusargs("ahb_unspec_len_wr_rd_test"))
      begin
         $display("Running TEST: ahb_unspec_len_wr_rd_test");
         unspec_len_wr_rd = new(env.mbxgd, env.mbxgm);
         env.gen = unspec_len_wr_rd;
         env.run();
      end

      if ($test$plusargs("ahb_wrap4_wr_rd_test"))
      begin
         $display("Running TEST: ahb_wrap4_wr_rd_test");
         wrap4_wr_rd = new(env.mbxgd, env.mbxgm);
         env.gen = wrap4_wr_rd;
         env.run();
      end

      if ($test$plusargs("ahb_inc4_wr_rd_test"))
      begin
         $display("Running TEST: ahb_inc4_wr_rd_test");
         incr4_wr_rd = new(env.mbxgd, env.mbxgm);
         env.gen = incr4_wr_rd;
         env.run();
      end

      if ($test$plusargs("ahb_wrap8_wr_rd_test"))
      begin
         $display("Running TEST: ahb_wrap8_wr_rd_test");
         wrap8_wr_rd = new(env.mbxgd, env.mbxgm);
         env.gen = wrap8_wr_rd;
         env.run();
      end

      if ($test$plusargs("ahb_inc8_wr_rd_test"))
      begin
         $display("Running TEST: ahb_inc8_wr_rd_test");
         incr8_wr_rd = new(env.mbxgd, env.mbxgm);
         env.gen = incr8_wr_rd;
         env.run();
      end

      if ($test$plusargs("ahb_wrap16_wr_rd_test"))
      begin
         $display("Running TEST: ahb_wrap16_wr_rd_test");
         wrap16_wr_rd = new(env.mbxgd, env.mbxgm);
         env.gen = wrap16_wr_rd;
         env.run();
      end

      if ($test$plusargs("ahb_inc16_wr_rd_test"))
      begin
         $display("Running TEST: ahb_inc16_wr_rd_test");
         incr16_wr_rd = new(env.mbxgd, env.mbxgm);
         env.gen = incr16_wr_rd;
         env.run();
      end

   endtask

endclass
