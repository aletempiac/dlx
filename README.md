# DLX processor project

<img src="images/Datapath_Schematic.svg" alt="Schematic" style="float: left; margin-right: 10px;" />  

The project contains all the VHDL code of a processor, see the [report] for further details.

## How to simulate

In order to simulate the design, you have to compile your DLX assembly, you have a complete list of all the instructions in the [report]. The compiler is called by [assembler.sh] on a file containing the assembly.  
For instance in the command line:

```bash
$ ./assembler.sh BranchPrediction.asm.txt
```

It will generate the machine code that will be read by the Instruction Memory at the start of the simulation.  

Use the script [DLX_sim.scr] to compile the design in ModelSim using
```bash
$ source DLX_sim.scr
```

## Synthesis

The design present in the `Synthesis` folder is fully synthesizable and [DLX.scr] compiles for Synopsys Design Compiler.

### Developers: Alessandro Tempia Calvino, Fausto Chiatante
Possible improvements in background:
- Add floating-point units to the design
- Multi-cycle execution

[report]: Report.pdf
[assembler.sh]: Simulation/assembler.sh
[DLX_sim.scr]: Simulation/DLX_sim.scr
[DLX.scr]: Synthesis/DLX.scr
