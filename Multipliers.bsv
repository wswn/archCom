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

package Multipliers;

// ================================================================
// Modules Importation
import LFSR :: * ;
import Adder :: * ;

// ================================================================
// Macro definition
`include <ConsoleColor.bsv>

// ================================================================
// Type definition

// ================================================================
// Instance definition

// ================================================================
// Function definition

/**
 * Function
 * \brief  Multiplier for 32-bit operands.
 *         http://csg.csail.mit.edu/6.175/labs/lab3-multipliers.html
 * \param  a [32-bit multiplicand] 
 * \param  b [32-bit multiplier] 
 * \return Bit#(64) [64-bit result]
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-07-17 11:32:32
 */
function Bit#(64) mul32(Bit#(32) a, Bit#(32) b);
    Bit#(32) prod = 0;
    Bit#(32) tp = 0;
    for(Integer i = 0; i < 32; i = i+1)
    begin
        Bit#(32) m = (a[i]==0)? 0 : b;
        Bit#(33) sum = addN(m,tp,0);
        prod[i:i] = sum[0];
        tp = sum[32:1];
    end
    return {tp,prod};
endfunction

/**
 * Function
 * \brief  BenchMark Function supplied by MIT6.175 
 *         http://csg.csail.mit.edu/6.175/labs/lab3-multipliers.html
 * \param  a [multiplicand]
 * \param  b [multiplier] 
 * \return Bit#(TAdd#(n,n)) [result] 
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-07-15 17:16:34
 */
function Bit#(TAdd#(n,n)) multiply_unsigned( Bit#(n) a, Bit#(n) b );
    UInt#(n) a_uint = unpack(a);
    UInt#(n) b_uint = unpack(b);
    UInt#(TAdd#(n,n)) product_uint = zeroExtend(a_uint) * zeroExtend(b_uint);
    return pack( product_uint );
endfunction

/**
 * Function
 * \brief  BenchMark Function supplied by MIT6.175 
 *         http://csg.csail.mit.edu/6.175/labs/lab3-multipliers.html
 * \param  a [multiplicand]
 * \param  b [multiplier] 
 * \return Bit#(TAdd#(n,n)) [result] 
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-07-15 17:16:34
 */
function Bit#(TAdd#(n,n)) multiply_signed( Bit#(n) a, Bit#(n) b );
    Int#(n) a_int = unpack(a);
    Int#(n) b_int = unpack(b);
    Int#(TAdd#(n,n)) product_int = signExtend(a_int) * signExtend(b_int);
    return pack( product_int );
endfunction

// ================================================================
// Interface definition
//interface Multiplier;
interface Multiplier#(numeric type n);
    method Action startMul(Bit#(n) x, Bit#(n) y);
    method ActionValue#(Bit#(TAdd#(n,n))) getMulRes;
endinterface


// ================================================================
// Module definition

/**
 * Module
 * \brief  Make an Folded Multiplier whose size is 32. 
 * \ifc    Multiplier#(32)	
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-07-17 18:40:54
 */
// module mkFoldedMultiplier(Multiplier#(32));      
//     Reg#(Bit#(32))   a       <- mkRegU(); 
//     Reg#(Bit#(32))   b       <- mkRegU(); 
//     Reg#(Bit#(32))   prod    <- mkRegU();
//     Reg#(Bit#(32))   tp      <- mkReg(0);
//     Reg#(Bit#(32))   i       <- mkReg(32);
//     Reg#(Bool)       busy    <- mkReg(False);
// 
//     rule mulStep if (i < 32);
//         Bit#(32) m = (a[0]==0)? 0 : b;
//         a <= a >> 1;
//         Bit#(33) sum = addN(m,tp,0);
//         prod <= {sum[0], prod[31:1]};
//         tp <= sum[32:1];
//         i <= i+1;
//     endrule
// 
//     method Action startMul(Bit#(32) x, Bit#(32) y) if (!busy);
//         a <= x; b <= y; busy <= True; i <= 0;
//     endmethod
//     method ActionValue#(Bit#(64)) getMulRes if ((i==32) && busy); 
//         busy <= False;
//         return {tp,prod};
//     endmethod
// 
// endmodule

function Bit#(n) arithShiftR1(Bit#(n) x);
    Int#(n) xintn = unpack(x);
    Int#(n) yintn = xintn >> 1; 
    return pack(yintn);
endfunction

// function Bit#(n) compInv(Bit#(n) x) 
//     // n >= 1;
//     provisos(Add#(1,j,n));
// 
//     Int#(n) xInt = unpack(x);
//     Int#(n) xIntInv = -xInt;
//     Bit#(n) xBit = pack(xIntInv);
//     Bit#(n) y;
//     let signX = msb(xBit);
//     if( signX==1 )
//         y = {signX, invert(xBit[valueOf(n)-2:0])+1};
//     else
//         y = xBit;
// 
//     return y;
// endfunction

module mkFoldedMultiplier(Multiplier#(n)) 
    // n >= 1
    provisos(Add#(1, j, n));

    let nInteger = valueOf(n);

    Reg#(Bit#(TAdd#( TAdd#(n,n),1 )))   m_pos       <- mkRegU(); 
    Reg#(Bit#(TAdd#( TAdd#(n,n),1 )))   m_neg       <- mkRegU(); 
    Reg#(Bit#(TAdd#( TAdd#(n,n),1 )))   p           <- mkRegU(); 

    Reg#(Bit#(n))   i               <- mkReg(fromInteger(nInteger));
    Reg#(Bool)      busy            <- mkReg(False);
    Reg#(Bool)      shiftRequired   <- mkReg(False);

    rule mulStep if ( i < fromInteger(nInteger) && shiftRequired==False );
        // if(i==0)
        //     $write("\nm_pos.%b m_neg.%b p.%b ", m_pos, m_neg, p);
        let pr = p[1:0];
        p <= case(pr)
            2'b01 : (p + m_pos);
            2'b10 : (p + m_neg); 
            default : (p);
        endcase;
        shiftRequired <= True;
        i <= i+1;
        // $write("\ni.%d, sum.%b, tp.%b, prod.%b, m.%b", i, sum, tp, prod, m);
    endrule

    rule shiftp if (shiftRequired);
        shiftRequired <= False;
        p <= arithShiftR1(p);
    endrule

    method Action startMul(Bit#(n) x, Bit#(n) y) if (!busy);
        m_pos <= {x, 0};
        m_neg <= {(-x), 0};
        p <= {0, y, 1'b0};
        busy <= True; 
        i <= 0;
        // $write("\nx.%b y.%b n.%2d ", x, y, valueOf(n));
    endmethod
    method ActionValue#(Bit#(TAdd#(n,n))) getMulRes if ((i==fromInteger(nInteger)) && busy && shiftRequired==False); 
        busy <= False;
        return p[nInteger*2:1];
    endmethod
endmodule

/**
 * Module
 * \brief  Make an Folded Multiplier whose size is 32. 
 * \ifc    Multiplier#(32)	
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-07-17 18:40:54
 */
module mkFoldedMultiplierU(Multiplier#(n)) 
    // n >= 1
    provisos(Add#(1, j, n));

    let nInteger = valueOf(n);
    Reg#(Bit#(n))   a       <- mkRegU(); 
    Reg#(Bit#(n))   b       <- mkRegU(); 
    Reg#(Bit#(n))   prod    <- mkRegU();
    Reg#(Bit#(n))   tp      <- mkReg(0);
    Reg#(Bit#(n))   i       <- mkReg(fromInteger(nInteger));
    Reg#(Bool)      busy    <- mkReg(False);

    rule mulStep if (i < fromInteger(nInteger));
        Bit#(n) m = (a[0]==0)? 0 : b;
        a <= a >> 1;
        Bit#(TAdd#(n,1)) sum = addN(m,tp,0);
        prod <= {sum[0], prod[nInteger-1:1]};
        tp <= sum[nInteger:1];
        i <= i+1;
        // $write("\ni.%d, sum.%b, tp.%b, prod.%b, m.%b", i, sum, tp, prod, m);
    endrule

    method Action startMul(Bit#(n) x, Bit#(n) y) if (!busy);
        a <= x; b <= y; tp <= 0; busy <= True; i <= 0;
        // $write("\nx.%b y.%b n.%2d ", x, y, valueOf(n));
    endmethod
    method ActionValue#(Bit#(TAdd#(n,n))) getMulRes if ((i==fromInteger(nInteger)) && busy); 
        busy <= False;
        return {tp,prod};
    endmethod
endmodule

/**
 * Module
 * \brief  BenchMark Module Implement. 
 *         There are two operands, the first of which represents to-test Interface and
 *         the second one is a benchmark function.
 * \ifc 	
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-07-17 18:43:05
 */
module mkTbMulModule#(  Multiplier#(n) testModule,
                        function Bit#(TAdd#(n,n)) benchFunction(Bit#(n) a, Bit#(n) b), 
                        Bool isVerbose) (Empty)     
    provisos(Add#(8, j, n));

    Bit#(n) m1_seed = ( 1 << (valueOf(n)-1) ) + 'b1000_1111;
    Bit#(n) m2_seed = ( 1 << (valueOf(n)-1) ) + 'b1000_1001;
                
    // LFSR for random numbers.
    LFSR#(Bit#(n)) lfsr_m1_n <- mkFeedLFSR(m1_seed);
    LFSR#(Bit#(n)) lfsr_m2_n <- mkFeedLFSR(m2_seed);

    Reg#(Bit#(n)) m1 <- mkReg(0);
    Reg#(Bit#(n)) m2 <- mkReg(0);

    // State

    rule process;
        // first calculate 0x0
        testModule.startMul(m1, m2);
    endrule

    rule result;
        // this RULE will fire after "process" because of the function - testModule.getMulRes.
        // Before get a result from testModule, m1 and m2 are assigned firstly here, the 
        // value of which take effect at the next cycle.
        m1 <= lfsr_m1_n.value;
        m2 <= lfsr_m2_n.value;
        lfsr_m1_n.next;
        lfsr_m2_n.next;

        // get result
        let yt <- testModule.getMulRes;
        let yb = benchFunction(m1, m2);
        
        // compare
        let cmp = yt==yb? True : False;
        if(isVerbose==True) begin
            Int#(n) m1s = unpack(m1);
            Int#(n) m2s = unpack(m2);
            Int#(TAdd#(n,n)) yts = unpack(yt);
            Int#(TAdd#(n,n)) ybs = unpack(yb);
            $write("\nmultiplier function test: %d x %d = %d <yt>, %d <yb>", m1s, m2s, yts, ybs);
            // $write("\nmultiplier function test: %d x %d = %d <yt>, %d <yb>", m1, m2, yt, yb);
            if( cmp == True ) 
                $write(`GREEN, "[ ", fshow(cmp), " ]", `NONE );
            else
                $write(`RED, "[ ", fshow(cmp), " ]", `NONE );
        end
        else
            if( cmp == True ) 
                $write(`GREEN, "[ ", fshow(cmp), " ]", `NONE );
            else
                $write(`RED, "[ ", fshow(cmp), " ]", `NONE );
    endrule

endmodule
/**
 * Module
 * \brief  BenchMark Module Implement. 
 *         There are two operands, the first of which represents to-test function and
 *         the second one is a benchmark function.
 * \ifc    Empty	
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-07-17 11:35:43
 */
// (* synthesize *)
module mkTbMulFunction#(    function Bit#(TAdd#(n,n)) testFunction(Bit#(n) a, Bit#(n) b),
                            function Bit#(TAdd#(n,n)) benchFunction(Bit#(n) a, Bit#(n) b), 
                            Bool isVerbose) (Empty);

    // LFSR for random numbers.
    LFSR#(Bit#(n)) lfsr_m1_n <- mkFeedLFSR('b1000_1111);
    LFSR#(Bit#(n)) lfsr_m2_n <- mkFeedLFSR('b1000_1001);

    Reg#(Bit#(n)) m1 <- mkReg(0);
    Reg#(Bit#(n)) m2 <- mkReg(0);

    // State

    rule process;
        m1 <= lfsr_m1_n.value;
        m2 <= lfsr_m2_n.value;
        lfsr_m1_n.next;
        lfsr_m2_n.next;

        let yt = testFunction(m1, m2);
        let yb = benchFunction(m1, m2);

        let cmp = yt==yb? True : False;
        if(isVerbose==True) begin
            $write("\nmultiplier function test: %d x %d = %d<yt>, %d<yb> ", m1, m2, yt, yb);
            if( cmp == True ) 
                $write(`GREEN, "[ ", fshow(cmp), " ]", `NONE );
            else
                $write(`RED, "[ ", fshow(cmp), " ]", `NONE );
        end
        else
            if( cmp == True ) 
                $write(`GREEN, "[ ", fshow(cmp), " ]", `NONE );
            else
                $write(`RED, "[ ", fshow(cmp), " ]", `NONE );
    endrule

endmodule

// (* synthesize *)
// module mkTbDumb();
//     function Bit#(16) test_function( Bit#(8) a, Bit#(8) b ) = multiply_unsigned( a, b );
//     Empty tb <- mkTbMulFunction(test_function, multiply_unsigned, True);
//     return tb;
// endmodule
// 
// (* synthesize *)
// module mkTbFoldedMultiplier();
//     Multiplier#(8) dut <- mkFoldedMultiplier();
//     Empty tb <- mkTbMulModule(dut, multiply_signed, True);
//     return tb;
// endmodule

endpackage 
