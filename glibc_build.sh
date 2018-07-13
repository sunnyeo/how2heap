#!/bin/bash

SRC="./glibc_src"
BUILD="./glibc_build"
VERSION="./glibc_versions"

if [[ $# < 2 ]]; then
    echo "Usage: $0 version #make-threads <-disable-tcache>"
    exit 1
fi

# Get glibc source
if [ -d "$SRC" ]; then
    cd $SRC
    git pull --all
else
    git clone git://sourceware.org/git/glibc.git "$SRC"
    cd "$SRC"
    git pull --all
fi

# Checkout release
git rev-parse --verify --quiet "origin/release/$1/master"
if [[ $? != 0 ]]; then
    echo "Error: Glib version does not seem to exists"
    exit 1
fi

git checkout "origin/release/$1/master"
cd -

# Build
if [ $# == 3 ] && [ "$3" = "-disable-tcache" ]; then
    TCACHE_OPT="--disable-experimental-malloc"
    SUFFIX="-no-tcache"
else
    TCACHE_OPT=""
    SUFFIX=""
fi

mkdir -p "$BUILD"
cd "$BUILD" && rm -rf ./*
../"$SRC"/configure --prefix=/usr "$TCACHE_OPT"
make -j "$2"
cd -

# Copy to version folder
mkdir -p "$VERSION"
cp "$BUILD/libc.so" "$VERSION/libc-$1$SUFFIX.so"
cp "$BUILD/elf/ld.so" "$VERSION/ld-$1$SUFFIX.so"





