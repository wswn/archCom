
package Testbench;

// ================================================================
// Project imports
import SimBench :: *;

// ================================================================
// Macro definition

// ================================================================
// Module definition
(* synthesize *)
module mkTestbench (Empty);

`ifdef SIM_MUX
    // Uncomment the lines below to check the correctness of all Multiplexer
    SimBench_IFC sim <- mkSimMux; 
`elsif SIM_ADDER
    // Uncomment the lines below to check the correctness of all Adder
    SimBench_IFC sim <- mkSimAdder; 
`elsif SIM_SHIFTER
    // Uncomment the lines below to check the correctness of all Shifter
    SimBench_IFC sim <- mkSimShifter; 
`elsif SIM_FIFO
    // Uncomment the lines below to check the correctness of all Fifo
    SimBench_IFC sim <- mkSimFifo; 
`elsif SIM_Fft
    // Uncomment the lines below to check the correctness of all Fifo
    SimBench_IFC sim <- mkSimFft; 
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
        $display("\nTest suit finish: return %d",x);
        $finish;
    endrule
endmodule

endpackage
