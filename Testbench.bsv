
package Testbench;

// ================================================================
// Project imports
import SimBench :: *;

`ifdef SIM_MUX
    import Multiplexer :: * ;
`elsif SIM_ADDER
    import Adder :: * ;
`elsif SIM_SHIFTER
    import Shifter :: * ;
`elsif SIM_FIFO
    import Fifo :: * ;
`elsif SIM_FFT
    import Fft :: * ;
`elsif SIM_MUL
    import Multipliers :: * ;
`else
    import Multiplexer :: * ;
`endif

// ================================================================
// Macro definition
`include <ConsoleColor.bsv>

// ================================================================
// Module definition
(* synthesize *)
module mkTestbench (Empty);

`ifdef SIM_MUX
    SimBench_IFC sim <- mkSimMux; 
`elsif SIM_ADDER
    SimBench_IFC sim <- mkSimAdder; 
`elsif SIM_SHIFTER
    SimBench_IFC sim <- mkSimShifter; 
`elsif SIM_FIFO
    SimBench_IFC sim <- mkSimFifo; 
`elsif SIM_FFT
    SimBench_IFC sim <- mkSimFft; 
`elsif SIM_MUL
    SimBench_IFC sim <- mkSimMul; 
`else
    SimBench_IFC sim <- mkSimMux;
    // Report Error
    error("\033[0;31mThe simulation mode should be specified. Usage: make all_bsim SIM=SIM_MUX. \
           You can replace SIM_MUX with others.\033[0;39m");
`endif

    rule mtb_start ; 
        $display("Test suit start...");
        sim.start;
    endrule

    rule mtb_finish ;
        let x <- sim.finish; 
        $write("\n%s-------------------",`NONE); 
        $write("\nTest suit finish.");
        $write("\n%sTotal cnt: %2d",`NONE,x);
        $write("\n");
        $finish;
    endrule
endmodule

endpackage
