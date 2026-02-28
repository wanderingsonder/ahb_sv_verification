package ahb_pkg;
event drvnext,sconext,done,stop;
bit d_flag = 0;
bit s_flag = 0;

event stop;
`include "/home/dvft0901/ahb_sv_project/env/ahb_transaction.sv"
`include "/home/dvft0901/ahb_sv_project/env/ahb_generator.sv"
`include "/home/dvft0901/ahb_sv_project/env/ahb_driver.sv"
`include "/home/dvft0901/ahb_sv_project/env/ahb_monitor.sv"
`include "/home/dvft0901/ahb_sv_project/env/ahb_coverage.sv"
`include "/home/dvft0901/ahb_sv_project/env/ahb_scoreboard.sv"
`include "/home/dvft0901/ahb_sv_project/env/ahb_environment.sv"
`include "/home/dvft0901/ahb_sv_project/test/ahb_test.sv"


endpackage
