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

package Multiplexer;

// ================================================================
// Project imports
import SimBench :: *;

// ================================================================
// Function definition

/**
 * Function
 * \brief  Logical AND[1bit]
 * \param  in_1
 * \param  in_2
 * \return in_1 & in_2 
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-06-13 16:43:35
 */
function Bit#(1) and1(Bit#(1) in_1, Bit#(1) in_2);
    return in_1 & in_2;
endfunction   

/**
 * Function
 * \brief  Logical OR[1bit]
 * \param  in_1
 * \param  in_2
 * \return in_1 | in_2
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-06-13 16:44:37
 */
function Bit#(1) or1(Bit#(1) in_1, Bit#(1) in_2);
    return in_1 | in_2;
endfunction  


/**
 * Function
 * \brief  Logical NOT[1bit]
 * \param  in
 * \return !in
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-06-13 16:45:41
 */
function Bit#(1) not1(Bit#(1) in);
    return ~in;
endfunction  

/**
 * Function
 * \brief  One-bit Multiplexer
 * \param  sel [selector]
 * \param  a 
 * \param  b
 * \return (sel == 0)? a : b; 
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-06-13 15:31:05
 */
function Bit#(1) multiplexer1(Bit#(1) sel, Bit#(1) a, Bit#(1) b);
    // Use C-like constructs  
    //return (sel == 0)? a : b;

    // Use and1, or1 and not1 to implement an one-bit Multiplexer
    let selNot = not1(sel);
    let a_selNot = and1(a, selNot);
    let b_sel = and1(b, sel);
    let out = or1(a_selNot, b_sel);
    return out;
endfunction

/**
 * Function
 * \brief  N-bit multiplexer constructed using polymorphism.
 * \note   Please note that we should use "(sel == 0)? a : b" 
 *         rather than multiplexern
 * \param  sel [selector] 
 * \param  a
 * \param  b 
 * \return (sel == 0)? a : b
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-06-13 17:43:00
 */
function Bit#(n) multiplexerN(Bit#(1) sel, Bit#(n) a, Bit#(n) b);
    // Use for loops and multiplexer1
    //return (sel == 0)? a : b;

    Bit#(n) out;
    for(Integer i = 0; i < valueOf(n); i = i + 1) begin
        out[i] = multiplexer1(sel, a[i], b[i]);
    end
    return out;
endfunction

/**
 * Function
 * \brief  Five-bit multiplexer
 * \param  sel [selector] 
 * \param  a
 * \param  b 
 * \return (sel == 0)? a : b
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-06-13 17:43:00
 */
function Bit#(5) multiplexer5(Bit#(1) sel, Bit#(5) a, Bit#(5) b);
    // Use for loops and multiplexer1
    //Bit#(5) out;
    //for(Integer i = 0; i < 5; i = i + 1) begin
    //    out[i] = multiplexer1(sel, a[i], b[i]);
    //end
    //return out;

    // Use polymorphism constructor
    return multiplexerN(sel, a, b);
endfunction

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

endpackage
