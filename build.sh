#!/usr/bin/env bash
# Build gdb-i8085 from GNU gdb 16.3 + the i8085 support patch.
# Native build on Linux/macOS; on Windows run under MSYS2/MinGW and set
# GDB_HOST=x86_64-w64-mingw32.  Requires gmp, mpfr and expat (dev packages).
set -e

VER=16.3
HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="$HERE/gdb-$VER"

if [ ! -d "$SRC" ]; then
  [ -f "$HERE/gdb-$VER.tar.xz" ] || \
    curl -L -o "$HERE/gdb-$VER.tar.xz" "https://ftp.gnu.org/gnu/gdb/gdb-$VER.tar.xz"
  tar xf "$HERE/gdb-$VER.tar.xz" -C "$HERE"
  ( cd "$SRC" && patch -p1 < "$HERE/i8085-support.patch" )
fi

mkdir -p "$SRC/build"
cd "$SRC/build"

CONFIG_HOST=""
[ -n "$GDB_HOST" ] && CONFIG_HOST="--host=$GDB_HOST"

# z80 target only (i8085 is a z80 bfd mach) -> much smaller, static-friendly.
# Static/link flags come from the environment (LDFLAGS) set by the caller.
../configure $CONFIG_HOST --target=z80-unknown-elf \
  --disable-binutils --disable-ld --disable-gas --disable-gprof --disable-sim \
  --with-expat --without-python --disable-nls --disable-werror \
  $EXTRA_CONFIGURE

JOBS="$( (nproc 2>/dev/null) || (sysctl -n hw.ncpu 2>/dev/null) || echo 4 )"
make -j"$JOBS" all-gdb

# The real binary (native builds may put it directly at gdb/gdb, libtool builds
# under gdb/.libs/); print whichever exists.
if [ -x "$SRC/build/gdb/.libs/gdb" ] || [ -x "$SRC/build/gdb/.libs/gdb.exe" ]; then
  echo "built: $SRC/build/gdb/.libs/gdb*"
else
  echo "built: $SRC/build/gdb/gdb*"
fi
