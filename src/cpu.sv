module cpu(clk,reset,N,V,Z, mdata, mem_cmd, mem_addr, read_data, write_data);
    input clk, reset;
    input [15:0] read_data, mdata;
    output [15:0] write_data;
    output Z, V, N;
    output [8:0] mem_addr;
    output [1:0] mem_cmd;

    /// for instruction decoder: 
    // input 
    reg [15:0] instruction; 
    wire [2:0] nsel;
    // output
    wire [1:0] ALUop, shift;
    wire [2:0] opcode, readnum, writenum;
    wire [15:0] sximm5, sximm8;

    // for FSM:
    wire write;
    wire [1:0] vsel;
    wire loada, loadb, loadc, loads, asel, bsel; 
    reg [7:0] PC;
    wire [15:0] mdata;


    // 3
    wire load_pc, reset_pc, load_addr, addr_sel, load_ir;
    
    //// Instruction Decoder
    inDecoder dec(.in(instruction), .nsel(nsel), .opcode(opcode), 
              .ALUop(ALUop), .sximm5(sximm5), .sximm8(sximm8), 
              .shift(shift), .readnum(readnum), .writenum(writenum));
              
    //// Controller
    stateMachine sm(.clk(clk), .s(s), .reset(reset), .opcode(opcode), .ALUop(ALUop), .shift(shift),
                    .nsel(nsel), .vsel(vsel), .write(write), 
                    .loada(loada), .loadb(loadb), .loadc(loadc), .loads(loads), .asel(asel), .bsel(bsel), 
                    .load_addr(load_addr), .load_ir(load_ir), .load_pc(load_pc),.addr_sel(addr_sel), .mem_cmd(mem_cmd), .reset_pc(reset_pc));

    //// Datapath
    datapath DP(.ALUop(ALUop), .sximm5(sximm5), .sximm8(sximm8),  
                .shift(shift), .readnum(readnum), .writenum(writenum), 
                .mdata(mdata), .clk(clk), .PC(PC), 
                .write(write), .loada(loada), .loadb(loadb), .loadc(loadc), .loads(loads), .asel(asel), .bsel(bsel), .vsel(vsel),
                .datapath_out(write_data), .Z_out(Z), .V_out(V), .N_out(N));

    // 3
    reg [8:0] next_pc;

    assign next_pc = (reset_pc) ? 9'b0 : (PC + 1'b1);
    
    // assigning mem_addr
    reg [8:0] address;
    assign mem_addr = (addr_sel) ? PC : address;
    
    always_ff @(posedge clk) begin
        if (load_pc) PC <= next_pc;

        if (load_addr) address <= write_data[8:0];

        if (load_ir) instruction <= read_data; 
    end

endmodule
