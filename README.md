# Asynchronous FIFO Design in Verilog

## Overview

This project implements a **parameterized Asynchronous FIFO (First-In, First-Out)** in Verilog for reliable data transfer between two independent clock domains. Unlike a synchronous FIFO, where both read and write operations share a common clock, an asynchronous FIFO operates with separate write (`wr_clk`) and read (`rd_clk`) clocks, making it suitable for Clock Domain Crossing (CDC) applications.

The design safely transfers data between asynchronous clock domains using **Gray-coded pointers** and **two-stage flip-flop synchronizers**, minimizing the probability of metastability while ensuring correct generation of the **Full** and **Empty** status flags.

---

# Key Features

* Parameterized FIFO depth and data width
* Independent read and write clock domains
* Gray-code pointer generation for safe clock domain crossing
* Two-stage synchronizers for metastability mitigation
* Modular RTL implementation
* Full and Empty flag generation
* Directed Verilog testbench covering major functional scenarios

---

# Design Architecture

The design consists of the following modules:

### `asynchfifo_top.v`

Top-level module that instantiates all FIFO submodules and connects the memory, pointer logic, and synchronizers.

### `memory.v`

Implements the dual-port memory used by the FIFO.

**Write Operation**

* Performed synchronously with the write clock (`wr_clk`)
* Data is written only when:

  * `wr_en = 1`
  * FIFO is not full (`!full`)

**Read Operation**

* Read operation is performed using the read pointer.
* Data is made available on the read side according to the implemented memory behavior.

---

### `wrptr_full.v`

Responsible for:

* Maintaining the binary write pointer
* Generating the Gray-coded write pointer
* Detecting the Full condition
* Incrementing the pointer after successful writes

An additional MSB is used to distinguish between pointer wrap-around conditions.

---

### `rdptr_empty.v`

Responsible for:

* Maintaining the binary read pointer
* Generating the Gray-coded read pointer
* Detecting the Empty condition
* Incrementing the pointer after successful reads

---

### `synchronizer.v`

Implements a two-stage flip-flop synchronizer for safely transferring Gray-coded pointers across clock domains.

Two synchronizers are used:

* Read pointer synchronized into the write clock domain
* Write pointer synchronized into the read clock domain

Using Gray code ensures that only one bit changes between consecutive pointer values, reducing the possibility of incorrect synchronization.

---

# Pointer Generation

The FIFO internally maintains binary pointers for memory addressing.

Before crossing clock domains, the pointers are converted into Gray code using

```
gray = binary ^ (binary >> 1)
```

Since only one bit changes between successive Gray-code values, synchronization errors caused by multi-bit transitions are significantly reduced.

---

# Full and Empty Detection

## Empty Condition

The FIFO is considered **Empty** when the synchronized write pointer equals the current read pointer.

When Empty is asserted:

* Read operations are blocked
* No invalid data is returned

---

## Full Condition

The FIFO is considered **Full** when the write pointer catches up with the read pointer after one complete wrap-around.

This is detected by comparing the Gray-coded pointers while inverting the two most significant bits of the synchronized read pointer.

When Full is asserted:

* Additional write operations are prevented
* Existing data remains protected from being overwritten

---

# Verification

The design was verified using a **directed Verilog testbench** with independent clock frequencies:

* Write Clock (`wr_clk`) : **100 MHz** (10 ns period)
* Read Clock (`rd_clk`) : **71.4 MHz** (14 ns period)

The testbench uses reusable tasks for reset, write, and read operations and continuously monitors the FIFO status.

The following scenarios were verified.

## Test 1 – Basic Write and Read

Three data values were written into the FIFO and subsequently read back.

**Observed Results**

* Data was read in the same order it was written (FIFO behavior)
* Full flag remained deasserted
* Empty flag asserted after the final read

---

## Test 2 – FIFO Full Condition

The FIFO was continuously written until its storage capacity was reached.

**Observed Results**

* Full flag asserted after the FIFO became completely occupied
* Additional write requests were ignored while Full remained asserted
* Existing data was preserved

---

## Test 3 – FIFO Empty Condition

All stored data was read from the FIFO.

**Observed Results**

* Empty flag asserted after the final data word was read
* Further read requests were blocked
* No invalid memory accesses occurred

---

## Test 4 – Simultaneous Read and Write

Read and write operations were performed concurrently while using different clock frequencies.

**Observed Results**

* FIFO correctly handled concurrent operations
* Data ordering was preserved
* Full and Empty flags updated correctly as occupancy changed

---

# Simulation Results

The simulation confirms that the FIFO correctly:

* Transfers data between asynchronous clock domains
* Maintains FIFO ordering
* Prevents overflow using the Full flag
* Prevents underflow using the Empty flag
* Operates correctly under simultaneous read/write conditions

Simulation waveforms demonstrating each test case are included in this repository.

---

# Conclusion

A synthesizable, parameterized asynchronous FIFO was successfully implemented in Verilog using Gray-coded pointers and two-stage synchronizers.

The design correctly transfers data between independent clock domains while maintaining reliable Full and Empty status detection. Directed simulation verified normal operation, overflow protection, underflow protection, and concurrent read/write functionality.

Although the current verification environment uses a directed testbench, future enhancements can include a self-checking testbench, SystemVerilog Assertions (SVA), constrained-random verification, functional coverage, and a UVM-based verification environment.
