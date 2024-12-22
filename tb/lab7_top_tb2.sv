module lab7_top_tb_2;
  reg [3:0] KEY;
  reg [9:0] SW;
  wire [9:0] LEDR; 
  wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  reg err;

  lab7_top DUT(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);

  initial forever begin
    KEY[0] = 1; #5;
    KEY[0] = 0; #5;
  end

  initial begin
    err = 0;
    KEY[1] = 1'b0; // reset asserted
    // check if program from Figure 8 in Lab 7 handout can be found loaded in memory
    if (DUT.MEM.mem[0] !== 16'b1101000000001000) begin err = 1; $display("FAILED: mem[0] wrong; "); $stop; end
    if (DUT.MEM.mem[1] !== 16'b0110000000000000) begin err = 1; $display("FAILED: mem[1] wrong; "); $stop; end
    if (DUT.MEM.mem[2] !== 16'b0110000001000000) begin err = 1; $display("FAILED: mem[4] wrong; "); $stop; end
    if (DUT.MEM.mem[3] !== 16'b1100000001101010) begin err = 1; $display("FAILED: mem[5] wrong; "); $stop; end
    if (DUT.MEM.mem[4] !== 16'b1101000100001001) begin err = 1; $display("FAILED: mem[6] wrong; "); $stop; end
    if (DUT.MEM.mem[5] !== 16'b0110000100100000) begin err = 1; $display("FAILED: mem[7] wrong; "); $stop; end
    if (DUT.MEM.mem[6] !== 16'b1000000101100000) begin err = 1; $display("FAILED: mem[8] wrong; "); $stop; end
    if (DUT.MEM.mem[7] !== 16'b1110000000000000) begin err = 1; $display("FAILED: mem[9] wrong; "); $stop; end

    SW = 10'b0;
    SW[2] = 1'b1;
    SW[3] = 1'b1;

    #10; // wait until next falling edge of clock
    KEY[1] = 1'b1; // reset de-asserted, PC still undefined if as in Figure 8

    #10; // waiting for RST state to cause reset of PC

    if (DUT.CPU.PC !== 9'b0) begin err = 1; $display("FAILED: PC is not reset to zero."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC); 
    if (DUT.CPU.PC !== 9'h1) begin err = 1; $display("FAILED: PC should be 1."); $stop; end

    // MOV R0, SW_BASE
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  
    if (DUT.CPU.PC !== 9'h2) begin err = 1; $display("FAILED: PC should be 2."); $stop; end
    if (DUT.CPU.DP.REGFILE.R0 !== 16'b1000) begin err = 1; $display("FAILED: R0 should be 1000."); $stop; end 

    // LDR R0, [R0]
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC); 
    if (DUT.CPU.PC !== 9'h3) begin err = 1; $display("FAILED: PC should be 3."); $stop; end
    if (DUT.CPU.DP.REGFILE.R0 !== 16'b101000000) begin err = 1; $display("FAILED: R0 should be 101000000."); $stop; end  

    // LDR R2, [R0]
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);
    if (DUT.CPU.PC !== 9'h4) begin err = 1; $display("FAILED: PC should be 4."); $stop; end
    if (DUT.CPU.DP.REGFILE.R2 !== 16'b1100) begin err = 1; $display("FAILED: R2 should be 1100."); end 

    // MOV R3, R2, LSL #1
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC); 
    if (DUT.CPU.PC !== 9'h5) begin err = 1; $display("FAILED: PC should be 5."); $stop; end
    if (DUT.CPU.DP.REGFILE.R3 !== 16'b11000) begin err = 1; $display("FAILED: R3 should be 11000."); end 

    // MOV R1, LEDR_BASE
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC); 
    if (DUT.CPU.PC !== 9'h6) begin err = 1; $display("FAILED: PC should be 6."); $stop; end
    if (DUT.CPU.DP.REGFILE.R1 !== 16'b1001) begin err = 1; $display("FAILED: R2 should be 1001."); end 

    // LDR R1, [R1]
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC); 
    if (DUT.CPU.PC !== 9'h7) begin err = 1; $display("FAILED: PC should be 7."); $stop; end
    if (DUT.CPU.DP.REGFILE.R1 !== 16'b100000000) begin err = 1; $display("FAILED: R1 should be 100000000."); end 

    // STR R3, [R1] 
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC); 
    if (DUT.CPU.PC !== 9'h8) begin err = 1; $display("FAILED: PC should be 8."); $stop; end
    if (DUT.CPU.DP.REGFILE.R3 !== 16'b11000) begin err = 1; $display("FAILED: R1 should be 11000."); end 


    if (~err) $display("INTERFACE OK");
    $stop;
  end
endmodule
