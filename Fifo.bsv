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
package Fifo;

// ================================================================
// Modules Importation
import SimBench :: *;
import Ehr      :: *;
import LFSR     :: *;
import GetPut   :: *;
import Vector   :: *;

// ================================================================
// Macro definition
`include <ConsoleColor.bsv>

// ================================================================
// Interface definition
// interface Fifo;
interface Fifo#(numeric type n, type t);
  method Bool notFull;
  method Action enq(t x);
  method Bool notEmpty;
  method Action deq;
  method t first;
  method Action clear;
endinterface

// ================================================================
// Function definition

/**
 * Function
 * \brief  Round up a val between 0 and size-1. 
 *         If the val is equal to size-1, 0 will be returned. 
 * \param  val [n-bit value] 
 * \param  size [integer value to give a upper bound] 
 * \return Bit#(n) [val+1 if val<size-1, 0 if val == size-1]
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-07-24 10:42:24
 */
function Bit#(n) roundUp(Bit#(n) val, Integer size);
    Bit#(n) upVal;
    Bit#(n) top = fromInteger(size-1);
    if(val==top)
        upVal = 0; 
    else
        upVal = val+1;
    return upVal;
endfunction

// ================================================================
// Module definition
// (* synthesize *)
/**
 * Module
 * \brief  a module to implement a conflicting fifo
 *         For conflicting fifoes, enq and deq can not fire concurrently in one cycle.
 * \ifc    Fifo#(n, t)	
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-07-24 10:32:05
 */
module mkFifo(Fifo#(n, t)) provisos (Bits#(t, sa));
    // define fifo's data region
    Vector#(n, Reg#(t)) data <- replicateM(mkReg(?));
    // define pointers of enq and deq
    Reg#(Bit#(TLog#(n))) enqP <- mkReg(0);
    Reg#(Bit#(TLog#(n))) deqP <- mkReg(0);
    // define full and emtpy flags
    Reg#(Bool) isEmpty <- mkReg(True);
    Reg#(Bool) isFull <- mkReg(False);
    
    method Bool notFull;
        return !isFull;
    endmethod
    method Action enq(t x) if(!isFull);
        data[enqP] <= x;
        enqP <= roundUp(enqP,valueOf(n));
        isFull <= roundUp(enqP,valueOf(n)) == deqP? True:False;
        isEmpty <= False;
    endmethod
    method Bool notEmpty;
        return !isEmpty;
    endmethod
    method Action deq if(!isEmpty);
        deqP <= roundUp(deqP, valueOf(n)); 
        isEmpty <= roundUp(deqP,valueOf(n)) == enqP? True:False;
        isFull <= False;
    endmethod
    method t first if(!isEmpty);
        return data[deqP];
    endmethod
    method Action clear;
        enqP <= 0;
        deqP <= 0;
        isEmpty <= True;
        isFull <= False;
    endmethod
endmodule

/**
 * Module
 * \brief  A module to implement a pipline fifo
 *         For pipline fifoes, enq and deq can fire concurrently in the
 *         order of "deq < enq".
 * \ifc    Fifo#(n, t)	
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-07-24 10:32:05
 */
module mkFifoP(Fifo#(n, t)) provisos (Bits#(t, sa));
    // define fifo's data region
    Vector#(n, Reg#(t)) data <- replicateM(mkReg(?));
    // define pointers of enq and deq
    Ehr#(3, Bit#(TLog#(n))) enqP <- mkEhr(0);
    Ehr#(3, Bit#(TLog#(n))) deqP <- mkEhr(0);
    // define full and emtpy flags
    Ehr#(3, Bool) isEmpty <- mkEhr(True);
    Ehr#(3, Bool) isFull <- mkEhr(False);
    
    method Bool notFull;
        return !isFull[1];
    endmethod
    method Action enq(t x) if(!isFull[1]);
        data[enqP[1]] <= x;
        enqP[1] <= roundUp(enqP[1],valueOf(n));
        isFull[1] <= roundUp(enqP[1],valueOf(n)) == deqP[1]? True:False;
        isEmpty[1] <= False;
    endmethod
    method Bool notEmpty;
        return !isEmpty[0];
    endmethod
    method Action deq if(!isEmpty[0]);
        deqP[0] <= roundUp(deqP[0], valueOf(n)); 
        isEmpty[0] <= roundUp(deqP[0],valueOf(n)) == enqP[0]? True:False;
        isFull[0] <= False;
    endmethod
    method t first if(!isEmpty[0]);
        return data[deqP[0]];
    endmethod
    method Action clear;
        enqP[2] <= 0;
        deqP[2] <= 0;
        isEmpty[2] <= True;
        isFull[2] <= False;
    endmethod
endmodule

/**
 * Module
 * \brief  a module to implement a bypass fifo
 *         For bypass fifoes, enq and deq can fire concurrently in the
 *         order of "enq < deq".
 * \ifc    Fifo#(n, t)	
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-07-24 10:32:05
 */
module mkFifoB(Fifo#(n, t)) provisos (Bits#(t, sa));
    // define fifo's data region
    Vector#(n, Ehr#(2,t)) data <- replicateM(mkEhr(?));
    // define pointers of enq and deq
    Ehr#(3, Bit#(TLog#(n))) enqP <- mkEhr(0);
    Ehr#(3, Bit#(TLog#(n))) deqP <- mkEhr(0);
    // define full and emtpy flags
    Ehr#(3, Bool) isEmpty <- mkEhr(True);
    Ehr#(3, Bool) isFull <- mkEhr(False);
    
    method Bool notFull;
        return !isFull[0];
    endmethod
    method Action enq(t x) if(!isFull[0]);
        data[enqP[0]][0] <= x;
        enqP[0] <= roundUp(enqP[0],valueOf(n));
        isFull[0] <= roundUp(enqP[0],valueOf(n)) == deqP[0]? True:False;
        isEmpty[0] <= False;
    endmethod
    method Bool notEmpty;
        return !isEmpty[1];
    endmethod
    method Action deq if(!isEmpty[1]);
        deqP[1] <= roundUp(deqP[1], valueOf(n)); 
        isEmpty[1] <= roundUp(deqP[1],valueOf(n)) == enqP[1]? True:False;
        isFull[1] <= False;
    endmethod
    method t first if(!isEmpty[1]);
        return data[deqP[1]][1];
    endmethod
    method Action clear;
        enqP[2] <= 0;
        deqP[2] <= 0;
        isEmpty[2] <= True;
        isFull[2] <= False;
    endmethod
endmodule

/**
 * Module
 * \brief  module to make Conflict-Free n-elements fifoes
 *         using Ehr 
 *         This module implement a fully functional fifo with the all of methods declared in 
 *         the interface "Fifo"
 * \ifc    Fifo#(n,t)	
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-06-20 15:28:45
 */
module mkFifoCF(Fifo#(n, t)) provisos (Bits#(t, sa));
    // define fifo's data region
    Vector#(n, Reg#(t)) data <- replicateM(mkReg(?));
    // define pointers of enq and deq
    Ehr#(3, Bit#(TLog#(n))) enqP <- mkEhr(0);
    Ehr#(3, Bit#(TLog#(n))) deqP <- mkEhr(0);
    // define full and emtpy flags
    Ehr#(3, Bool) isEmpty <- mkEhr(True);
    Ehr#(3, Bool) isFull <- mkEhr(False);
    // define Ehr for enq and deq
    Ehr#(3, Maybe#(t)) enqMethod <- mkEhr(tagged Invalid);
    Ehr#(3, Bool) deqMethod <- mkEhr(False);
   
    (* no_implicit_conditions, fire_when_enabled *) 
    rule canonicalize;
        t enqx = fromMaybe (?, enqMethod[2]);
        if(isValid(enqMethod[2])) begin
            Integer order = 2;
            data[enqP[order]] <= enqx;
            enqP[order] <= roundUp(enqP[order],valueOf(n));
            isFull[order] <= roundUp(enqP[order],valueOf(n)) == deqP[order]? True:False;
            isEmpty[order] <= False;
            enqMethod[2] <= tagged Invalid;
        end
        if(deqMethod[2]==True) begin
            Integer order = 1;
            deqP[order] <= roundUp(deqP[order], valueOf(n)); 
            isEmpty[order] <= roundUp(deqP[order],valueOf(n)) == enqP[order]? True:False;
            isFull[order] <= False;
            deqMethod[2] <= False;
        end
    endrule

    method Bool notFull;
        return !isFull[0];
    endmethod
    method Action enq(t x) if(!isFull[0]);
        enqMethod[0] <= tagged Valid x;
    endmethod
    method Bool notEmpty;
        return !isEmpty[0];
    endmethod
    method Action deq if(!isEmpty[0]);
        deqMethod[0] <= True;
    endmethod
    method t first if(!isEmpty[0]);
        return data[deqP[0]];
    endmethod
    method Action clear;
        enqMethod[1] <= tagged Invalid;
        deqMethod[1] <= False;
        enqP[0] <= 0;
        deqP[0] <= 0;
        isEmpty[0] <= True;
        isFull[0] <= False;
    endmethod
    // should have the schedule:
    // schedule (notFull, enq) CF (notEmpty, first, deq);
    // schedule (notFull, enq, notEmpty, first, deq) SB (clear);
endmodule

/**
 * Module
 * \brief  module to make Conflict-Free n-elements fifoes
 *         using Ehr 
 * \ifc    Fifo#(n,t)	
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-06-20 15:28:45
 */
// module mkCFFifo(Fifo#(n, t)) provisos (Bits#(t, sa));
//     Vector#(n, Ehr#(2, t)) d <- replicateM(mkEhr(?));
//     Vector#(n, Ehr#(2, Bool)) v <- replicateM(mkEhr(?));
//     let size = valueOf(n);
// 
//     rule canonicalize (!v[0][1]);
//         for(Integer i=0; i<size-1; i=i+1) begin
//             d[i][1] <= d[i+1][1]; 
//             v[i][1] <= v[i+1][1];
//         end
//         v[size-1][1] <= False;
//     endrule
//     method Action enq(t x) if (!v[size-1][0]);
//         d[size-1][0] <= x; 
//         v[size-1][0] <= True;
//     endmethod
//     method Action deq if (v[0][0]);
//         v[0][0] <= False;
//     endmethod
//     method t first if (v[0][0]);
//         return d[0][0]; 
//     endmethod
// endmodule

/**
 * Module
 * \brief  Module to check the correctness of the Fifo.
 * \ifc    SimBench_IFC	
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-06-14 15:59:24
 */
(* synthesize *)
module mkSimFifo (SimBench_IFC);
    
    // register for this module's state
    Reg #(State_MTB) rg_state <- mkReg(IDLE);
    
    // registers for clock counter
    Reg #(Bit #(5)) rg_cnt <- mkReg (0);
    let cnt = rg_cnt[4:0];

    // LFSR for random numbers.
    LFSR#(Bit#(32)) lfsr_a32 <- mkLFSR_32; 

    // common register
    Fifo#(5, Bit#(32)) fifo <- mkFifoCF;

    rule mtb_process (rg_state == PROCESS);
        if(cnt[0] == 0)
            $write("\n%scnt: %2d", `GREEN, cnt);
        else
            $write("\n%scnt: %2d", `CYAN, cnt);
        if (cnt < 25) begin
            rg_cnt <= rg_cnt+1;
        end
        else
            rg_state <= FINISH;
    endrule

    rule mtb_process_enq (rg_state == PROCESS && cnt<20 && cnt > 0);
        // process for three-elements Fifo
        let x = lfsr_a32.value;
        fifo.enq(x);
        lfsr_a32.next;
        $write("\tenq: %d", x);
    endrule

    rule mtb_process_deq (rg_state == PROCESS && cnt > 3);
        // process for three-elements Fifo
        let y = fifo.first;
        fifo.deq;
        $write("\t\t\tdeq: %d", y);
    endrule

    rule mtb_process_clear (rg_state == PROCESS && cnt == 10);
        // process for three-elements Fifo
        fifo.clear;
        $write("\t%sclear fifo%s.",`RED,`NONE);
    endrule

    method Action start if(rg_state == IDLE);
        rg_state <= PROCESS;
        lfsr_a32.seed(32'b0011);
    endmethod

    method ActionValue#(int) finish if(rg_state==FINISH);
        rg_state <= IDLE;
        rg_cnt <= 0;
        return unpack(extend(cnt));
    endmethod
endmodule

// ================================================================
// Define instances of ToGet and ToPut for the intefaces defined in this package
instance ToGet #( Fifo#(n, t), t ) ;
   function Get#(t) toGet (Fifo#(n, t) i);
      return (interface Get;
                 method ActionValue#(t) get();
                    i.deq ;
                    return i.first ;
              endmethod
         endinterface);
   endfunction
endinstance

instance ToPut #( Fifo#(n, t), t ) ;
   function Put#(t) toPut (Fifo#(n, t) i);
      return (interface Put;
                 method Action put(t x);
                    i.enq(x) ;
              endmethod
         endinterface);
   endfunction
endinstance

endpackage
