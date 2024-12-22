module ALU(Ain,Bin,ALUop,out,Z,N,V);
  input [15:0] Ain, Bin;
  input [1:0] ALUop;
  output reg [15:0] out;
  output reg Z,N,V;

  always @(*) begin
    Z = 1'b0;
    N = 1'b0;
    V = 1'b0;
    // different operations based on ALUop
    case(ALUop)
      2'b00: begin // Addition
        out = Ain + Bin;
        // controls the output of V
        V = (~Ain[15] & ~Bin[15] & out[15]) | (Ain[15] & Bin[15] & ~out[15]);
      end
      2'b01: begin // Subtraction
        out = Ain - Bin;
        // controls the output of V
        V = (~Ain[15] & Bin[15] & out[15]) | (Ain[15] & ~Bin[15] & ~out[15]);
      end
      2'b10: out = Bin & Ain;
      2'b11: out = ~Bin;
      default: out = out;
    endcase

    // control the output of Z
    if (out == 16'b0) Z = 1'b1;
    else Z = 1'b0;
    // if most significant bit is one, number is negative
    if (out[15] == 1'b1) N = 1'b1;
    else N = 1'b0;
    
  end

endmodule
