#!/usr/bin/env bash

cecho() {
    printf "\033[1;36m%s\033[0m\n" "$*"
}

DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

TARGET="x86_64-elf"
PREFIX="$DIR/toolchain/$TARGET"
BUILD="$DIR/../build/toolchain-$TARGET"

echo "TARGET=$TARGET"
echo "PREFIX=$PREFIX"
echo "BUILD=$BUILD"

BINUTILS="binutils-2.40" # released 2023-01-16
BINUTILS_TGZ="$BINUTILS.tar.gz"
BINUTILS_URL="https://ftp.gnu.org/gnu/binutils/$BINUTILS_TGZ"

GCC="gcc-12.2.0" # released 2022-08-19
GCC_TGZ="$GCC.tar.gz"
GCC_URL="https://ftp.gnu.org/gnu/gcc/$GCC/$GCC_TGZ"

mkdir -p "$BUILD"

if [ ! -e "$BUILD/$BINUTILS_TGZ" ]; then
    cecho "Getting $BINUTILS_URL"
    curl -# -o "$BUILD/$BINUTILS_TGZ" "$BINUTILS_URL"
fi
if [ ! -e "$BUILD/$GCC_TGZ" ]; then
    cecho "Getting $GCC_URL"
    curl -# -o "$BUILD/$GCC_TGZ" "$GCC_URL"
fi

rm -rf "$BUILD/$BINUTILS" "$BUILD/$GCC"

cecho "Extracting $BINUTILS_TGZ"
tar -xzf "$BUILD/$BINUTILS_TGZ" -C "$BUILD"
cecho "Extracting $GCC_TGZ"
tar -xzf "$BUILD/$GCC_TGZ" -C "$BUILD"

cecho "Patching $GCC"
patch -p1 -d "$BUILD/$GCC" < "$DIR/patches/gcc-12.2.0.patch"

rm -rf "$PREFIX"
mkdir -p "$PREFIX"

MAKEJOBS=$(nproc)

rm -rf "$BUILD/build-binutils"
mkdir -p "$BUILD/build-binutils"

pushd "$BUILD/build-binutils"
cecho "Configuring binutils"
"$BUILD/$BINUTILS/configure" --target="$TARGET" --prefix="$PREFIX" --disable-nls --with-sysroot || exit 1
cecho "Building binutils"
make -j "$MAKEJOBS" || exit 1
cecho "Installing binutils"
make -j "$MAKEJOBS" install || exit 1
popd # $BUILD/build-binutils

rm -rf "$BUILD/build-gcc"
mkdir -p "$BUILD/build-gcc"

pushd "$BUILD/build-gcc"
cecho "Configuring gcc"
"$BUILD/$GCC/configure" --target="$TARGET" --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers || exit 1
cecho "Building gcc"
make -j "$MAKEJOBS" all-gcc || exit 1
cecho "Installing gcc"
make -j "$MAKEJOBS" install-gcc || exit 1
cecho "Building libgcc"
make -j "$MAKEJOBS" all-target-libgcc || exit 1
cecho "Installing libgcc"
make -j "$MAKEJOBS" install-target-libgcc || exit 1
popd # $BUILD/build-gcc

cecho "Done - installed to $PREFIX"
