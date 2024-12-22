module regfile(data_in,writenum,write,readnum,clk,data_out);
    input [15:0] data_in;
    input [2:0] writenum, readnum;
    input write, clk;
    output reg [15:0] data_out;

    // Define eight 16-bit registers explicitly
    reg [15:0] R0, R1, R2, R3, R4, R5, R6, R7;

    // decoder for writenum and readnum
    wire [7:0] tmpWrite;
    assign tmpWrite = (write) ? (1 << writenum) : 8'b0; // Choose which register to write into
    
    // update register on rising edge of clock
    always @(posedge clk) begin
        if (tmpWrite[0]) R0 <= data_in;
        else R0 <= R0;
        if (tmpWrite[1]) R1 <= data_in;
        else R1 <= R1;
        if (tmpWrite[2]) R2 <= data_in;
        else R2 <= R2;
        if (tmpWrite[3]) R3 <= data_in;
        else R3 <= R3;
        if (tmpWrite[4]) R4 <= data_in;
        else R4 <= R4;
        if (tmpWrite[5]) R5 <= data_in;
        else R5 <= R5;
        if (tmpWrite[6]) R6 <= data_in;
        else R6 <= R6;
        if (tmpWrite[7]) R7 <= data_in;
        else R7 <= R7;
    end

    // Decoders: 
    always @(*) begin
        // decoder for readnum
        case(readnum)
            3'b000: data_out = R0;
            3'b001: data_out = R1;
            3'b010: data_out = R2;
            3'b011: data_out = R3;
            3'b100: data_out = R4;
            3'b101: data_out = R5;
            3'b110: data_out = R6;
            3'b111: data_out = R7;
            default: data_out = 16'b0;
        endcase

        // // decoder for writenum
        // if (write) begin
        //     case (writenum)
        //         3'b000: tmpWrite = 8'b00000001;
        //         3'b001: tmpWrite = 8'b00000010;
        //         3'b010: tmpWrite = 8'b00000100;
        //         3'b011: tmpWrite = 8'b00001000;
        //         3'b100: tmpWrite = 8'b00010000;
        //         3'b101: tmpWrite = 8'b00100000;
        //         3'b110: tmpWrite = 8'b01000000;
        //         3'b111: tmpWrite = 8'b10000000;
        //     endcase
        // end
        // else tmpWrite = 8'b0;

    end


endmodule