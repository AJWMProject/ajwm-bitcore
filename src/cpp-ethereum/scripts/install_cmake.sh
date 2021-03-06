#!/usr/bin/env sh

# This script downloads the CMake binary and installs it in $PREFIX directory
# (the cmake executable will be in $PREFIX/bin). By default $PREFIX is
# ~/.local but can we changes with --prefix <PREFIX> argument.

# This is mostly suitable for CIs, not end users.

set -e

VERSION=3.7.1

if [ "$1" = "--prefix" ]; then
    PREFIX="$2"
else
    PREFIX=~/.local
fi

OS=$(uname -s)
case $OS in
Linux)  SHA256=7b4b7a1d9f314f45722899c0521c261e4bfab4a6b532609e37fef391da6bade2;;
Darwin) SHA256=1851d1448964893ajwm5a8c05863326119f397a3790e0c84c40b83499c7960267;;
esac


BIN=$PREFIX/bin

if test -f $BIN/cmake && ($BIN/cmake --version | grep -q "$VERSION"); then
    echo "CMake $VERSION already installed in $BIN"
else
    FILE=cmake-$VERSION-$OS-x86_64.tar.gz
    URL=https://cmake.org/files/v3.7/$FILE
    ERROR=0
    TMPFILE=$(mktemp --tmpdir cmake-$VERSION-$OS-x86_64.XXXXXXXX.tar.gz)
    echo "Downloading CMake ($URL)..."
    curl -s "$URL" > "$TMPFILE"

    if type -p sha256sum > /dev/null; then
        SHASUM="sha256sum"
    else
        SHASUM="shasum -a256"
    fi

    if ! ($SHASUM "$TMPFILE" | grep -q "$SHA256"); then
        echo "Checksum mismatch ($TMPFILE)"
        exit 1
    fi
    mkdir -p "$PREFIX"
    tar xzf "$TMPFILE" -C "$PREFIX" --strip 1
    rm $TMPFILE
fi
