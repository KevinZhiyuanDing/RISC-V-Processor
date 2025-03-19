# RISC-Machine
Reduced Instruction Set Computer Processor Implemented in SystemVerilog

## Instruction Set

### Direct Call
- **Syntax:** `BL <label>`
- **Encoding:** `opcode: 010111`, `op: 1`, `Rn: 111`, `8b: im8`
- **Operation:** `R[7]=PC+1; PC=PC+1+sx(im8)`

### Return
- **Syntax:** `BX Rd`
- **Encoding:** `opcode: 010000`, `op: 0`, `unused: 00000`, `Rd: Rd`
- **Operation:** `PC=R[Rd]`

### Indirect Call
- **Syntax:** `BLX Rd`
- **Encoding:** `opcode: 010111`, `op: 1`, `Rn: 111`, `Rd: Rd`
- **Operation:** `R[7]=PC+1; PC=R[Rd]`

### Branch
- **Syntax:** `B <label>`
- **Encoding:** `opcode: 010000`, `op: 0`, `cond: 000`, `8b: im8`
- **Operation:** `PC = PC+1+sx(im8)`

### Memory Instructions
- **Syntax:** `LDR Rd, [Rn{,#<im5>}]`
- **Encoding:** `opcode: 011000`, `op: 0`, `3b: Rn`, `5b: im5`
- **Operation:** `R[Rd]=M[R[Rn]+sx(im5)]`

- **Syntax:** `STR Rd, [Rn{,#<im5>}]`
- **Encoding:** `opcode: 100000`, `op: 0`, `3b: Rn`, `5b: im5`
- **Operation:** `M[R[Rn]+sx(im5)]=R[Rd]`

### Special Instructions
- **Syntax:** `HALT`
- **Encoding:** `opcode: 111000`, `not used: 0000000000`
- **Operation:** `go to halt state`

### Move Instructions
- **Syntax:** `MOV Rn,#<im8>`
- **Encoding:** `opcode: 111000`, `op: 0`, `3b: Rn`, `8b: im8`
- **Operation:** `R[Rn] = sx(im8)`

### ALU Instructions
- **Syntax:** `ADD Rd, Rn, Rm{,<sh_op>}`
- **Encoding:** `opcode: 101000`, `ALUOp: 0`, `3b: Rn`, `3b: Rd`, `2b: sh`, `3b: Rm`
- **Operation:** `R[Rd]=R[Rn]+sh_Rm`

