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
import SimBench :: * ;
import Ehr :: * ;
import LFSR :: * ;
import Vector :: * ;

// ================================================================
// Macro definition
`include <ConsoleColor.bsv>

// ================================================================
// Interface definition
//interface Fifo;
interface Fifo#(numeric type n, type t);
    // method Bool notFull;
    // method Bool notEmpty;
    method Action enq(t x);
    method Action deq;
    method t first;
endinterface

// ================================================================
// Function definition

// ================================================================
// Module definition
// (* synthesize *)

/**
 * Module
 * \brief  module to make 3-elements fifoes
 * \ifc    Fifo#(n,t)	
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-06-20 15:24:35
 */
module mkFifo3 (Fifo#(3, t)) provisos (Bits#(t, sa));
    Reg#(t) da <- mkRegU;
    Reg#(Bool) va <- mkReg(False);
    Reg#(t) db <- mkRegU;
    Reg#(Bool) vb <- mkReg(False);
    Reg#(t) dc <- mkRegU;
    Reg#(Bool) vc <- mkReg(False);

    method Action enq(t x) if (!vc);
        if (va) begin 
            if (vb) begin
                dc <= x; 
                vc <= True;   
            end 
            else begin
                db <= x; 
                vb <= True;
            end
        end 
        else begin 
            da <= x; 
            va <= True; 
        end
    endmethod
    method Action deq if (va);
        if (vb) begin 
            if (vc) begin
                da <= db;
                db <= dc;
                vc <= False;
            end
            else begin
                da <= db; 
                vb <= False; 
            end
        end
        else begin 
            va <= False; 
        end
    endmethod
    method t first if (va); return da;
    endmethod
endmodule

/**
 * Module
 * \brief  module to make 2-elements fifoes.
 * \ifc    Fifo#(n,t)	
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-06-20 15:26:13
 */
module mkFifo2 (Fifo#(2, t)) provisos (Bits#(t, sa));
    Reg#(t) da <- mkRegU();
    Reg#(Bool) va <- mkReg(False);
    Reg#(t) db <- mkRegU();
    Reg#(Bool) vb <- mkReg(False);
    method Action enq(t x) if (!vb);
        if (va) begin db <= x; vb <= True; end
        else begin da <= x; va <= True; end
    endmethod
    method Action deq if (va);
        if (vb) begin da <= db; vb <= False; end
        else begin va <= False; end
    endmethod
    method t first if (va); return da;
    endmethod
endmodule

/**
 * Module
 * \brief  module to make Conflict-Free 2-elements fifoes.
 * \ifc    Fifo#(n,t)
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-06-20 15:26:53
 */
module mkCFFifo2 (Fifo#(2, t)) provisos (Bits#(t, sa));
    Reg#(t) da <- mkRegU();
    Reg#(Bool) va <- mkReg(False);
    Reg#(t) db <- mkRegU();
    Reg#(Bool) vb <- mkReg(False);
    rule canonicalize if (vb && !va);
        da <= db;
        va <= True; vb <= False; 
    endrule
    method Action enq(t x) if (!vb);
        begin db <= x; vb <= True; end
    endmethod
    method Action deq if (va);
        va <= False;
    endmethod
    method t first if (va); return da;
    endmethod
endmodule

/**
 * Module
 * \brief  module to make Conflict-Free 2-elements fifoes using Ehr.
 * \ifc    Fifo#(n,t)
 * \author Hu Junying
 * \mail   Junying.hu@csu.edu.cn
 * \time   2020-06-20 15:27:47
 */
module mkCFFifo2WithEhr(Fifo#(2, t)) provisos (Bits#(t, sa));
    Ehr#(2, t) da <- mkEhr(?);
    Ehr#(2, Bool) va <- mkEhr(False);
    Ehr#(2, t) db <- mkEhr(?);
    Ehr#(2, Bool) vb <- mkEhr(False);

    rule canonicalize (vb[1] && !va[1]);
        da[1] <= db[1]; 
        va[1] <= True;
        vb[1] <= False; 
    endrule
    method Action enq(t x) if (!vb[0]);
        db[0] <= x; 
        vb[0] <= True;
    endmethod
    method Action deq if (va[0]);
        va[0] <= False;
    endmethod
    method t first if (va[0]);
        return da[0]; 
    endmethod
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
module mkCFFifo(Fifo#(n, t)) provisos (Bits#(t, sa));
    Vector#(n, Ehr#(2, t)) d <- replicateM(mkEhr(?));
    Vector#(n, Ehr#(2, Bool)) v <- replicateM(mkEhr(?));
    let size = valueOf(n);

    rule canonicalize (!v[0][1]);
        for(Integer i=0; i<size-1; i=i+1) begin
            d[i][1] <= d[i+1][1]; 
            v[i][1] <= v[i+1][1];
        end
        v[size-1][1] <= False;
    endrule
    method Action enq(t x) if (!v[size-1][0]);
        d[size-1][0] <= x; 
        v[size-1][0] <= True;
    endmethod
    method Action deq if (v[0][0]);
        v[0][0] <= False;
    endmethod
    method t first if (v[0][0]);
        return d[0][0]; 
    endmethod
endmodule

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
    Fifo#(5, Bit#(32)) fifo <- mkCFFifo;

    rule mtb_process (rg_state == PROCESS);
        if(cnt[0] == 0)
            $write("\n%scnt: %2d", `GREEN, cnt);
        else
            $write("\n%scnt: %2d", `BLUE, cnt);
        if (cnt < 25) begin
            rg_cnt <= rg_cnt+1;
        end
        else
            rg_state <= FINISH;
    endrule

    rule mtb_process_enq (rg_state == PROCESS && cnt < 20 && cnt > 0);
        // process for three-elements Fifo
        let x = lfsr_a32.value;
        fifo.enq(x);
        lfsr_a32.next;
        $write("\tenq: %d", x);
    endrule

    rule mtb_process_deq (rg_state == PROCESS && cnt < 23 && cnt > 0);
        // process for three-elements Fifo
        let y = fifo.first;
        fifo.deq;
        $write("\t\t\tdeq: %d", y);
    endrule

    method Action start if(rg_state == IDLE);
        rg_state <= PROCESS;
        lfsr_a32.seed(32'b0011);
    endmethod

    method ActionValue#(int) finish if(rg_state==FINISH);
        $write("\n%scnt: %2d",`NONE,cnt);
        rg_state <= IDLE;
        rg_cnt <= 0;
        return 42;
    endmethod
endmodule

endpackage
