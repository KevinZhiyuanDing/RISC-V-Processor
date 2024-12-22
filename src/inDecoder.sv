
module inDecoder(in, nsel, opcode, ALUop, sximm5, sximm8, shift, writenum, readnum);
    input [15:0] in;
    input [2:0] nsel;
    output reg [1:0] ALUop, shift;
    output reg [15:0] sximm5, sximm8;
    output reg [2:0] opcode, readnum, writenum;

    // create the internal wires
    wire [2:0] Rn, Rd, Rm;
    wire [4:0] imm5;
    wire [7:0] imm8;

    // decode each component from the input
    assign imm5 = in[4:0];
    assign imm8 = in[7:0];

    assign ALUop = in[12:11];
    assign shift = (opcode == 3'b110 | opcode == 3'b101) ? in[4:3] : 2'b00; //shift is applied only in Move and ALU instructions

    assign Rn = in[10:8];
    assign Rd = in[7:5];
    assign Rm = in[2:0];

    assign op = in[12:11];
    assign opcode = in[15:13];

    // sign extension
    assign sximm5 = {{11{imm5[4]}},imm5};
    assign sximm8 = {{8{imm8[7]}},imm8};

    // choose between Rm Rd Rn based on nsel
    always @(*) begin
        case(nsel) 
            // set to Rm
            3'b001 : begin 
                writenum <= Rm; 
                readnum <= Rm; 
            end
            // set to Rd
            3'b010 : begin 
                writenum <= Rd; 
                readnum <= Rd; 
            end
            // set to Rn
            3'b100 : begin 
                writenum <= Rn; 
                readnum <= Rn; 
            end
            default: begin
                writenum = 3'b000;
                readnum = 3'b000;
            end 

        endcase
    end

endmodule
