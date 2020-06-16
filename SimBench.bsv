/* Copyright (C) 
* 
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License
* as published by the Free Software Foundation; either version 2
* of the License, or (at your option) any later version.
* 
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
* 
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
* 
* 2020 - Junying Hu
*/

package SimBench;

// ================================================================
// Modules Importation
import Multiplexer :: * ;
import Adder :: * ;
import Shifter :: * ;
import LFSR::* ;

// ================================================================
// Macro definition
`define DISP_CRED   $write("\033[0;31m") 
`define DISP_CGREEN $write("\033[0;32m") 
`define DISP_CRESET $write("\033[0;39m") 

// ================================================================
// Interface definition
//interface Multiplexer_IFC;
interface SimBench_IFC;
   method Action start;
   method ActionValue #(int) finish;
endinterface


// ================================================================
// Type Definition
typedef enum {IDLE, PROCESS, FINISH} State_MTB
deriving (Eq, Bits, FShow);

// ================================================================
// Module definition

/**
 * Module
 * \brief  Module to check the correctness of the multiplexers 
 * \ifc    SimBench_IFC	
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-06-14 15:55:46
 */
(* synthesize *)
module mkSimMux (SimBench_IFC);
    
    // register for this module's state
    Reg #(State_MTB) rg_state <- mkReg(IDLE);
    
    // registers for clock counter
    Reg #(Bit #(3)) rg_cnt <- mkReg (0);
    let cnt = rg_cnt[2:0];

    // common register
    Reg #(Bit #(1)) rg_a <- mkReg (0);
    Reg #(Bit #(1)) rg_b <- mkReg (1);
    Reg #(Bit #(1)) rg_sel <- mkReg (0);

    Reg #(Bit #(5)) rg_a5 <- mkReg (5'b1_0101);
    Reg #(Bit #(5)) rg_b5 <- mkReg (5'b0_1010);

    // registers for multiplexer1
    Reg #(Bit #(1)) rg_mux <- mkReg (0);

    // registers for multiplexer5
    Reg #(Bit #(5)) rg_mux5 <- mkReg (0);

    rule mtb_process (rg_state == PROCESS);
        $write("cnt: %2d",cnt);
        
        // process for multiplexer1
        rg_sel <= rg_cnt[0];
        rg_mux <= multiplexer1(rg_sel, rg_a, rg_b);
        $write("\t multiplexer1: sel=%d, a=%d, b=%d, rg_mux=%d.", rg_sel, rg_a, rg_b, rg_mux);

        // process for multiplexer5
        rg_mux5  <= multiplexer5(rg_sel, rg_a5, rg_b5);
        $display("\t multiplexer1: sel=%d, a=%b, b=%b, rg_mux=%b.", rg_sel, rg_a5, rg_b5, rg_mux5);

        if (cnt < 6)
            rg_cnt <= rg_cnt+1;
        else
            rg_state <= FINISH;
    endrule

    method Action start if(rg_state == IDLE);
        rg_state <= PROCESS;
    endmethod

    method ActionValue#(int) finish if(rg_state==FINISH);
        rg_state <= IDLE;
        rg_cnt <= 0;
        return 42;
    endmethod
endmodule

/**
 * Module
 * \brief  Module to check the correctness of the adders
 * \ifc    SimBench_IFC	
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-06-14 15:59:24
 */
(* synthesize *)
module mkSimAdder (SimBench_IFC);
    
    // register for this module's state
    Reg #(State_MTB) rg_state <- mkReg(IDLE);
    
    // registers for clock counter
    Reg #(Bit #(5)) rg_cnt <- mkReg (0);
    let cnt = rg_cnt[4:0];

    // LFSR for random numbers.
    LFSR#(Bit#(4)) lfsr_a4 <- mkFeedLFSR( 4'h9 );
    LFSR#(Bit#(4)) lfsr_b4 <- mkLFSR_4; // default feed is 4'h9
    LFSR#(Bit#(8)) lfsr_a8 <- mkLFSR_8; // default feed is 8'h8E
    LFSR#(Bit#(8)) lfsr_b8 <- mkLFSR_8; // default feed is 8'h8E

    // common register
    Reg #(Bit #(1)) rg_a  <- mkReg (0);
    Reg #(Bit #(1)) rg_b  <- mkReg (1);
    Reg #(Bit #(4)) rg_a4 <- mkReg (0);
    Reg #(Bit #(4)) rg_b4 <- mkReg (0);
    Reg #(Bit #(8)) rg_a8 <- mkReg (0);
    Reg #(Bit #(8)) rg_b8 <- mkReg (0);

    Reg #(Bit #(4)) rg_a4p <- mkReg (0);
    Reg #(Bit #(4)) rg_b4p <- mkReg (0);
    Reg #(Bit #(8)) rg_a8p <- mkReg (0);
    Reg #(Bit #(8)) rg_b8p <- mkReg (0);

    // registers for Full Adder
    Reg #(Bit #(1)) rg_cin   <- mkReg (0);
    Reg #(Bit #(4)) rg_cin4p <- mkReg (0);
    Reg #(Bit #(8)) rg_cin8p <- mkReg (0);
    Reg #(Bit #(2)) rg_fa    <- mkReg (0);
    Reg #(Bit #(5)) rg_fa5   <- mkReg (0); 
    Reg #(Bit #(9)) rg_fa9   <- mkReg (0); 
    
    rule mtb_process (rg_state == PROCESS);
        $write("cnt: %2d",cnt);
        
        // process for One-bit Full Adder
        rg_cin <= rg_cnt[0];
        rg_cin4p[0] <= rg_cin;
        rg_cin8p[0] <= rg_cin;
        rg_fa  <= fa(rg_a, rg_b, rg_cin);
        $write("\t full adder: a=%d, b=%d, c_in=%d, c_out=%d, s=%d.", rg_a, rg_b, rg_cin, rg_fa[1], rg_fa[0]);

        // process for add4         
        rg_a4 <= lfsr_a4.value;
        rg_b4 <= lfsr_b4.value;
        rg_a4p <= rg_a4;
        rg_b4p <= rg_b4;

        rg_fa5 <= add4(rg_a4, rg_b4, rg_cin);
        if( rg_a4p + rg_b4p + rg_cin4p == rg_fa5[3:0] ) begin
            if( rg_fa5[3:0] < rg_a4p ) begin
                if(rg_fa5[4] == 1'b1 ) begin
                    `DISP_CGREEN;
                    $write("\t add4: a=%4b, b=%4b, c_in=%d, c_out=%d, s=%4b. √", rg_a4, rg_b4, rg_cin, rg_fa5[4], rg_fa5[3:0]);
                    `DISP_CRESET;
                end
                else begin
                    `DISP_CRED;
                    $write("\t add4: a=%4b, b=%4b, c_in=%d, c_out=%d, s=%4b. ×", rg_a4, rg_b4, rg_cin, rg_fa5[4], rg_fa5[3:0]);
                    `DISP_CRESET;
                end
            end
            else begin
                `DISP_CGREEN;
                $write("\t add4: a=%4b, b=%4b, c_in=%d, c_out=%d, s=%4b. √", rg_a4, rg_b4, rg_cin, rg_fa5[4], rg_fa5[3:0]);
                `DISP_CRESET;
            end
        end
        else begin
            `DISP_CRED;
            $write("\t add4: a=%4b, b=%4b, c_in=%d, c_out=%d, s=%4b. ×", rg_a4, rg_b4, rg_cin, rg_fa5[4], rg_fa5[3:0]);
            `DISP_CRESET;
        end
        
        // process for add8 
        rg_a8 <= lfsr_a8.value;
        rg_b8 <= lfsr_b8.value;
        rg_a8p <= rg_a8;
        rg_b8p <= rg_b8;

        rg_fa9 <= addN(rg_a8, rg_b8, rg_cin);
        if( rg_a8p + rg_b8p + rg_cin8p == rg_fa9[7:0] ) begin
            if( rg_fa9[7:0] < rg_a8p ) begin
                if(rg_fa9[8] == 1'b1 ) begin
                    `DISP_CGREEN;
                    $display("\t add8: a=%8b, b=%8b, c_in=%d, c_out=%d, s=%8b. √", rg_a8, rg_b8, rg_cin, rg_fa9[8], rg_fa9[7:0]);
                    `DISP_CRESET;
                end
                else begin
                    `DISP_CRED;
                    $display("\t add8: a=%8b, b=%8b, c_in=%d, c_out=%d, s=%8b. ×", rg_a8, rg_b8, rg_cin, rg_fa9[8], rg_fa9[7:0]);
                    `DISP_CRESET;
                end
            end
            else begin
                `DISP_CGREEN;
                $display("\t add8: a=%8b, b=%8b, c_in=%d, c_out=%d, s=%8b. √", rg_a8, rg_b8, rg_cin, rg_fa9[8], rg_fa9[7:0]);
                `DISP_CRESET;
            end
        end
        else begin
            `DISP_CRED;
            $display("\t add8: a=%8b, b=%8b, c_in=%d, c_out=%d, s=%8b. ×", rg_a8, rg_b8, rg_cin, rg_fa9[8], rg_fa9[7:0]);
            `DISP_CRESET;
        end

        if (cnt < 20) begin
            rg_cnt <= rg_cnt+1;
            lfsr_a4.next;
            lfsr_b4.next;
            lfsr_a8.next;
            lfsr_b8.next;
        end
        else
            rg_state <= FINISH;
    endrule

    method Action start if(rg_state == IDLE);
        rg_state <= PROCESS;
        lfsr_a4.seed(4'b0011);
        lfsr_b4.seed(4'b0101);
        lfsr_a8.seed(8'b0011);
        lfsr_b8.seed(8'b0101);
    endmethod

    method ActionValue#(int) finish if(rg_state==FINISH);
        rg_state <= IDLE;
        rg_cnt <= 0;
        return 42;
    endmethod
endmodule

/**
 * Module
 * \brief  Module to check the correctness of the Shifters
 * \ifc    SimBench_IFC	
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-06-14 15:59:24
 */
(* synthesize *)
module mkSimShifter (SimBench_IFC);
    
    // register for this module's state
    Reg #(State_MTB) rg_state <- mkReg(IDLE);
    
    // registers for clock counter
    Reg #(Bit #(5)) rg_cnt <- mkReg (0);
    let cnt = rg_cnt[4:0];

    // LFSR for random numbers.
    LFSR#(Bit#(32)) lfsr_a32 <- mkLFSR_32; 

    // common register
    Reg #(Bit #(32)) rg_a32  <- mkReg (0);
    Reg #(Bit #(32)) rg_a32p <- mkReg (0);

    // registers for Shifter
    Reg #(Bit #(5))  rg_sb5   <- mkReg (0);
    Reg #(Bit #(5))  rg_sb5p  <- mkReg (0);
    Reg #(Bit #(32)) rg_sf32  <- mkReg (0); 
    
    rule mtb_process (rg_state == PROCESS);
        $write("cnt: %2d",cnt);
        
        // process for One-bit Full Adder
        rg_sb5 <= rg_cnt;
        rg_sb5p <= rg_sb5;

        rg_a32 <= lfsr_a32.value;
        rg_a32p <= rg_a32;

        rg_sf32 <= barrelShiftRight32(rg_a32, rg_sb5);
        if( rg_a32p>>rg_sb5p == rg_sf32 ) begin
            `DISP_CGREEN;
            $display("\t add4: in=%32b, shiftBy=%2d, out=%32b. √", rg_a32, rg_sb5, rg_sf32);
            `DISP_CRESET;
        end
        else begin
            `DISP_CRED;
            $display("\t add4: in=%32b, shiftBy=%2d, out=%32b. ×", rg_a32, rg_sb5, rg_sf32);
            `DISP_CRESET;
        end

        if (cnt < 20) begin
            rg_cnt <= rg_cnt+1;
            lfsr_a32.next;
        end
        else
            rg_state <= FINISH;
    endrule

    method Action start if(rg_state == IDLE);
        rg_state <= PROCESS;
        lfsr_a32.seed(32'b0011);
    endmethod

    method ActionValue#(int) finish if(rg_state==FINISH);
        rg_state <= IDLE;
        rg_cnt <= 0;
        return 42;
    endmethod
endmodule

endpackage
