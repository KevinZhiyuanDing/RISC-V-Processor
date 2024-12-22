module lab7_top_tb;
  reg [3:0] KEY;
  reg [9:0] SW;
  wire [9:0] LEDR; 
  wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  reg err;

  lab7_top DUT(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);

  initial forever begin
    KEY[0] = 0; #5;
    KEY[0] = 1; #5;
  end

  initial begin
    err = 0;
    KEY[1] = 1'b0; // reset asserted

    // @00 1101000000000101 // MOV R0, 5
    // @01 1101000100000010 // MOV R1, 2
    // @02 1010001000100000 // ADD R2, R1, R2 -> 7
    // @03 0110001101000000 // LDR R3, R2 -> [R3] = M[R2] = M[7] = 1000010111000000
    // @04 0110000000100000 // LDR R1, R0 -> [R1] = M[R0] = M[5] = 0110000000100000
    // @05 1100000010001010 // MOV R4, R2 {shift 01} -> R4 = 7*2 
    // @06 1011000110100010 // AND R5, R1, R2 -> 010 & 111 -> 010
    // @07 1000010111000000 // STR R6, R5  M[R6] = R5
    // @08 1110000000000000 // HALT
    // @09 1010101111001101

    // Verify that the program from `data.txt` is loaded correctly
    if (DUT.MEM.mem[0] !== 16'b1101000000000101) begin err = 1; $display("FAILED: mem[0] wrong."); $stop; end
    if (DUT.MEM.mem[1] !== 16'b1101000100000010) begin err = 1; $display("FAILED: mem[1] wrong."); $stop; end
    if (DUT.MEM.mem[2] !== 16'b1010000101000000) begin err = 1; $display("FAILED: mem[2] wrong."); $stop; end
    if (DUT.MEM.mem[3] !== 16'b0110001001100000) begin err = 1; $display("FAILED: mem[3] wrong."); $stop; end
    if (DUT.MEM.mem[4] !== 16'b0110000000100000) begin err = 1; $display("FAILED: mem[4] wrong."); $stop; end
    if (DUT.MEM.mem[5] !== 16'b1100000010001010) begin err = 1; $display("FAILED: mem[5] wrong."); $stop; end
    if (DUT.MEM.mem[6] !== 16'b1011000110100010) begin err = 1; $display("FAILED: mem[6] wrong."); $stop; end
    if (DUT.MEM.mem[7] !== 16'b1000010110100000) begin err = 1; $display("FAILED: mem[7] wrong."); $stop; end
    if (DUT.MEM.mem[8] !== 16'b1110000000000000) begin err = 1; $display("FAILED: mem[8] wrong."); $stop; end
    if (DUT.MEM.mem[9] !== 16'b1010101111001101) begin err = 1; $display("FAILED: mem[9] wrong."); $stop; end

    @(negedge KEY[0]);
    KEY[1] = 1'b1;
    #10; 

    if (DUT.CPU.PC !== 9'b0) begin err = 1; $display("FAILED: PC is not reset to zero."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  
    if (DUT.CPU.PC !== 9'h1) begin err = 1; $display("FAILED: PC should be 1."); $stop; end

    // MOV R0 5
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);
    if (DUT.CPU.PC !== 9'h2) begin err = 1; $display("FAILED: PC should be 2."); $stop; end
    if (DUT.CPU.DP.REGFILE.R0 !== 16'h5) begin err = 1; $display("FAILED: R0 should be 5."); $stop; end 

    // MOV R1, 2
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC); 
    if (DUT.CPU.PC !== 9'h3) begin err = 1; $display("FAILED: PC should be 3."); $stop; end
    if (DUT.CPU.DP.REGFILE.R1 !== 16'h2) begin err = 1; $display("FAILED: R1 should be 2."); $stop; end
    
    
    // ADD R2, R1, R0 -> 7
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);
    if (DUT.CPU.PC !== 9'h4) begin err = 1; $display("FAILED: PC should be 4."); $stop; end
    if (DUT.CPU.DP.REGFILE.R2 !== 16'h7) begin err = 1; $display("FAILED: R2 should be 7."); $stop; end


    // LDR R3, R2 -> [R3] = M[R2] = M[7] = 1000010110100000
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);
    if (DUT.CPU.PC !== 9'h5) begin err = 1; $display("FAILED: PC should be 5."); $stop; end
    if (DUT.CPU.DP.REGFILE.R3 !== 16'b1000010110100000) begin err = 1; $display("FAILED: R3 should be memory at M[7] 1000010111000000."); $stop; end
    

    // @04 0110000000100000 // LDR R1, R0 -> [R1] = M[R0] = M[5] = 0110000000100000
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);
    if (DUT.CPU.PC !== 9'h6) begin err = 1; $display("FAILED: PC should be 6."); $stop; end
    if (DUT.CPU.DP.REGFILE.R1 !== 16'b1100000010001010) begin err = 1; $display("FAILED: R1 should be memory at M[5] 1100000010001010."); $stop; end
    

    // MOV R4, R2 {shift 01} -> R4 = 7*2 
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);
    if (DUT.CPU.PC !== 9'h7) begin err = 1; $display("FAILED: PC should be 7. actual: %d", DUT.CPU.PC); $stop; end
    if (DUT.CPU.DP.REGFILE.R4 !== 16'd14) begin err = 1; $display("FAILED: R4 should be 14."); $stop; end
    

    // AND R5, R1, R2 -> 010 & 111 -> 010
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);
    if (DUT.CPU.PC !== 9'h8) begin err = 1; $display("FAILED: PC should be 8."); $stop; end
    if (DUT.CPU.DP.REGFILE.R5 !== 16'd2) begin err = 1; $display("FAILED: R5 should be 2."); $stop; end
    

    // STR R5, R5  -> M[R5] = R5 -> M[2] = 2
    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);
    if (DUT.CPU.PC !== 9'h9) begin err = 1; $display("FAILED: PC should be 9."); $stop; end
    if (DUT.MEM.mem[2] !== 16'd2) begin err = 1; $display("FAILED: mem[2] wrong."); $stop; end
    //@(posedge DUT.CPU.PC or negedge DUT.CPU.PC);

    // NOTE: if HALT is working, PC won't change again...

    if (~err) $display("INTERFACE OK");
    $stop;
  end
endmodule
