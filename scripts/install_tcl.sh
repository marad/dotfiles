#!/bin/bash
set -euo pipefail

# Tcl/Tk 9 is not packaged on Ubuntu 24.04 / Mint 22 (apt has 8.6) nor in the
# Arch repos (8.6), so build the upstream release. macOS gets both from
# Homebrew's tcl-tk formula instead. X11 headers for the Tk build come from the
# package lists in the playbooks.
TCL_VERSION="9.0.4"
SERIES="${TCL_VERSION%.*}"

BUILD_DIR="$(mktemp -d)"
trap 'rm -rf "$BUILD_DIR"' EXIT

# $1 = source tarball prefix (tcl/tk), $2 = installed binary, rest = configure args
install_component() {
    local name="$1" binary="$2"
    shift 2

    if [ -x "/usr/local/bin/$binary$SERIES" ]; then
        echo "$binary$SERIES is already installed!"
        return
    fi

    echo "=== Installing $name $TCL_VERSION ==="
    curl -fsSL "https://downloads.sourceforge.net/project/tcl/Tcl/$TCL_VERSION/$name$TCL_VERSION-src.tar.gz" \
        | tar xz -C "$BUILD_DIR"
    cd "$BUILD_DIR/$name$TCL_VERSION/unix"
    ./configure --prefix=/usr/local "$@"
    # zipfs and the bundled packages (sqlite, tdbc, thread) are built by the
    # freshly built binary, which links its shared library from this directory.
    LD_LIBRARY_PATH="$PWD" make -j"$(nproc)"
    sudo make install

    # Same as Homebrew's tcl-tk: make `tclsh`/`wish` the freshly built ones.
    # The distro 8.6, if installed, stays in /usr/bin for packaged scripts.
    sudo ln -sf "$binary$SERIES" "/usr/local/bin/$binary"
}

install_component tcl tclsh
install_component tk wish --with-tcl=/usr/local/lib
