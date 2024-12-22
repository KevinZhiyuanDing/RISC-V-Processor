`timescale 1ps/1ps

module datapath_tb;
    // Declare testbench variables
    reg clk;
    reg [2:0] readnum, writenum;
    reg loada, loadb, loadc, loads, asel, bsel, write;
    reg [1:0] shift, ALUop, vsel;
    reg [15:0] sximm8, mdata, sximm5;                  // new inputs for datapath
    reg [7:0] PC;                                     // new input
    wire N_out, V_out, Z_out;                         // new outputs for status flags
    wire [15:0] datapath_out;

    // Instantiate the datapath
    datapath DUT (
        .clk(clk),
        .sximm8(sximm8),
        .sximm5(sximm5),
        .PC(PC),
        .mdata(mdata),
        .readnum(readnum),
        .vsel(vsel),
        .loada(loada),
        .loadb(loadb),
        .shift(shift),
        .asel(asel),
        .bsel(bsel),
        .ALUop(ALUop),
        .loadc(loadc),
        .loads(loads),
        .writenum(writenum),
        .write(write),
        .N_out(N_out),
        .V_out(V_out),
        .Z_out(Z_out),
        .datapath_out(datapath_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // Task to initialize inputs
    task initialize;
        begin
            readnum = 3'b000;
            writenum = 3'b000;
            loada = 0; loadb = 0; loadc = 0; loads = 0;
            asel = 0; bsel = 0; write = 0;
            shift = 2'b00; ALUop = 2'b00; vsel = 2'b00;
            sximm8 = 16'b0; 
            mdata = 16'b0;                     // stays at 0
            sximm5 = 16'b0; 
            PC = 8'b0;                         // stays at 0
        end
    endtask

    // Test sequence
    initial begin
        integer errors = 0;

        // Step 1: Initialization
        initialize();
        #10;

        // Test 1: Register File Write and Read
        $display("Test 1: Register File Write and Read");
        vsel = 2'b01;                // Select sximm8 as input
        sximm8 = 16'b0001001000110100;  // Binary representation of 0x1234
        writenum = 3'b001;           // Write to register 1
        write = 1;                   // Enable writing
        #10 write = 0;               // Complete write cycle

        readnum = 3'b001;            // Read from register 1
        loada = 1;                   // Load value to A register
        #10 loada = 0;               // Complete load cycle
        $display("  A register value = %b", DUT.Ain);
        if (DUT.Ain !== 16'b0001001000110100) begin
            $display("Test 1 Failed: Expected 16'b0001001000110100, got %b", DUT.Ain);
            errors = errors + 1;
        end

        // Test 2: ALU Addition
        $display("Test 2: ALU Addition");
        sximm5 = 16'b0000000000000001;  // Binary representation of 1
        bsel = 1;                    // Select sximm5 as Bin
        ALUop = 2'b00;               // Addition
        loadc = 1;                   // Load result to datapath_out
        #10 loadc = 0;               // Complete load cycle
        $display("  ALU result (Addition) = %b", datapath_out);
        if (datapath_out !== 16'b0001001000110101) begin
            $display("Test 2 Failed: Expected 16'b0001001000110101, got %b", datapath_out);
            errors = errors + 1;
        end

        // Test 3: ALU Subtraction
        $display("Test 3: ALU Subtraction");
        ALUop = 2'b01;               // Subtraction (A - B)
        loads = 1;                   // Load status flags
        loadc = 1;                   // Load result to datapath_out
        #10 loads = 0;
        loadc = 0;                   // Complete load cycle
        $display("  ALU result (Subtraction) = %b, Status = %b %b %b", datapath_out, N_out, V_out, Z_out);
        if (datapath_out !== 16'b0001001000110011) begin
            $display("Test 3 Failed: Expected 16'b0001001000110011, got %b", datapath_out);
            errors = errors + 1;
        end

        // Test 4: Shifter (Logical Left Shift)
        $display("Test 4: Shifter (Logical Left Shift)");
        ALUop = 2'b11;               // Bitwise complement
        loadc = 1;                   // Load result to datapath_out
        #10 loadc = 0;               // Complete load cycle
        $display("  ALU result (Bitwise complement) = %b", datapath_out);
        if (datapath_out !== 16'b1111111111111110) begin
            $display("Test 4 Failed: Expected 16'b1111111111111110, got %b", datapath_out);
            errors = errors + 1;
        end

        // Test 5: Shifter (Arithmetic Right Shift)
        //$display("Test 5: Shifter (Arithmetic Right Shift)");
        //shift = 2'b10;               // Arithmetic right shift
        //loadc = 1;                   // Load result to datapath_out
        //#10 loadc = 0;               // Complete load cycle
        //$display("  ALU result (Arithmetic Right Shift) = %b", datapath_out);
        //if (datapath_out !== 16'b0000000000000000) begin
            //$display("Test 5 Failed: Expected 16'b0000000000000000, got %b", datapath_out);
            //errors = errors + 1;
        //end
        
        // Test 6: Shifter (Left Shift)
        //$display("Test 6: Shifter (Left Shift)");
        //shift = 2'b01;               // Left shift
        //loadc = 1;                   // Load result to datapath_out
        //#10 loadc = 0;               // Complete load cycle
        //$display("  ALU result (Left Shift) = %b", datapath_out);
        //if (datapath_out !== 16'b0000000000000010) begin
            //$display("Test 6 Failed: Expected 16'b0000000000000010, got %b", datapath_out);
            //errors = errors + 1;
        //end

        // End simulation
        //if (errors == 0) begin
            //$display("All tests passed!");
        //end else begin
            //$display("Testing completed with %d errors.", errors);
        //end
        //$stop;


    end
endmodule


