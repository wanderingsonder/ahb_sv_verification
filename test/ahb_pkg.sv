package ahb_pkg;
event drvnext,sconext,done,stop;
bit d_flag = 0;
bit s_flag = 0;

event stop;
`include "ahb_transaction.sv"
`include "ahb_generator.sv"
`include "ahb_driver.sv"
`include "ahb_monitor.sv"
`include "ahb_coverage.sv"
`include "ahb_scoreboard.sv"
`include "ahb_environment.sv"
`include "ahb_test.sv"


endpackage
