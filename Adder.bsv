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
import Multiplexer :: *;

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

endpackage
