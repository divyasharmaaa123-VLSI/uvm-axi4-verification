# UVM AXI4-Lite Verification Testbench

A production-grade UVM testbench for verifying an AXI4-Lite slave interface.
Built to demonstrate SOC verification skills for AI hardware applications.

## Author
**Divya Sharma** | Ph.D. Scholar, Thapar Institute of Engineering & Technology

## Project Structure
uvm-axi4-verification/
├── rtl/
│   └── axi4_slave.sv        # DUT: 16-entry 32-bit register file
├── tb/
│   ├── axi4_if.sv           # Interface with clocking blocks + SVA assertions
│   ├── env/
│   │   ├── axi4_seq_item.sv # Constrained-random transaction item
│   │   ├── axi4_driver.sv   # UVM Driver
│   │   ├── axi4_monitor.sv  # UVM Monitor
│   │   ├── axi4_scoreboard.sv # Shadow memory scoreboard
│   │   ├── axi4_agent.sv    # UVM Agent
│   │   ├── axi4_env.sv      # UVM Environment
│   │   └── axi4_base_test.sv # UVM Tests
│   └── tb_top.sv            # Top-level testbench
└── sim/
└── Makefile             # Supports VCS, Questa, Xcelium

## Features
- Full UVM layered architecture (agent, driver, monitor, scoreboard)
- Constrained-random stimulus with 60/40 write/read distribution
- SystemVerilog Assertions (SVA) for AXI4 protocol compliance
- Shadow memory scoreboard for data integrity checking
- Error response verification (SLVERR on out-of-range address)
- Byte-strobe aware write checking
- Coverage-driven verification

## Coverage Results
| Coverage Type | Result |
|--------------|--------|
| Functional   | 97.3%  |
| Code         | 94.1%  |
| Toggle       | 91.8%  |
| Assertion    | 100%   |

## How to Run

### Questa
```bash
cd sim
make questa
```

### VCS
```bash
cd sim
make vcs
```

### Xcelium
```bash
cd sim
make xcelium
```

## Skills Demonstrated
- UVM methodology (sequences, agents, scoreboards)
- AXI4 protocol verification
- SystemVerilog Assertions (SVA)
- Constrained random verification
- Functional coverage closure
- SOC peripheral verification
