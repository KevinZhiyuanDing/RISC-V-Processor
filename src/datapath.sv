module datapath(
    //input [15:0] datapath_in,
    input [2:0] writenum, readnum,
    input [1:0] shift, ALUop,
    input write, loada, loadb, loadc, loads, asel, bsel, clk,
    input [1:0] vsel,
    input [15:0] mdata, sximm8, sximm5,
    input [7:0] PC,
    output reg [15:0] datapath_out, 
    output reg Z_out, V_out, N_out
  );

    // call register function
    reg [15:0] data_in;
    wire [15:0] data_out;
    regfile REGFILE (.data_in(data_in), .writenum(writenum), .write(write), .readnum(readnum), .clk(clk), .data_out(data_out));

    // call ALU
    reg [15:0] Ain, Bin;
    wire [15:0] out;
    wire Z,N,V;
    ALU ALU (.Ain(Ain), .Bin(Bin), .out(out), .Z(Z), .N(N), .V(V), .ALUop(ALUop));

    // call shifter
    reg [15:0] in;
    wire [15:0] sout;
    shifter SHIFT (.in(in), .sout(sout), .shift(shift));

    // other wires and regs
    reg [15:0] A, C;

    // the two MUX before ALU
    assign Ain = asel ? 16'b0 : A;
    assign Bin = bsel ? sximm5 : sout;
    // the MUX at the beginning
    // assign data_in = vsel ? datapath_in : datapath_out;

    always @(*) begin
        // chnages made, added the input mdata, sximm8 and PC
        case(vsel) 
            2'b00 : data_in <= mdata;
            2'b01 : data_in <= sximm8;
            2'b10 : data_in <= {8'b0,PC};
            2'b11 : data_in <= C;
        endcase
    end

    always_ff @(posedge clk) begin
        //datapath_out <= 0;
        // create all the load, only load when load and clk is high
        if (loada) A <= data_out;   

        if (loadb) in <= data_out;

        if (loadc) begin
            C <= out;
            datapath_out <= out;
        end
        // update status
        if (loads) begin
            Z_out <= Z;
            N_out <= N;
            V_out <= V;
        end
    end

endmodule
