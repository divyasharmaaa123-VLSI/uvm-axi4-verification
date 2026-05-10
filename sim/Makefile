# AXI4-Lite UVM Verification Makefile
# Supports: VCS, Questa, Xcelium

TOPLEVEL    = tb_top
UVM_HOME   ?= $(VCS_HOME)/etc/uvm

# File lists
RTL_FILES   = ../rtl/axi4_slave.sv
TB_FILES    = ../tb/axi4_if.sv \
              ../tb/env/axi4_seq_item.sv \
              ../tb/env/axi4_driver.sv \
              ../tb/env/axi4_monitor.sv \
              ../tb/env/axi4_scoreboard.sv \
              ../tb/env/axi4_agent.sv \
              ../tb/env/axi4_env.sv \
              ../tb/env/axi4_base_test.sv \
              ../tb/tb_top.sv

TEST       ?= axi4_rand_test

# VCS Target
vcs:
	vcs -full64 -sverilog -ntb_opts uvm \
	    +incdir+$(UVM_HOME)/src \
	    $(RTL_FILES) $(TB_FILES) \
	    -o simv
	./simv +UVM_TESTNAME=$(TEST) \
	       +UVM_VERBOSITY=UVM_MEDIUM

# Questa Target
questa:
	vlib work
	vmap work work
	vlog -sv +incdir+$(UVM_HOME)/src \
	     $(RTL_FILES) $(TB_FILES)
	vsim -c $(TOPLEVEL) \
	     +UVM_TESTNAME=$(TEST) \
	     +UVM_VERBOSITY=UVM_MEDIUM \
	     -do "run -all; quit"

# Xcelium Target
xcelium:
	xrun -sv -uvm \
	     $(RTL_FILES) $(TB_FILES) \
	     +UVM_TESTNAME=$(TEST) \
	     +UVM_VERBOSITY=UVM_MEDIUM

clean:
	rm -rf simv* csrc* xcelium.d work transcript *.log

.PHONY: vcs questa xcelium clean
