# WHU_MIPSCPU_COD_Project

## Construction

- [Part I: Single-Cycle Implementation](./Single_Cycle/README.md)
- [Part II: Multi-Cycle Implementation](./Multi_Cycle/README.md)
- [MIPS ASM Testing Codes(dat/coe) 测试asm代码以及其对应的dat或coe文件](./Testing_Code/readme.txt)
- [Configuration File for Vivado(FPGA) 开发板约束文件](./Nexys4DDR_CPU.xdc)

```
.
├── Multi_Cycle
│   ├── FPGA
│   ├── README.md
│   ├── Simulate
│   │   ├── create_wave.sh
│   │   ├── display_wave.sh
│   │   ├── dm.v
│   │   ├── mccomp.v
│   │   ├── mccomp_tb.v
│   │   ├── mccomp_tb.vcd
│   │   ├── mccomp_wave
│   │   ├── results/
│   │   └── wave_sim.sh
│   └── src/
├── Nexys4DDR_CPU.xdc
├── README.md
├── Single_Cycle
│   ├── FPGA
│   ├── README.md
│   ├── Simulate
│   │   ├── Data_Memory.v
│   │   ├── Instruction_Memory.v
│   │   ├── create_wave.sh
│   │   ├── display_wave.sh
│   │   ├── results/
│   │   ├── sccomp.v
│   │   ├── sccomp_tb.v
│   │   ├── sccomp_tb.vcd
│   │   ├── sccomp_wave
│   │   └── wave_sim.sh
│   └── src/
└── Testing_Code/

12 directories, 91 files
```

## Notes

### Tools for Simulating and FPGA

#### For macOS

There are useful tools able to use for simulating verilog codes in macOS. Here I use `iverilog` as a verilog compiler, `vvp` as a wave-file generator and `gtkwave` as a wave displayer. All of three can be downloaded through the package manager `Homebrew`:

```bash
brew install icarus-verilog
brew install verilator
brew install --HEAD randomplum/gtkwave/gtkwave
brew install graphviz
```

Notice that the name is not different...

There are various instructions for these on Internet...

However, I still can't figure these three kinds of tools out very clearly, just know how to use them in a simple way: scripts named `create_wave.sh`, `wave_sim.sh` and `display_wave.sh` in `Simulate/`.

Basically:

```bash
iverilog -o [wave_file] [.v_srcs]
vvp [wave_file] > results/result_*
gtkwave [.vcd_file]
```

`.vcd_file` means the file dumped by testbench file.

#### For Windows

On Windows, we are required to use `ModelSim` for simulating and `Vivado` for loading the codes to FPGA(Nexys 4 DDR2). I don't find any substutional software in macOS for the latter. Welcome to inform in the issue...

### Other tools

#### MARS

...

#### mipsasm(seemed not very helpful?)

...

***ps: Both of two are for developing using MIPS Assembly Language.***

## Contribution

Great thanks to [the repository of scarletborder](https://github.com/scarletborder/myMipsCPU). 🙏
It was of great help after my own design failed... 🥺

## To be done

The report...etc.

