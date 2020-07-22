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

package Shifter;

// ================================================================
// Modules Importation
import SimBench :: * ;
import LFSR :: * ;
import Multiplexer :: * ;

// ================================================================
// Macro definition
`include <ConsoleColor.bsv>

// ================================================================
// Function definition
/**
 * Function
 * \brief  Barrel Shifter(right) using  (LogN)
 *         The bit encoding of N(also represented by param shiftBy)
 *         tells us which shifters are needed; if the value of the 
 *         i-th (least significant bit is 1 then we need to shift by 
 *         2^i bits
 *         e.g. 3=0b11=2^1+2^0, 5=0b101=2^2+2^0, 21=0b10101=2^5+2^2+2^0
 * \note   Please note that we can use >> and << to replace this function.
 * \param  in
 * \param  shiftBy
 * \return out 
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-06-15 17:50:11
 */
function Bit#(32) barrelShiftRight32(Bit#(32) in, Bit#(5) shiftBy);
    let out0 = shiftR1 (in, shiftBy[0]); 
    let out1 = shiftR2 (out0, shiftBy[1]);
    let out2 = shiftR4 (out1, shiftBy[2]);   
    let out3 = shiftR8 (out2, shiftBy[3]);
    let out  = shiftR16(out3, shiftBy[4]);
    return out;
endfunction

function Bit#(32) shiftR1(Bit#(32) in, Bit#(1) sel);
    let out = multiplexerN(sel, in, {1'h0,in[31:1]});
    return out;
endfunction
function Bit#(32) shiftR2(Bit#(32) in, Bit#(1) sel);
    let out = multiplexerN(sel, in, {2'h0,in[31:2]});
    return out;
endfunction
function Bit#(32) shiftR4(Bit#(32) in, Bit#(1) sel);
    let out = multiplexerN(sel, in, {4'h0,in[31:4]});
    return out;
endfunction
function Bit#(32) shiftR8(Bit#(32) in, Bit#(1) sel);
    let out = multiplexerN(sel, in, {8'h0,in[31:8]});
    return out;
endfunction
function Bit#(32) shiftR16(Bit#(32) in, Bit#(1) sel);
    let out = multiplexerN(sel, in, {16'h0,in[31:16]});
    return out;
endfunction

// ================================================================
// Module definition
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
