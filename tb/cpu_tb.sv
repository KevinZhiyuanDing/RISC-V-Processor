
module cpu_tb();
    reg clk, reset, err;
    reg [15:0] read_data, mdata;
    wire [15:0] write_data;
    wire Z, V, N;
    wire [8:0] mem_addr;
    wire [1:0] mem_cmd;
  

    cpu DUT(.clk(clk), .reset(reset), 
            .mdata(mdata), .read_data(read_data),
            .mem_cmd(mem_cmd), .mem_addr(mem_addr), .write_data(write_data), 
            .N(N), .V(V), .Z(Z));

    
    initial begin
        clk <= 1'b1;
        forever #5 clk = ~clk;
    end

    initial begin
        // Initialize inputs
        read_data = 16'b0;
        mdata = 16'b0;
        err = 0;

        reset = 1'b1; // reset asserted
        @(negedge clk); // wait until next falling edge of clock
        reset = 1'b0; // reset de-asserted, PC still undefined if as in Figure 4

        #10; // waiting for RST state to cause reset of PC
        @(posedge clk); // wait until next falling edge of clock
        @(negedge clk);

        // NOTE: your program counter register output should be called PC and be inside a module with instance name CPU
        if (DUT.PC !== 9'b0) begin err = 1; $display("FAILED: PC is not reset to zero."); $stop; end

        @(posedge DUT.PC or negedge DUT.PC);  // wait here until PC changes; autograder expects PC set to 1 *before* executing MOV R0, X
        if (DUT.PC !== 9'h1) begin err = 1; $display("FAILED: PC should be 1."); $stop; end

        read_data = 16'b1101000000000101;
        mdata = 16'b1101000000000101;

        @(posedge DUT.PC or negedge DUT.PC);  // wait here until PC changes; autograder expects PC set to 2 *after* executing MOV R0, X
        if (DUT.PC !== 9'h2) begin err = 1; $display("FAILED: PC should be 2."); $stop; end
        if (DUT.DP.REGFILE.R0 !== 16'h5) begin err = 1; $display("FAILED: R0 should be 5."); $stop; end  // because MOV R0, X should have occurred
  
        // NOTE: if HALT is working, PC won't change again...

        if (~err) $display("INTERFACE OK");
        $stop;       

    end
endmodule
