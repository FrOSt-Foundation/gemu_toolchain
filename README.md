# Skeleton toolchain to create techcompliant programs

This skeleton uses GEMUSingle, clang and [Yamakaky's assembler] (https://github.com/Yamakaky/dcpu) (which is also a dissambler, a debugger and a GEMU compatible emulator).

To compile, use `make`. To run, use `make run`.

---

## File structure explanation

- *KISS_bootloader/* contains the [KISS bootloader] (https://github.com/FrOSt-Foundation/KISS_bootloader)
- *boot/* contains a minimal C bootstrap code (boot.dasm)
- *program/* contains a minimal C code program.
  - *types.h* contains all of dcpu specific types (u16, u32, and so on)
  - *asm.c/asm.h* contain an implementation of specific assembly functions not available with C
  - *bootloader.h* contains the implementation of the struct provided by the bootloader
  - *entrypoint.c* is the implementation of the entrypoint in C.
- *tools/* contains all of the required tools to compile, link, assemble, run and debug your programs

## Makefile options

- `make`: to compile the program
- `make run`: to compile and run the program (uses GEMUSingle)
- `make clean`: to clean the binary folder
- `make debug`: to compile and run in debug mode the program (uses Yamakaky's debugger & emulator for maximum compatibility)

---

### Output of the makefile

The Makefile outputs a lot of different files in the *bin/* folder.
The files finishing in .bin are usable with GEMU.
The files finihsing in .bin.noswap are usable with Yamakaky's emulator (except with bootloader.bin which is also usable with Yamakaky's emulator).
The files finishing in .sym are the symbol maps usable in the debugger.

- *KISS_bootloader/* contains all compilation files related to the KISS bootloader.
- *program/* contains all assembly files generated from C.
- *program.dasm* is the concatenation of all assembly files from *boot/* and *program/*.
- *program.bin* contains the bootsector with the correct number of sectors to load from the floppy.

---

Please feel free to contribute to this toolchain!
