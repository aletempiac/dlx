# DLX processor project
### Developer: Alessandro Tempia Calvino

Open in development, next steps:
- Optimize and improve FP adder
- Change Branch prediction to GShare

The project contains all the vhdl code of a processor, see the report for further details.

In order to simulate the design, use the compiler Simulation/assembler.sh
For instance in the command line:
`./assebler.sh ASM_file.txt`
It will generate the machine code that will be read by the Instruction Memory at the start of the simulation.
Just use the script **_DLX_sim.scr_**  for compiling in ModelSim.
