#!/bin/bash
set -euo pipefail

# Hyprland v0.41.2 -- latest version compatible with Ubuntu 24.04 system libraries.
# Newer versions (v0.44+) require wayland-protocols >= 1.47, libinput >= 1.28,
# xkbcommon >= 1.11, which are not available on Ubuntu 24.04 / Mint 22.
HYPRLAND_VERSION="v0.41.2"

if command -v Hyprland &>/dev/null; then
    echo "Hyprland is already installed!"
    Hyprland --version
    exit 0
fi

echo "=== Installing Hyprland $HYPRLAND_VERSION ==="

# --- Build dependencies ---
echo "Installing build dependencies..."
sudo apt install -y \
    meson ninja-build cmake cmake-extras \
    gettext gettext-base fontconfig libfontconfig-dev libffi-dev \
    libxml2-dev libdrm-dev libxkbcommon-x11-dev libxkbregistry-dev \
    libxkbcommon-dev libpixman-1-dev libudev-dev libseat-dev seatd \
    libxcb-dri3-dev libvulkan-dev vulkan-utility-libraries-dev libvulkan1 \
    glslang-tools libinput-bin libinput-dev \
    libcairo2-dev libpango1.0-dev libgbm-dev \
    check hwdata libdisplay-info-dev libliftoff-dev \
    libtomlplusplus-dev libmagic-dev libzip-dev librsvg2-dev libpugixml-dev \
    xwayland libxcb-ewmh-dev libxcb-composite0-dev libxcb-icccm4-dev \
    libxcb-render0-dev libxcb-xfixes0-dev libxcb-res0-dev libxcb-util-dev \
    uuid-dev libxcursor-dev xcb-proto libxcb1-dev autoconf automake libtool \
    gcc-14 g++-14

CMAKE_OPTS="-DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=gcc-14 -DCMAKE_CXX_COMPILER=g++-14"

BUILD_DIR=$(mktemp -d)
trap 'rm -rf "$BUILD_DIR"' EXIT
cd "$BUILD_DIR"

# --- Build xcb-errors from source (not packaged in Ubuntu 24.04) ---
if ! pkg-config --exists xcb-errors 2>/dev/null; then
    echo "--- Building xcb-errors ---"
    git clone --depth 1 https://gitlab.freedesktop.org/xorg/lib/libxcb-errors.git
    cd libxcb-errors
    git submodule update --init
    ./autogen.sh --prefix=/usr
    make -j"$(nproc)"
    sudo make install
    sudo ldconfig
    cd "$BUILD_DIR"
fi

# --- Build and install Hyprland dependencies ---
# These versions are compatible with Hyprland v0.41.2 and compile with GCC 14.

build_dep() {
    local name=$1
    local repo=$2
    local tag=$3

    echo "--- Building $name $tag ---"
    git clone --depth 1 --branch "$tag" "https://github.com/hyprwm/$repo.git"
    cd "$repo"
    cmake -B build $CMAKE_OPTS
    cmake --build build -j"$(nproc)"
    sudo cmake --install build
    sudo ldconfig
    cd "$BUILD_DIR"
}

build_dep "hyprwayland-scanner" "hyprwayland-scanner" "v0.3.10"
build_dep "hyprutils"           "hyprutils"           "v0.1.5"
build_dep "hyprlang"            "hyprlang"            "v0.5.3"
build_dep "hyprcursor"          "hyprcursor"          "v0.1.9"

# --- Clone and build Hyprland ---
echo "--- Building Hyprland $HYPRLAND_VERSION ---"
git clone --recursive --branch "$HYPRLAND_VERSION" --depth 1 \
    "https://github.com/hyprwm/Hyprland.git"
cd Hyprland
cmake -B build $CMAKE_OPTS
cmake --build build -j"$(nproc)"
sudo cmake --install build

# --- Verify ---
sudo ldconfig
echo ""
echo "=== Hyprland installed successfully ==="
Hyprland --version
