# gdb-i8085

A GNU GDB build with **Intel 8085** support, for source-level debugging of
i8085 firmware (as emitted by the LLVM i8085 backend) — including **single
stepping** and the **undocumented opcodes**. Used by the
[`platform-intel_mcs85`](https://github.com/maxgerhardt/platform-intel_mcs85)
PlatformIO platform together with the
[`tool-i8085-trace`](https://github.com/maxgerhardt/tool-i8085-trace) simulator,
which provides the GDB remote (RSP) server.

There is no i8085 architecture in stock binutils/GDB (bfd only knows z80). This
adds i8085 as a mach variant of the z80 bfd architecture, with:

- **bfd**: recognises `e_machine = 0x103` (259, what LLVM emits) as
  `bfd_mach_i8085`, so `elf32-i8085` files load natively.
- **gdb (`i8085-tdep`)**: a dedicated gdbarch with the 15-register i8085 model
  (matching the simulator's stub and LLVM's DWARF register numbers), unwinding
  purely via **DWARF CFI** (`.debug_frame`) — not the z80 prologue analyser,
  which crashes on i8085 code. This is what makes stepping work.
- **opcodes**: a full i8085 disassembler (all documented + undocumented opcodes:
  `DSUB`, `ARHL`, `RDEL`, `LDHI`, `LDSI`, `RSTV`, `SHLX`, `JNX5`, `LHLX`,
  `JX5`), which the z80 decoder cannot render (those bytes are z80 prefixes).

## Branches

- **`main`** — the source patch (`i8085-support.patch`) against GNU gdb 16.3,
  plus this README and the build script.
- **`windows_x64`** — the prebuilt Windows x64 binary (`bin/i8085-elf-gdb.exe`),
  its runtime DLLs and `share/gdb`, packaged for PlatformIO.

## Building from source

```sh
./build.sh            # downloads gdb-16.3, applies the patch, configures, builds
```

The patch touches `bfd/bfd-in2.h`, `bfd/cpu-z80.c`, `bfd/elf32-z80.c`,
`gdb/z80-tdep.c`, and `opcodes/z80-dis.c`. The i8085 disassembler is ported from
the [i8085-trace](https://github.com/apullin/i8085-trace) emulator.

## Usage

```sh
# firmware must be built with DWARF-4 debug info (gdb's z80 DWARF-5 line reader
# does not handle the i8085 line tables): clang ... -gdwarf-4
i8085-elf-gdb firmware.elf
(gdb) target remote localhost:1234      # tool-i8085-trace --gdb=1234 ...
(gdb) break main
(gdb) continue
(gdb) next / step / stepi / bt / info registers
```

## License

GPLv3+ (GDB). See the GNU GDB sources.
