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

endpackage
