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
import Multiplexer :: *;

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

endpackage
