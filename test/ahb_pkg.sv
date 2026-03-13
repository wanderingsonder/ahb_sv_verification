package ahb_pkg;

   // Global sync flags and events
   event stop;
   bit   d_flag = 0;
   bit   s_flag = 0;

   // ENV includes (relative paths - EDA compatible)
   `include "ahb_transaction.sv"
   `include "ahb_generator.sv"
   `include "ahb_driver.sv"
   `include "ahb_monitor.sv"
   `include "ahb_coverage.sv"
   `include "ahb_scoreboard.sv"
   `include "ahb_environment.sv"

   // TEST include
   `include "ahb_test.sv"

endpackage
