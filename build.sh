#!/usr/bin/env bash
# Build gdb-i8085 from GNU gdb 16.3 + the i8085 support patch.
# Requires an MSYS2/MinGW-w64 environment (gcc, make, gmp, mpfr, expat).
set -e

VER=16.3
HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="gdb-$VER"

export PATH="/mingw64/bin:/usr/bin:$PATH"

if [ ! -d "$SRC" ]; then
  [ -f "gdb-$VER.tar.xz" ] || curl -LO "https://ftp.gnu.org/gnu/gdb/gdb-$VER.tar.xz"
  tar xf "gdb-$VER.tar.xz"
  ( cd "$SRC" && patch -p1 < "$HERE/i8085-support.patch" )
fi

mkdir -p "$SRC/build-gdb"
cd "$SRC/build-gdb"
../configure --host=x86_64-w64-mingw32 --target=z80-unknown-elf \
  --enable-targets=all \
  --disable-binutils --disable-ld --disable-gas --disable-gprof --disable-sim \
  --with-expat --disable-werror --disable-nls
make -j"$(nproc)" all-gdb

echo
echo "Built: $(pwd)/gdb/.libs/gdb.exe"
echo "(the gdb/gdb.exe next to it is only a libtool wrapper)"
