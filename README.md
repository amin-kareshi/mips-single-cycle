# Single-Cycle MIPS Processor

A Verilog implementation of a 32-bit single-cycle MIPS processor based on the classic MIPS architecture.

The project demonstrates the complete datapath and control logic required to execute a subset of MIPS instructions in a single clock cycle.

---

## Features

- 32-bit Single-Cycle MIPS CPU
- ALU implementation
- Register File
- Instruction Memory
- Data Memory
- Main Control Unit
- ALU Control Unit
- Branch and Jump support
- Verilog Testbench
- Tiny Python assembler for generating machine code

---

## Supported Instructions

### R-Type

- ADD
- SUB
- AND
- OR
- SLT

### I-Type

- LW
- SW
- BEQ

### J-Type

- J

---

## Project Structure

```
.
├── mips_single_cycle.v     # Main CPU implementation
├── tb_mips.v               # Testbench
├── assemble.py             # Tiny MIPS assembler
└── README.md
```

---

## Running the Project

### 1. Compile

Using Icarus Verilog:

```bash
iverilog -o cpu tb_mips.v mips_single_cycle.v
```

### 2. Run simulation

```bash
vvp cpu
```

If waveform dumping is enabled:

```bash
gtkwave wave.vcd
```

---

## Running the Assembler

Generate machine code with:

```bash
python assemble.py
```

The script prints hexadecimal instructions that can be loaded into the instruction memory.

---

## Example Program

The included example demonstrates:

- Arithmetic operations
- Logical operations
- Store Word (SW)
- Load Word (LW)
- Branch Equal (BEQ)
- Jump (J)

---

## Technologies

- Verilog HDL
- Python
- Icarus Verilog
- GTKWave
