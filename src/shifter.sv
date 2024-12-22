module shifter(in,shift,sout);
    input [15:0] in;
    input [1:0] shift;
    output reg [15:0] sout;
    always @(*) begin
        // shift the output based on the shift
        case (shift) 
            2'b00: sout <= in; // do nothing
            2'b01: sout <= in << 1'b1; // multiply by 2
            2'b10: sout <= in >> 1'b1; // divide by 2
            2'b11: sout <= $signed(in) >>> 1'b1; // divide by 2 (works for both signs)
        endcase
    end
endmodule