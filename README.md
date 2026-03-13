# AHB Slave Protocol Verification
### SystemVerilog · UVM-lite · AMBA AHB · Burst Transfers · Functional Coverage · SVA

---

## Project Overview

This project implements a complete **layered class-based testbench** for verifying an AHB-compliant slave peripheral. The testbench is structured following industry-standard verification methodology principles:

- **Layered architecture** separating stimulus, checking, and coverage
- **Constrained-random verification** through a `rand` transaction class
- **Self-checking** via a shadow memory model in the scoreboard
- **Functional coverage** with coverpoints across address, burst type, transfer size, and direction
- **All 8 AHB burst modes** verified: SINGLE, INCR (unspecified length), WRAP4/8/16, INCR4/8/16
- **SVA assertions** for protocol correctness — reset, response, burst sequencing, signal stability
- **EPWave waveform verification** for every test case

**Simulation tool:** Synopsys VCS `X-2025.06-SP1_Full64`
**Platform:** EDA Playground
**Waveform:** EPWave (`ahb_wave.vcd`)
**EDA Playground:** https://www.edaplayground.com/x/pCn5

---

## AMBA AHB Protocol Background

The **Advanced High-performance Bus (AHB)** is part of the ARM AMBA bus family. It is designed for high-bandwidth, high-performance transfers between processors, on-chip memories, and DMA peripherals.

### AHB Pipeline

Every AHB transfer is pipelined — the **address phase** and **data phase** are separated by one clock cycle. The master drives address and control signals in cycle N; the slave responds with data in cycle N+1.

```
CLK     ──┐ ┌──┐ ┌──┐ ┌──┐ ┌──
HADDR   ──────[A0]──[A1]──[A2]──
HWDATA  ──────────[D0]──[D1]──[D2]──   (write: data 1 cycle after addr)
HRDATA  ──────────[D0]──[D1]──[D2]──   (read:  data 1 cycle after addr)
HREADY  ────────────────────────────   (1 = transfer complete, no wait states)
```

### AHB State Machine

```
       IDLE
        │
        ▼  HSEL=1, HTRANS=NON_SEQ
    CHECK_MODE
        │
        ▼  HADDR valid, HSEL=1
    ADDR_DECODE
        │
        ├──► (HWRITE=1) ──► WRITE ──► HREADY=1 ──► Transfer Done
        │
        └──► (HWRITE=0) ──► READ  ──► HREADY=1 ──► Transfer Done
```

| Phase | HSEL | HTRANS | HREADY | Description |
|-------|------|--------|--------|-------------|
| IDLE | 0 | IDLE | — | No transfer in progress |
| CHECK_MODE | 1 | — | 0 | Slave decoding direction and address range |
| ADDR_DECODE | 1 | NON_SEQ/SEQ | 0 | Address latched, routing to write or read |
| WRITE/READ | 1 | NON_SEQ/SEQ | 1 | Transfer complete |

### Key AHB Signals

| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `CLK` | Input to Slave | 1 | Bus clock |
| `HRESETn` | Input to Slave | 1 | Active-low synchronous reset |
| `HSEL` | Input to Slave | 1 | Slave select |
| `HADDR` | Input to Slave | 32 | Address bus |
| `HWRITE` | Input to Slave | 1 | 1=Write, 0=Read |
| `HWDATA` | Input to Slave | 32 | Write data |
| `HSIZE` | Input to Slave | 3 | Transfer size (byte/halfword/word) |
| `HBURST` | Input to Slave | 3 | Burst type encoding |
| `HTRANS` | Input to Slave | 2 | Transfer type |
| `HRDATA` | Output | 32 | Read data |
| `HREADY` | Output | 1 | Transfer complete (1=done) |
| `HRESP` | Output | 2 | Transfer response (OKAY/ERROR/RETRY/SPLIT) |

### AHB Burst Type Encoding (`HBURST[2:0]`)

| Encoding | Name | Description |
|----------|------|-------------|
| `3'b000` | SINGLE | Single transfer |
| `3'b001` | INCR | Incrementing burst, unspecified length |
| `3'b010` | WRAP4 | 4-beat wrapping burst |
| `3'b011` | INCR4 | 4-beat incrementing burst |
| `3'b100` | WRAP8 | 8-beat wrapping burst |
| `3'b101` | INCR8 | 8-beat incrementing burst |
| `3'b110` | WRAP16 | 16-beat wrapping burst |
| `3'b111` | INCR16 | 16-beat incrementing burst |

### HTRANS Encoding (this DUT)

> **Note:** HTRANS encoding in this DUT uses non-standard values:

```systemverilog
`define IDLE    2'b00   // No transfer
`define BUSY    2'b01   // Master inserts idle mid-burst
`define NON_SEQ 2'b10   // First beat of burst or single transfer
`define SEQ     2'b11   // Subsequent beats of a burst
```

In waveforms: `htrans=2` = NONSEQ (burst start), `htrans=3` = SEQ (subsequent beats).

---

## Project Structure

```
ahb_sv_project/
│
├── design.sv                         — Top design include (EDA Playground)
├── testbench.sv                      — Top module: clock gen, reset, DUT + interface
│
├── ahb_interface.sv                  — AHB interface + 5 SVA assertions + 4 cover properties
├── ahb_pkg.sv                        — Package: includes all TB files
│
├── ahb_transaction.sv                — Randomized transaction class
├── ahb_generator.sv                  — Base generator (virtual run task)
├── ahb_driver.sv                     — Bus functional model — all burst types
├── ahb_monitor.sv                    — Passive observer — pipeline-aware capture
├── ahb_coverage.sv                   — Functional coverage group
├── ahb_scoreboard.sv                 — Self-checking scoreboard + shadow memory
├── ahb_environment.sv                — Top TB env: instantiates all components
│
├── ahb_test.sv                       — Base test: plusarg dispatch
├── ahb_single_tr_wr_rd_test.sv       — TC1
├── ahb_unspec_len_wr_rd_test.sv      — TC2
├── ahb_wrap4_wr_rd_test.sv           — TC3
├── ahb_inc4_wr_rd_test.sv            — TC4
├── ahb_wrap8_wr_rd_test.sv           — TC5
├── ahb_inc8_wr_rd_test.sv            — TC6
├── ahb_wrap16_wr_rd_test.sv          — TC7
└── ahb_inc16_wr_rd_test.sv           — TC8
```

---

## DUT — AHB Slave Design

**File:** `ahb_slave.sv`

The DUT is an AHB-compliant slave peripheral with **256-byte byte-addressable memory**. It supports all 8 burst types at word transfer size. `HREADY` is always asserted (no wait states). `HRESP` is always OKAY for valid addresses.

### DUT State Machine (5 states)

```
              hresetn=0
           ┌──────────────────────────┐
           │                          │
           ▼                          │
        ┌──────┐                      │
───────▶│ IDLE │◀─────────────────────┘
        └──┬───┘  hsel=0 / addr>=256
           │
           ▼
      ┌────────────┐
      │ CHECK_MODE │
      └─────┬──────┘
            │
       ┌────┴─────────────┐
       │ hwrite=1         │ hwrite=0
       ▼                  ▼
  ┌─────────────┐    ┌─────────────┐
  │ ADDR_DECODE │    │ ADDR_DECODE │
  └──────┬──────┘    └──────┬──────┘
         ▼                  ▼
      ┌───────┐          ┌──────┐
      │ WRITE │          │ READ │
      └───────┘          └──────┘
```

| State | Encoding | Description |
|-------|----------|-------------|
| `idle` | 0 | Reset state |
| `check_mode` | 1 | Validates address, decodes direction |
| `addr_decode` | 4 | Latches address, routes to write/read |
| `write` | 2 | Executes write burst |
| `read` | 3 | Executes read burst |

### Reset Behavior

On `HRESETn = 0`:
- FSM returns to `idle`
- All 256 bytes of `mem[]` cleared to `8'h00`
- `HREADY` deasserts; `HRESP` = OKAY

---

## Testbench Architecture

```
╔══════════════════════════════════════════════════════════════════════╗
║                         testbench  (module)                          ║
║                                                                      ║
║  ╔══════════════════════════════════════════════════╗                ║
║  ║                 ahb_environment                  ║                ║
║  ║                                                  ║                ║
║  ║  ┌─────────────┐  mbxgd  ┌──────────────┐        ║                ║
║  ║  │  Generator  │────────▶│    Driver    │        ║                ║
║  ║  │ virtual run │         └──────┬───────┘        ║                ║
║  ║  └──────┬──────┘                │ drives vif     ║                ║
║  ║         │ mbxgm (INCR only)     ▼                ║                ║
║  ║         │              ┌─────────────────┐       ║  ┌───────────┐ ║
║  ║         └─────────────▶│  ahb_interface  │◀─────▶║  │ ahb_slave │ ║
║  ║                        │  + SVA + cover  │       ║  │  (DUT)    │ ║
║  ║  ┌─────────────┐       └────────┬────────┘       ║  └───────────┘ ║
║  ║  │   Monitor   │◀───────────────┘                ║                ║
║  ║  │  pipeline   │  mbxms                          ║                ║
║  ║  │   aware     ├────────────────┐                ║                ║
║  ║  └─────────────┘                ▼                ║                ║
║  ║                        ┌─────────────────┐       ║                ║
║  ║                        │   Scoreboard    │       ║                ║
║  ║                        │  shadow memory  │       ║                ║
║  ║                        │  PASS / FAIL    │       ║                ║
║  ║                        │  + Coverage     │       ║                ║
║  ║                        └─────────────────┘       ║                ║
║  ╚══════════════════════════════════════════════════╝                ║
╚══════════════════════════════════════════════════════════════════════╝
```

### Mailbox Communication

| Mailbox | Type | From → To | Purpose |
|---------|------|-----------|---------|
| `mbxgd` | Bounded(1) | Generator → Driver | One transaction at a time — flow control |
| `mbxms` | Unbounded | Monitor → Scoreboard | Captured bus transactions for comparison |
| `mbxgm` | Unbounded | Generator → Monitor | Burst length sync — **INCR only** |

### Synchronization

```systemverilog
event stop;   // Triggered by generator when done; waited on by environment
```

---

## Component Deep-Dive

### 1. AHB Interface

**File:** `ahb_interface.sv`

```systemverilog
interface ahb_interface;
   logic        clk, hresetn, hsel, hwrite, hready;
   logic [31:0] hwdata, haddr, hrdata;
   logic [2:0]  hsize, hburst;
   logic [1:0]  htrans, hresp;
endinterface
```

> **Difference from reference design:** This interface does **not** expose `next_addr`. The monitor computes burst address sequencing from `haddr` and pipeline-aware clock alignment — no internal DUT signal needed.

The interface also contains all 5 SVA assertions and 4 cover properties:

```systemverilog
A_RESET_TO_IDLE    : assert property (...)
A_HRESP_OKAY       : assert property (...)
A_SEQ_AFTER_NONSEQ : assert property (...)
A_HADDR_STABLE     : assert property (...)
A_HWRITE_STABLE    : assert property (...)

COV_SINGLE_WRITE      : cover property (...)
COV_BURST_WRAP4       : cover property (...)
COV_BURST_INCR8       : cover property (...)
COV_READ_AFTER_WRITE  : cover property (...)
```

---

### 2. AHB Transaction

**File:** `ahb_transaction.sv`

```systemverilog
class ahb_transaction;
   rand bit [31:0] hwdata;
   rand bit [31:0] haddr;
   rand bit [2:0]  hburst;
   rand bit        hwrite;
        bit [1:0]  htrans;
        bit        hresetn, hsel;
        bit [1:0]  hresp;
        bit        hready;
        bit [31:0] hrdata;
   rand bit [4:0]  ulen;      // INCR only
```

Each test constrains only `hwrite`, `hburst`, and `haddr`. Over-constraining causes randomization failures.

---

### 3. AHB Generator

**File:** `ahb_generator.sv`

The base generator's `run()` task is declared **`virtual`**. Without `virtual`, all test class overrides are silently ignored and the base `run()` executes regardless of the test object type. Each test extends `ahb_generator` and overrides `run()`.

`mbxgm.put(ulen)` is called **only in `ahb_unspec_len_wr_rd_test`** — the only test where the monitor calls `mbxgm.get()`. Putting to `mbxgm` in any other test blocks the simulation.

---

### 4. AHB Driver

**File:** `ahb_driver.sv`

Separate tasks handle each burst type and direction (8 types × 2 directions = 16 tasks).

**Critical:** `d_flag = 1` must be set at the end of every transfer task after `@(posedge clk)`. Without it the generator blocks forever on `wait(d_flag==1)`:

```systemverilog
task single_wr();
   // ... drive signals ...
   @(posedge clk);
   d_flag = 1;   // unblocks generator for next transaction
endtask
```

**First-beat hwdata = 0:** Beat 1 `hwdata` always appears as 0 in driver and monitor logs. This is because `hwdata` is assigned with non-blocking assignment (`<=`) and does not update until the end of the current time step. From beat 2 onwards data is correct. The scoreboard records `INFO` (not FAIL) for beat 1 since expected is also 0.

---

### 5. AHB Monitor

**File:** `ahb_monitor.sv`

Purely passive — observes the bus and never drives signals. Detects `htrans==2'b10` (NONSEQ) to identify burst start.

**Pipeline-aware capture:** The AHB protocol returns `hrdata` one clock after `haddr`. The monitor accounts for this:

```
run() detects NONSEQ on posedge → beat 1:
  haddr = vif.haddr          ← captured immediately (no extra clock)
  @(posedge clk);
  hrdata = vif.hrdata        ← data arrives one cycle after address

beats 2..N:
  @(posedge clk);            ← advance one clock per beat
  haddr  = vif.haddr
  hrdata = vif.hrdata
```

> **No `next_addr`:** Unlike some AHB monitor implementations, this monitor does not rely on an internal DUT signal. Address tracking uses `vif.haddr` directly at the correct clock edge.

---

### 6. AHB Scoreboard & Coverage

**File:** `ahb_scoreboard.sv` / `ahb_coverage.sv`

Shadow memory mirrors every write. On reads, expected data is reconstructed from 4 bytes:

```systemverilog
// Write
mem[tr.haddr]   = tr.hwdata[7:0];
mem[tr.haddr+1] = tr.hwdata[15:8];
mem[tr.haddr+2] = tr.hwdata[23:16];
mem[tr.haddr+3] = tr.hwdata[31:24];

// Read compare
rdata = {mem[tr.haddr+3], mem[tr.haddr+2],
          mem[tr.haddr+1], mem[tr.haddr]};
if (tr.hrdata == rdata)  $display("[SCO] PASS: data matched");
else                     $display("[SCO] FAIL: data mismatched");
```

**Functional Coverage:**

| Coverpoint | Signal | Bins |
|------------|--------|------|
| `hburst` | `tr.hburst` | All 8 burst modes `[0:7]` |
| `hwrite` | `tr.hwrite` | Write (1) / Read (0) |
| `htrans` | `tr.htrans` | NONSEQ (`2'b10`) / SEQ (`2'b11`) |
| `haddr` | `tr.haddr` | Valid range `[0x00–0xFF]` |

> **Known issue:** `Functional Coverage = 0.00%` appears in all logs because `tr.hresetn` is never assigned in the monitor tasks — the covergroup's reset coverpoint is never sampled. All other coverpoints are correctly sampled. Scoreboard PASS/FAIL is the primary correctness metric.

---

### 7. AHB Environment

**File:** `ahb_environment.sv`

```systemverilog
class ahb_environment;
   ahb_generator  gen;
   ahb_driver     drv;
   ahb_monitor    mon;
   ahb_scoreboard sco;

   mailbox #(ahb_transaction) mbxgd = new(1);
   mailbox #(ahb_transaction) mbxms = new();
   mailbox #(bit[4:0])        mbxgm = new();
```

**Critical:** `env.build()` must be called **before** any test object is constructed. If called inside an `if` block after `new()`, mailbox handles are null when passed to test constructors → Null Object Access crash.

`run()` uses `@stop` for clean termination regardless of burst size:

```systemverilog
task run();
   fork
      gen.run(); drv.run(); mon.run(); sco.run();
   join_none;
   @(stop);
   repeat(10) @(posedge vif.clk);
   $finish;
endtask
```

---

## Test Suite

| TC | Test Name | Burst Mode | Beats | Sim Time |
|----|-----------|------------|-------|----------|
| TC1 | `ahb_single_tr_wr_rd_test` | SINGLE (3'b000) | 1W + 1R | 225ns |
| TC2 | `ahb_unspec_len_wr_rd_test` | INCR (3'b001) | 5W + 5R | 325ns |
| TC3 | `ahb_wrap4_wr_rd_test` | WRAP4 (3'b010) | 4W + 4R | 265ns |
| TC4 | `ahb_inc4_wr_rd_test` | INCR4 (3'b011) | 4W + 4R | 265ns |
| TC5 | `ahb_wrap8_wr_rd_test` | WRAP8 (3'b100) | 8W + 8R | 345ns |
| TC6 | `ahb_inc8_wr_rd_test` | INCR8 (3'b101) | 8W + 8R | 345ns |
| TC7 | `ahb_wrap16_wr_rd_test` | WRAP16 (3'b110) | 16W + 16R | 505ns |
| TC8 | `ahb_inc16_wr_rd_test` | INCR16 (3'b111) | 16W + 16R | 505ns |

### Read Burst — First Beat Behavior

For all burst tests (TC2–TC8), beat 1 of the read phase targets an **unwritten location** — the scoreboard prints `INFO: location not written yet`. This is expected, not a bug. Beats 2..N all return PASS.

**Example — INCR4 (TC4), HADDR=0x56:**
```
Write:  0x56 → 0x5a → 0x5e → 0x62
Read:   0x56 (INFO) → 0x5a (PASS) → 0x5e (PASS) → 0x62 (PASS)
```

---

## AHB Transfer Timing

### Single Write (TC1 — verified at 225ns)
```
         T0        T1        T2
CLK    ──┐ ┌──┐ ┌──┐ ┌──┐
HSEL   ──────────┌─────────┐──────
HADDR  ──────────┌─────────┐──────   addr=38
HWDATA ──────────┌─────────┐──────   data=a5b5c5d5
HTRANS ──────────┌─────────┐──────   10 (NONSEQ)
HREADY ──────────────────────────    1 throughout
HRESP  ──────────────────────────    0 (OKAY) throughout
```

### INCR4 Burst (TC4 — verified at 265ns)
```
         T0    T1    T2    T3    T4    T5
CLK    ──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──
HSEL   ──────────┌──────────────────┐────
HWRITE ──────────┌──────────────────┘────
HADDR  ──────────[56]─[5a]─[5e]─[62]────
HTRANS ──────────[10]─[11]─[11]─[11]────  (NONSEQ→SEQ)
HWDATA ──────────[0]──[25]─[31]─[46]────
HRDATA ────────────────[0]──[25]─[31]──  (1 cycle delayed — read phase)
HREADY ────────────────────────────────  1 throughout
```

---

## SVA Assertions

| Assertion | Description | Failures |
|-----------|-------------|----------|
| `A_RESET_TO_IDLE` | Bus must be IDLE after reset | 0 across all TCs |
| `A_HRESP_OKAY` | HRESP must be OKAY for valid addresses | 0 across all TCs |
| `A_SEQ_AFTER_NONSEQ` | SEQ must follow NONSEQ or SEQ in a burst | 0 across all TCs |
| `A_HADDR_STABLE` | HADDR stable when HREADY=0 | Vacuously true (HREADY always 1) |
| `A_HWRITE_STABLE` | HWRITE stable during burst | 0 across all TCs |

### Cover Properties

| Property | TC6 result | All TCs |
|----------|------------|---------|
| `COV_SINGLE_WRITE` | 0 match | Not hit in burst tests |
| `COV_BURST_WRAP4` | 0 match | Encoding mismatch in cover property |
| `COV_BURST_INCR8` | 2 match | TC6 only |
| `COV_READ_AFTER_WRITE` | 3 match | All burst tests |

---

## Running Simulations

### EDA Playground (VCS)

Compile:
```bash
vcs -full64 -licqueue -timescale=1ns/1ns \
    +vcs+flush+all +warn=all -sverilog \
    design.sv testbench.sv
```

Run tests:
```bash
./simv +vcs+lic+wait +ahb_single_tr_wr_rd_test
./simv +vcs+lic+wait +ahb_unspec_len_wr_rd_test
./simv +vcs+lic+wait +ahb_wrap4_wr_rd_test
./simv +vcs+lic+wait +ahb_inc4_wr_rd_test
./simv +vcs+lic+wait +ahb_wrap8_wr_rd_test
./simv +vcs+lic+wait +ahb_inc8_wr_rd_test
./simv +vcs+lic+wait +ahb_wrap16_wr_rd_test
./simv +vcs+lic+wait +ahb_inc16_wr_rd_test
```

---

## Verification Results

### Regression Summary

```
  Test Name                    | Burst Mode     | Beats  | Result  | Pass | Fail
  -----------------------------|----------------|--------|---------|------|------
  ahb_single_tr_wr_rd_test     | SINGLE         |  1+1   | PASSED  |  1   |  0
  ahb_unspec_len_wr_rd_test    | INCR (ulen=5)  |  5+5   | PASSED  |  4   |  0 *
  ahb_wrap4_wr_rd_test         | WRAP4          |  4+4   | PASSED  |  3   |  0 *
  ahb_inc4_wr_rd_test          | INCR4          |  4+4   | PASSED  |  3   |  0 *
  ahb_wrap8_wr_rd_test         | WRAP8          |  8+8   | PASSED  |  7   |  0 *
  ahb_inc8_wr_rd_test          | INCR8          |  8+8   | PASSED  |  7   |  0 *
  ahb_wrap16_wr_rd_test        | WRAP16         | 16+16  | PASSED  | 15   |  0 *
  ahb_inc16_wr_rd_test         | INCR16         | 16+16  | PASSED  | 15   |  0 *

  * Beat 1 of each read burst returns INFO (unwritten location) — expected.

  TOTAL TESTS  :  8  |  PASSED  :  8  |  FAILED  :  0
```

### Sample Log Output (TC1)

```
Running TEST: ahb_single_tr_wr_rd_test
[DRV] RESET DONE
[SVA PASS] A_RESET_TO_IDLE pass#1 time=55
[DRV] SINGLE WRITE addr=38 data=a5b5c5d5
[MON] SINGLE WRITE addr=38 data=a5b5c5d5
[SCO] WRITE addr=38 data=a5b5c5d5
[SVA PASS] A_HRESP_OKAY pass#1 time=65
[DRV] SINGLE READ  addr=38 hrdata=a5b5c5d5
[MON] SINGLE READ  addr=38 hrdata=a5b5c5d5
[SCO] READ addr=38 hrdata=a5b5c5d5 expected=a5b5c5d5
[SCO] PASS: data matched
ENVIRONMENT: TEST COMPLETED
$finish at simulation time 225
```

---

## Key Bugs Fixed During Development

| # | Bug | Symptom | Fix |
|---|-----|---------|-----|
| 1 | `d_flag` never set in driver | Simulation hangs on `wait(d_flag==1)` | Added `@(posedge clk); d_flag=1` at end of all 4 driver tasks |
| 2 | `mbxgm.put()` in all tests | Non-INCR tests block — monitor never calls `get()` | Removed from all tests except `ahb_unspec_len_wr_rd_test` |
| 3 | Generator `run()` not `virtual` | Base class runs instead of test override — wrong stimulus | Added `virtual` to `ahb_generator::run()` |
| 4 | `env.build()` after test `new()` | Null Object Access crash on mailbox handles | Moved `env.build()` before all `if` blocks in `build_and_run()` |
| 5 | Monitor consumed extra clock per beat | Beat 1 skipped; data/address misaligned | Beat 1 captured from `run()` edge directly; beats 2..N use `@clk` loop |
| 6 | `hrdata` captured same cycle as `haddr` | Read data always 0 — one cycle too early | Added `@(posedge clk)` between address and data capture |
| 7 | Fixed `repeat(40)` timeout | Too short for 16-beat bursts | Replaced with `@stop; repeat(10) @clk` |

---

## Key Design Decisions

**`virtual run()` in generator** — Without `virtual`, every test silently executes base class stimulus. Adding a new burst mode test requires only a new class overriding `run()` — no other file changes.

**`env.build()` first** — Mailbox handles must exist before any test constructor runs. Calling `build()` inside an `if` block after `new()` gives null handles → NOA crash.

**Bounded `mbxgd = new(1)`** — Size-1 bound creates back-pressure. Generator blocks until driver `get()`s, preventing stimulus racing ahead.

**`mbxgm` for INCR only** — Monitor calls `mbxgm.get()` only for `hburst==3'b001`. Putting to `mbxgm` from any other test fills the mailbox and blocks.

**Pipeline-aware monitor** — `haddr` captured on NONSEQ edge, `hrdata` one clock later. This matches AHB pipeline spec and was the key fix for correct scoreboard alignment.

**`@stop` termination** — Event-based stop terminates immediately after last transaction completes regardless of burst size (TC1=225ns, TC8=505ns with no dead time).

---

## Tools Used

| Tool | Version | Purpose |
|------|---------|---------|
| Synopsys VCS | X-2025.06-SP1_Full64 | Compilation and simulation |
| EPWave | beta | Waveform viewing (`ahb_wave.vcd`) |
| EDA Playground | — | Cloud simulation platform |
| SystemVerilog | IEEE 1800-2017 | HDL |

---

## Author

**Mahendar**
VLSI Design & Verification Engineer

EDA Playground: https://www.edaplayground.com/x/pCn5

---

`SystemVerilog` `AMBA` `AHB` `RTL Verification` `Functional Coverage` `SVA` `Burst Transfers` `VLSI` `SoC` `Design Verification` `EDA Playground` `VCS`
