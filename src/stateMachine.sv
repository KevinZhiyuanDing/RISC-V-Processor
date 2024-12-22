module stateMachine(clk, s, reset, opcode, ALUop, shift, nsel, vsel, write, loada, loadb, loadc, loads, asel, bsel, load_addr, load_ir, load_pc, addr_sel, mem_cmd, reset_pc);
    input clk, s, reset;
    input [1:0] ALUop, shift;
    input [2:0] opcode;
    output wire load_addr, load_ir, addr_sel, reset_pc, load_pc;
    output wire [1:0] mem_cmd;
    output wire [1:0] vsel;
    output wire [2:0] nsel;
    output wire loada, loadb, loadc, loads, write, asel, bsel;

    `define NONE 2'b00
    `define MWRITE 2'b01
    `define MREAD 2'b10

    enum reg [5:0] {mov_1, mov1, mov2, mov3, 
                    mvn1, mvn2, mvn3, 
                    add1, add2, add3, add4, 
                    cmp1, cmp2, cmp3, 
                    and1, and2, and3, and4,
                    ldr1, ldr2, ldr3, ldr4, ldr5, ldr6,
                    str1, str2, str3, str4, str5,
                    RST, IF1, IF2, UpdatePC, HALT, Decode} state;


    //assign W = (state == Wait) ? 1'b1 : 1'b0 ;

    // State transition and output logic combined in one always block
    always @(posedge clk) begin
        if (reset) 
            state <= RST;
        else begin
            // State transitions and output assignments
            case (state)
                RST: state <= IF1;
                IF1: state <= IF2;
                IF2: state <= UpdatePC;
                UpdatePC: state <= Decode;
                HALT: state <= HALT;

                // need to change
                Decode: begin
                    if (opcode == 3'b111) state <= HALT;
                    else if (opcode == 3'b110) begin
                        if (ALUop == 2'b10) state <= mov_1;
                        else if (ALUop == 2'b00) state <= mov1;
                    end
                    else if (opcode == 3'b101) begin
                        if (ALUop == 2'b00) state <= add1;
                        else if (ALUop == 2'b01) state <= cmp1;
                        else if (ALUop == 2'b10) state <= and1;
                        else if (ALUop == 2'b11) state <= mvn1;
                    end
                    else if (opcode == 3'b011 && ALUop == 2'b00) state <= ldr1;
                    else if (opcode == 3'b100 && ALUop == 2'b00) state <= str1;
                end
                
                

                mov_1: state <= IF1;

                // MOV instruction 
                mov1: state <= mov2;
                mov2: state <= mov3;
                mov3: state <= IF1;

                // ADD instruction
                add1: state <= add2;
                add2: state <= add3;
                add3: state <= add4;
                add4: state <= IF1;

                // AND instruction
                and1: state <= and2;
                and2: state <= and3;
                and3: state <= and4;
                and4: state <= IF1;

                // CMP instruction 
                cmp1: state <= cmp2;
                cmp2: state <= cmp3;
                cmp3: state <= IF1;

                // MVN instructions
                mvn1: state <= mvn2;
                mvn2: state <= mvn3;
                mvn3: state <= IF1;

                // LDR instructions;
                ldr1: state <= ldr2;
                ldr2: state <= ldr3;
                ldr3: state <= ldr4;
                ldr4: state <= ldr5;
                ldr5: state <= IF1;
                //ldr6: state <= IF1;

                // STR instructions;
                str1: state <= str2;
                str2: state <= str3;
                str3: state <= str4;
                str4: state <= str5;
                str5: state <= IF1;

                
            endcase
        end
    end

    // change each instructions baesd on the state 
    assign W = (state == IF1) ? 1'b1 : 1'b0 ;

    // loada is high 
    assign loada = (state == add1) ? 1'b1 :
                    (state == cmp1) ? 1'b1 :
                    (state == and1) ? 1'b1 : 
                    (state == ldr1) ? 1'b1 :  // added for ldr1
                    (state == str1) ? 1'b1 : 
                    1'b0 ;
    
    // loadb is high 
    assign loadb = (state == add2) ? 1'b1 :
                    (state == cmp2) ? 1'b1 :
                    (state == and2) ? 1'b1 :
                    (state == mvn1) ? 1'b1 :
                    (state == mov1) ? 1'b1 : 
                    (state == str3) ? 1'b1 : 1'b0 ;
                    

    // loadc is high to load the final output
    assign loadc = (state == add3) ? 1'b1 :
                    (state == and3) ? 1'b1 :
                    (state == mvn2) ? 1'b1 :
                    (state == mov2) ? 1'b1 : 
                    (state == cmp3) ? 1'b1 : 
                    (state == ldr2) ? 1'b1 : 
                    (state == str2) ? 1'b1 : 
                    (state == str4) ? 1'b1 : 
                    1'b0;

    // loads is high to load status
    assign loads = (state == cmp3) ? 1'b1 : 1'b0 ;

    // changes vsel, asel, bsel (for mux) based on states
    assign vsel = (state == mov_1) ? 2'b01 : 
                  (state == ldr5) ? 2'b00 : 
                  2'b11 ;

    assign asel = (state == mvn2) ? 1'b1 :
                    (state == mov2) ? 1'b1 : 
                    (state == str2) ? 1'b0 : 
                    (state == str4) ? 1'b1 :
                    1'b0 ;
                    // note: (state == ldr2) ? 1'b0

    assign bsel = (state == ldr2) ? 1'b1 :
                  (state == str2) ? 1'b1 : 
                   1'b0;
                   // note : (state == str4) ? 1'b0

    // which writenum/readnum to get
    assign nsel = (state == add1) ? 3'b100 :
                    (state == cmp1) ? 3'b100 :
                    (state == and1) ? 3'b100 :
                    (state == mov_1) ? 3'b100 :
                    (state == add4) ? 3'b010 :
                    (state == and4) ? 3'b010 :
                    (state == mvn3) ? 3'b010 :
                    (state == mov3) ? 3'b010 : 
                    (state == ldr1) ? 3'b100 :   // added for ldr1
                    (state == ldr5) ? 3'b010 : 
                    (state == ldr6) ? 3'b010 : 
                    (state == str1) ? 3'b100 : 
                    (state == str3) ? 3'b010 : 
                    3'b001 ;

    
    // write is high when writing values in 
    assign write = (state == add4) ? 1'b1 :
                    (state == mvn3) ? 1'b1 :
                    (state == and4) ? 1'b1 :
                    (state == mov_1) ? 1'b1 :
                    (state == mov3) ? 1'b1 : 
                    (state == ldr5) ? 1'b1 :
                    (state == ldr6) ? 1'b1 :
                    1'b0 ;
    
    //load_addr, load_ir, addr_sel, mem_cmd, reset_pc

    

    assign load_pc = (state == RST) ? 1'b1 :
                     (state == UpdatePC) ? 1'b1 : 1'b0;

    assign reset_pc = (state == RST) ? 1'b1 : 1'b0;
    
    assign load_ir = (state == IF2) ? 1'b1 : 1'b0;

    // addr_sel is high when in IF1 & IF2
    assign addr_sel = (state == IF1) ? 1'b1 :
                      (state == IF2) ? 1'b1 : 
                      (state == str4) ? 1'b0 :
                      (state == str5) ? 1'b0 : 
                      1'b0;
                      // Note: (state == ldr4) ? 1'b0 : 

    // mem_cmd is 'MREAD when in IF states
    assign mem_cmd = (state == IF1) ? `MREAD :
                      (state == IF2) ? `MREAD : 
                      (state == ldr4) ? `MREAD : 
                      (state == ldr5) ? `MREAD : 
                      (state == str5) ? `MWRITE :
                      `NONE;

    assign load_addr = (state == ldr3) ? 1'b1 : 
                        (state == str3) ? 1'b1 : 1'b0;


    // always @(*) begin
        // for output logic
        
        // case (state)
        //     mov_1: begin
        //         write = 1;
        //         vsel <= 2'b01;
        //         nsel <= 3'b100;
        //     end

        //     mov1: begin
        //         loadb <= 1; // Enable loading into B register
        //         nsel <= 3'b001; // Select source register Rm
        //         vsel <= 2'b11;
    
        //     end
        //     mov2: begin
        //         asel <= 1; // set register A to 0
        //         loadc <= 1; // Enable ALU output to C register
        //         nsel <= 3'b001; // get value from register
        //     end
        //     mov3: begin
        //         nsel <= 3'b010; // Select source register Rd
        //         write <= 1;
        //     end


        //     // MVN instruction states
        //     mvn1: begin
        //         loadb <= 1;         // Load Rm into B
        //         nsel <= 3'b001;     // Select Rm for loading
        //         vsel <= 2'b11;
        //     end
        //     mvn2: begin
        //         loadc <= 1;         // Perform NOT operation, store in C
        //         asel <= 1;          // ALU gets input from B
        //         nsel <= 3'b001; // get value from register
        //     end
        //     mvn3: begin
        //         write <= 1;         // Write the result from C to Rd
        //         nsel <= 3'b010;     // Select Rd as the destination register
        //         //vsel <= 2'b11;      // Select C (the ALU output) as the write-back value
        //     end


        //     // ADD instruction states
        //     add1: begin
        //         loada <= 1; // Load first operand (Rn) into A
        //         nsel <= 3'b100; // Select Rn
        //         vsel <= 2'b11;
        //     end
        //     add2: begin
        //         loadb <= 1; // Load second operand (Rm) into B
        //         nsel <= 3'b001; // Select Rm
        //     end
        //     add3: begin
        //         loadc <= 1; // Perform addition in ALU, output to C
        //         asel <= 0; // Configure ALU for addition
        //         bsel <= 0;
        //     end
        //     add4: begin
        //         write <= 1; // Write result from C to Rd
        //         nsel <= 3'b010; // Select Rd
        //         vsel <= 2'b11;
        //     end

        //     // AND instruction states
        //     and1: begin
        //         loada <= 1; // Load first operand (Rn) into A
        //         nsel <= 3'b100; // Select Rn
        //     end
        //     and2: begin
        //         loadb <= 1; // Load second operand (Rm) into B
        //         nsel <= 3'b001; // Select Rm
        //     end
        //     and3: begin
        //         loadc <= 1; // Perform addition in ALU, output to C
        //         asel <= 0; // Configure ALU for addition
        //         bsel <= 0;
        //     end
        //     and4: begin
        //         write <= 1; // Write result from C to Rd
        //         nsel <= 3'b100; // Select Rd
        //     end

        //     // CMP instruction states
        //     cmp1: begin
        //         loada <= 1; // Load Rn into A for comparison
        //         nsel <= 3'b100;
        //     end
        //     cmp2: begin
        //         loadb <= 1; // Load Rm into B for comparison
        //         nsel <= 3'b001;
        //     end
        //     cmp3: begin
        //         asel <= 0;
        //         bsel <= 0;
        //         loadc <= 1;
        //         loads <= 1;
        //     end


        //     default: begin
        //         nsel <= 3'b000;
        //         vsel <= 2'b00;
        //         write <= 0;
        //         loada <= 0;
        //         loadb <= 0;
        //         loadc <= 0;
        //         asel <= 0;
        //         bsel <= 0;
        //     end
        // endcase
    // end



endmodule
