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

package Fft;

// ================================================================
// Modules Importation
import Vector :: * ;
import Complex :: * ;
import FixedPoint :: * ;
import Real :: * ;

// ================================================================
// Macro definition
`define FftPoints  16

// ================================================================
// Type Definition
typedef FixedPoint#(10,16) FftFloat;

// ================================================================
// Instance Definition

// instance FShow#(FftFloat);
//     function Fmt fshow (FftFloat x);
//         return $format("<FftFloat %b", x.i, ",%b", x.f, ">"); 
//     endfunction
// endinstance
// ================================================================
// Function definition
/**
 * Function
 * \brief  radix-4 butterfly unit 
 *         Butter fly is the computational core of FFT, and here is an excellent 
 *         example sourced from 
 *         http://csg.csail.mit.edu/6.175/lectures/L0x-FFT.pptx
 * \param  t [ 
 *              t’s (twiddle coefficients) are mathematically derivable constants 
 *              for each bfly4 and depend upon the position of bfly4 the in the network.
 *              t = [WN^0, WN^(q), WN^(2q), WN^(3q)]
 *         ]
 * \param  x [ the input arrary of the bfly4 ] 
 * \return z [ the output arrary of bfly4 ] 
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-07-10 10:44:43
 */
function Vector#(4,Complex#(FftFloat)) bfly4 (Vector#(4,Complex#(FftFloat)) t,  Vector#(4,Complex#(FftFloat)) x);

  Vector#(4,Complex#(FftFloat)) m, y, z;
  Complex#(FftFloat) j = cmplx(0, -1) ;

  m[0] = x[0] * t[0]; m[1] = x[1] * t[1]; 
  m[2] = x[2] * t[2]; m[3] = x[3] * t[3];

  y[0] = m[0] + m[2]; y[1] = m[0] - m[2]; 
  y[2] = m[1] + m[3]; y[3] = j*(m[1] - m[3]);

  z[0] = y[0] + y[2]; z[1] = y[1] + y[3];
  z[2] = y[0] - y[2]; z[3] = y[1] - y[3];

  return(z);
endfunction

/**
 * Function
 * \brief  Base-4 Digit Reversal Function
 *         This function is to supply an transformation from base-4 digital number 
 *         to the corresponding digit reversal number. 
 *         ------------------------------------------
 *         example:
 *         index Quaternary digit-reversed integer
 *         0     000        000            0
 *         1     001        100            16
 *         2     002        200            32
 *         3     003        300            48
 *         ...
 *         62    332        233            47
 *         63    333        333            63
 * \param  val [input number] 
 * \return Bit#(n) [base-4 reversal number]
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-07-14 10:08:12
 */
function Bit#(n) digitReversed ( Bit#(n) val);
    // digit reversal
    // example:
    // index Quaternary digit-reversed integer
    // 0     000        000            0
    // 1     001        100            16
    // 2     002        200            32
    // 3     003        300            48
    // ...
    // 62    332        233            47
    // 63    333        333            63
    Integer bw = valueof(TDiv#(TLog#(`FftPoints),2));
    Vector#(TDiv#(TLog#(`FftPoints), 2), Bit#(n)) dout;
    for (Integer i=0; i<bw; i=i+1)
    begin
        if(i==0)
            dout[i] = (val >> i*2) & 3;
        else
            dout[i] = ((val >> i*2) & 3) + (dout[i-1] << 2);
    end

    return dout[bw-1];
endfunction
 

/**
 * Function
 * \brief  Generate an list of the discrete points for a given continuous wave.
 * \param   
 * \return Vector#(`FftPoints, Complex#(FftFloat)) [the discrete points]
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-07-14 10:14:18
 */
function Vector#(`FftPoints, Complex#(FftFloat)) genWave ();
    Vector#(`FftPoints, Complex#(FftFloat)) dwd;
    Real ts = 1/`FftPoints;
    for (Real k=0; k<`FftPoints; k=k+1)
    begin
        dwd[round(k)] = cmplx(fromReal(5 + 2*cos(2*pi*k*ts-pi/2) + 3*cos(4*pi*k*ts) + 1*cos(100*pi*k*ts+pi/3)), 0);
    end
    return dwd;
endfunction


/**
 * Function
 * \brief  an implementation of the combinational FFT.
 * \param  in_data [the list of the given continuous wave's discrete points] 
 * \return Vector#(`FftPoints, Complex#(FftFloat)) [frequency domain result] 
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-07-14 10:16:45
 */
function Vector#(`FftPoints, Complex#(FftFloat)) fftcomb (Vector#(`FftPoints, Complex#(FftFloat)) in_data);
	//Declare vectors
    Vector#(4, Vector#(`FftPoints, Complex#(FftFloat))) stage_data;
    Vector#(`FftPoints, Complex#(FftFloat)) in_data_br;

    for (Bit#(TAdd#(TLog#(`FftPoints), 1)) i=0; i<`FftPoints; i=i+1) begin
        let br = digitReversed(i);
        in_data_br[i] = in_data[br];
    end

    stage_data[0] = in_data_br;
    Bit#(TAdd#(TLog#(`FftPoints), 1)) stageCount = fromInteger(valueof(TDiv#(TLog#(`FftPoints), 2)));
    for (Bit#(TAdd#(TLog#(`FftPoints), 1)) stage = 0; stage < stageCount; stage = stage + 1)
        if (stage==stageCount-1)
            stage_data[stage+1] = stage_f(stage,stage_data[stage],True);
        else
            stage_data[stage+1] = stage_f(stage,stage_data[stage],False);

    return(stage_data[stageCount]);
    // return(in_data);
endfunction


/**
 * Function
 * \brief  Stage Function 
 *         FFT is constructed by N/4(N is the number of FFT's Points) stages. 
 * \param  stage [index of the current stage] 
 * \param  stage_in [input of the current stage] 
 * \param  isLastStage [indication of the last stage] 
 * \return Vector#(`FftPoints, Complex#(FftFloat)) [the output of the current stage] 
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-07-14 10:20:00
 */
function Vector#(`FftPoints, Complex#(FftFloat)) stage_f ( Bit#(n) stage, Vector#(`FftPoints, Complex#(FftFloat)) stage_in, Bool isLastStage);
    let bN = `FftPoints;
    Vector#(`FftPoints, Complex#(FftFloat)) stage_temp, stage_out;

    for (Integer i = 0; i < bN/4; i = i + 1) begin
        Integer idx = i * 4;
        Vector#(4, Complex#(FftFloat)) x;
        x[0] = stage_in[idx];   x[1] = stage_in[idx+1];
        x[2] = stage_in[idx+2]; x[3] = stage_in[idx+3];

        let twid = getTwiddle(stage, fromInteger(i));
        let y = bfly4(twid, x);

        stage_temp[idx]   = y[0]; stage_temp[idx+1] = y[1];
        stage_temp[idx+2] = y[2]; stage_temp[idx+3] = y[3];
    end

    // Permutation
    for (Integer i = 0; i < bN; i = i + 1)
    begin
        let itrans = permute(stage, fromInteger(i), isLastStage);
        if(isLastStage)
            stage_out[itrans] = stage_temp[i];
        else
            stage_out[i] = stage_temp[itrans];
    end

  return(stage_out);
endfunction

/**
 * Function
 * \brief  Get the value of WN^k. k is the exponent of WN(WN=exp(-j2pi/N*k) 
 * \param  index [ the exponent ] 
 * \return Complex#(FftFloat) [WN^k] 
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-07-14 10:26:03
 */
function Complex#(FftFloat) getWn ( Bit#(n) index) ;
    Vector#(`FftPoints, FftFloat) vsin, vcos; 
    Real rN = `FftPoints;
    for (Real i=0; i<`FftPoints; i=i+1) begin
        vsin[round(i)] = fromReal(-1*sin(2*pi/rN*i));
        vcos[round(i)] = fromReal(cos(2*pi/rN*i));
    end 
    FftFloat re = vcos[index];
    FftFloat im = vsin[index];
    Complex#(FftFloat) res = cmplx(re, im);
    return res;
endfunction

/**
 * Function
 * \brief  Get Twiddle 
 *         Here well understanding to FFT is required...
 * \param  
 * \return 
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-07-14 10:29:43
 */
function Vector#(4, Complex#(FftFloat)) getTwiddle ( Bit#(n) stage, Bit#(n) bflyIndex );
    let s = stage;
    let bfi = bflyIndex;
    let bN = `FftPoints;

    Bit#(n) apbfc = 0;
    apbfc[2*s] = 1;

    let q = bfi % apbfc;
    let expbf = bN / (apbfc * 4);
    
    Vector#(4, Complex#(FftFloat)) res;

    res[0] = getWn(0 * q * expbf);
    res[1] = getWn(1 * q * expbf);
    res[2] = getWn(2 * q * expbf);
    res[3] = getWn(3 * q * expbf);

    return res;
endfunction

/**
 * Function
 * \brief  Permutation  
 *         Here well understanding to FFT is required...
 * \param  
 * \return 
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-07-14 10:32:11
 */
function Bit#(n) permute ( Bit#(n) stage, Bit#(n) index, Bool isLastStage );
    let s = stage;
    let x = index;

    // the total number of an A-Type Permutation's inputs.
    // apxc = 4**(s+1)
    Bit#(n) apxc = 0;
    apxc[2*(s+1)] = 1;

    // x = n * apxc + apxoffset
    // apxbase = n * apxc
    let apxoffset = x % apxc;
    let apxbase = x - apxoffset;
    
    // The maximum of an A-Type Permutation's q and every q's value is corresponding to an Bfly4 unit.
    // So ...
    let qmax = apxc / 4;
    let qi = apxoffset / 4;
    let qr = apxoffset % 4;
    
    // A-Type Permutation
    let aP = qr * qmax + qi;
    let aPout = apxbase + aP;
    
    // calculate B-type Permutation
    let bpxc = apxc * 4;

    // APout = n * bpxc + bpxoffset
    // bpxbase = n * bpxc
    let bpxoffset = aPout % bpxc;
    let bpxbase = aPout - bpxoffset;
    
    // the maximum of the number of B-type Permutation's inputs
    let bfcMax = bpxc / 4;
    let bfr = bpxoffset / bfcMax;
    let bfi = bpxoffset % bfcMax;
    let bPout = bpxbase + 4 * bfi + bfr;

    let out = isLastStage==False? bPout : aPout;

    return out;
endfunction

// ================================================================
// Interface definition
//interface Bfly4;
// interface Bfly4;
//     method Vector#(4, Complex#(s)) mbfly4(Vector#(4,Complex#(s)) t, Vector#(4,Complex#(s)) x);
// endinterface

//interface Fft;
// interface Fft;
//     method Action enq(Vector#(`FftPoints, Complex#(s)) in);
//     method ActionValue#(Vector#(`FftPoints, Complex#(s))) deq();
// endinterface

// ================================================================
// Module definition
// module mkBfly4(Bfly4);
//     method Vector#(4, Complex#(s)) mbfly4(Vector#(4,Complex#(s)) t, Vector#(4,Complex#(s)) x);
//         // Method body
//         return bfly4(t, x);
//     endmethod
// endmodule

endpackage

