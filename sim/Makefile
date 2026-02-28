RTL=../rtl/ahb_slave.sv
INF=../env/ahb_interface.sv
PKG=../test/ahb_pkg.sv
TOP=../top/ahb_top.sv
INC= +incdir+../test/ +incdir+../env/ +incdir+../top/

COM=vcs -full64 -sverilog -kdb -debug_access+all ${RTL} ${INF} ${PKG} ${TOP} ${INC}
compile:
	${COM}
COVER=-cm line+cond+fsm+tgl+branch+assert
RUN=vcs -R -full64 -sverilog ${COVER} -kdb -debug_access+all +ntb_random_seed_automatic ${RTL} ${INF} ${PKG} ${TOP} ${INC}
run:
	${RUN}

tc1:
	$(RUN) -cm_dir $(TEST1)_coverage.vdb +$(TEST1) -l $(TEST1).log; urg -dir $(TEST1)_coverage.vdb -report $(TEST1)_report
tc2:
	$(RUN) -cm_dir $(TEST2)_coverage.vdb +$(TEST2) -l $(TEST2).log; urg -dir $(TEST2)_coverage.vdb -report $(TEST2)_report
tc3:
	$(RUN) -cm_dir $(TEST3)_coverage.vdb +$(TEST3) -l $(TEST3).log; urg -dir $(TEST3)_coverage.vdb -report $(TEST3)_report
tc4:
	$(RUN) -cm_dir $(TEST4)_coverage.vdb +$(TEST4) -l $(TEST4).log; urg -dir $(TEST4)_coverage.vdb -report $(TEST4)_report
tc5:
	$(RUN) -cm_dir $(TEST5)_coverage.vdb +$(TEST5) -l $(TEST5).log; urg -dir $(TEST5)_coverage.vdb -report $(TEST5)_report
tc6:
	$(RUN) -cm_dir $(TEST6)_coverage.vdb +$(TEST6) -l $(TEST6).log; urg -dir $(TEST6)_coverage.vdb -report $(TEST6)_report
tc7:
	$(RUN) -cm_dir $(TEST7)_coverage.vdb +$(TEST7) -l $(TEST7).log; urg -dir $(TEST7)_coverage.vdb -report $(TEST7)_report
tc8:
	$(RUN) -cm_dir $(TEST8)_coverage.vdb +$(TEST8) -l $(TEST8).log; urg -dir $(TEST8)_coverage.vdb -report $(TEST8)_report

TEST1=ahb_single_tr_wr_rd_test
TEST2=ahb_unspec_len_wr_rd_test
TEST3=ahb_wrap4_wr_rd_test
TEST4=ahb_wrap8_wr_rd_test
TEST5=ahb_wrap16_wr_rd_test
TEST6=ahb_inc4_wr_rd_test
TEST7=ahb_inc8_wr_rd_test
TEST8=ahb_inc16_wr_rd_test



tc:tc1 tc2 tc3 tc4 tc5 tc6 tc7 tc8

clean:
	rm -rf csrc sim.daidir ucli.key simv *.vpd *.vcd *.log *.dump *.vdb *_report *_test nova* v*

merge:
	urg -dir $(TEST1)_coverage.vdb $(TEST2)_coverage.vdb $(TEST3)_coverage.vdb $(TEST4)_coverage.vdb $(TEST5)_coverage.vdb $(TEST6)_coverage.vdb $(TEST7)_coverage.vdb $(TEST8)_coverage.vdb -format both -report merged_report 

report:
	firefox merged_report/dashboard.html&

regression: tc merge report

final: merge report

