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

package Adder;

// ================================================================
// Modules Importation
import SimBench :: *;
import LFSR :: * ;
import Multiplexer :: *;

// ================================================================
// Macro definition
`include <ConsoleColor.bsv>

// ================================================================
// Function definition
/**
 * Function
 * \brief  One-bit Half Adder. 
 * \param  a 
 * \param  b 
 * \return {c,s} [two bits], s[sum], c[carry]
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-06-13 15:08:00
 */
function Bit#(2) ha(Bit#(1) a, Bit#(1) b);
    let s = a^b;
    let c = a&b;
    return {c, s};
endfunction

/**
 * Function
 * \brief  One-bit Full Adder.
 * \param  a
 * \param  b
 * \param  c_in [carry bit input]
 * \return {c_out,s} [two bits, s[sum], c[carry]]
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-06-13 15:17:02
 */
function Bit#(2) fa(Bit#(1) a, Bit#(1) b, Bit#(1) c_in);
    let ab  = ha(a, b);
    let abc = ha(ab[0], c_in);
    let c_out = ab[1] | abc[1];
    return {c_out, abc[0]};
endfunction


/**
 * Function
 * \brief  N-bit Full Adder.
 * \note   We use "+" rather than addN generally;
 * \param  a 
 * \param  b 
 * \param  c_in
 * \return {c,s}
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-06-16 09:55:04
 */
function Bit#(TAdd#(n,1)) addN(Bit#(n) a, Bit#(n) b, Bit#(1) c_in);
   // Use "+" to implement this function.
   Bit#(n) c = 0;
   c[0] = c_in;
   let s = a + b + c;
   if(s < a) 
       c[1] = 1;
   else
       c[1] = 0;
   return {c[1],s};

   // Use "fa" and for loop to implement this function
   //Bit#(n) s; 
   //Bit#(TAdd#(n,1)) c = 0; 

   //c[0] = c_in;
   //let valn = valueof(n);
   //for(Integer i=0; i<valn; i=i+1) begin
   //    let cs = fa(a[i],b[i],c[i]); 
   //    c[i+1] = cs[1]; s[i] = cs[0];
   //end
   //return {c[valn],s};
endfunction 

/**
 * Function
 * \brief  Four-bits Full Adder.
 * \param  a
 * \param  b
 * \param  c_in [carry bit input]
 * \return {c_out,s} [s[sum], c[carry]]
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-06-13 15:17:02
 */
function Bit#(5) add4(Bit#(4) a, Bit#(4) b, Bit#(1) c_in);
    Bit#(4) s = 0;
    Bit#(5) c = 0; c[0] = c_in;

    for(Integer i = 0; i < 4; i = i + 1) begin
        let cs = fa(a[i], b[i], c[i]);
        c[i+1] = cs[1]; s[i] = cs[0];
    end 

    return {c[4],s};
endfunction

function Bit#(9) add8(Bit#(8) a, Bit#(8) b, Bit#(1) c_in);
   let s30 = add4(a[3:0], b[3:0], c_in);
   let s740 = add4(a[7:4], b[7:4], 0);
   let s741 = add4(a[7:4], b[7:4], 1);
   let s74 = multiplexerN(s30[4], s740, s741);
   return {s74, s30[3:0]};
endfunction

// ================================================================
// Module definition
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

endpackage
