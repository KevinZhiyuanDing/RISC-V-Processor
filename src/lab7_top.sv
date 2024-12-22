module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
    input [3:0] KEY;
    input [9:0] SW;
    output reg [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    `define NONE 2'b00
    `define MWRITE 2'b01
    `define MREAD 2'b10

    wire clk;
    assign clk = ~KEY[0];

    wire [8:0] mem_addr;

    wire Z, N, V;
    wire [15:0] read_data, write_data;
    wire [1:0] mem_cmd;

    // instantiate CPU module
    cpu CPU( .clk   (~KEY[0]), // recall from Lab 4 that KEY0 is 1 when NOT pushed
            .reset (~KEY[1]), 
            .N     (N),
            .V     (V),
            .Z     (Z),
            .mdata (read_data), 
            .mem_cmd(mem_cmd), 
            .mem_addr(mem_addr),          // read_data
            .read_data(read_data), 
            .write_data(write_data)
            ); // add mdata, mem_cmd, mem_addr,
                                  // remove load, s

    // when mem_addr[8] == 0, msel is high
    wire msel;
    assign msel = (mem_addr[8:8] == 1'b0) ? 1:0;

    // when mem_cmd == `MWRITE and msel is high, write is high
    wire write;
    assign write = (mem_cmd == `MWRITE && msel) ? 1:0;

    // when mem_cmd == `MREAD and msel is high, write is high
    wire enable;
    assign enable = (mem_cmd == `MREAD && msel) ? 1:0;

    wire [15:0] dout;
    wire [15:0] din;
    // 7 implementes tri-state driver to enable value in dout to be driven to read data
    assign read_data = (enable) ? dout : 16'bz;   
    assign din = write_data;

    // instantiates RAM module
    //                         clk,  read_address  write_address, write,  din, dout
    RAM #(16,8,"data.txt") MEM(clk, mem_addr[7:0], mem_addr[7:0], write,  din, dout);



    // switch, implements tri-state driver to enable SW to be be driven to read_data
    assign read_data = (mem_cmd == `MREAD && mem_addr == 9'h140) ? {8'b0,SW[7:0]} : 16'bz; 

    // implement write enabled reg for LED to be driven by write data
    // Update LEDs
    always @(posedge clk) begin
        if ((mem_cmd == `MWRITE) && (mem_addr == 9'h100)) begin
            LEDR[7:0] <= write_data[7:0];
        end
    end

endmodule

// From slide set 11
module RAM(clk,read_address,write_address,write,din,dout);
  parameter data_width = 32; 
  parameter addr_width = 4;
  parameter filename = "data.txt";

  input clk;
  input [addr_width-1:0] read_address, write_address;
  input write;
  input [data_width-1:0] din;
  output [data_width-1:0] dout;
  reg [data_width-1:0] dout;

  reg [data_width-1:0] mem [2**addr_width-1:0];

  initial $readmemb(filename, mem);

  always @ (posedge clk) begin
    if (write)
      mem[write_address] <= din;
    dout <= mem[read_address]; // dout doesn't get din in this clock cycle 
                               // (this is due to Verilog non-blocking assignment "<=")
  end 
endmodule

// instantiate vDFF module
module vDFF(clk,D,Q);
    parameter n=1;
    input clk;
    input [n-1:0] D;
    output [n-1:0] Q;
    reg [n-1:0] Q;
    always @(posedge clk)
        Q <= D;
endmodule

// instantiate sseg module
module sseg(in,segs);
    input [3:0] in;
    output reg [6:0] segs;

    always @(*) begin
        case (in) 
        4'b0000: segs = 7'b1000000;//0
        4'b0001: segs = 7'b1111001;//1
        4'b0010: segs = 7'b0100100;//2
        4'b0011: segs = 7'b0110000;//3
        4'b0100: segs = 7'b0011001;//4
        4'b0101: segs = 7'b0010010;//5
        4'b0110: segs = 7'b0000010;//6
        4'b0111: segs = 7'b1111000;//7
        4'b1000: segs = 7'b0000000;//8
        4'b1001: segs = 7'b0011000;//9
        4'b1010: segs = 7'b0001000;//A
        4'b1011: segs = 7'b0000011;//b
        4'b1100: segs = 7'b1000110;//C
        4'b1101: segs = 7'b0100001;//d
        4'b1110: segs = 7'b0000110;//E
        4'b1111: segs = 7'b0001110;//F
        default: segs <= 7'b1000000;
        endcase
    end

endmodule
