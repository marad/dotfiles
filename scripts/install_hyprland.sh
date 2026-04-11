#!/bin/bash
set -euo pipefail

if command -v Hyprland &>/dev/null; then
    echo "Hyprland is already installed!"
    Hyprland --version
    exit 0
fi

echo "=== Installing Hyprland ==="

# --- CMake 3.30+ (required by Hyprland, Ubuntu 24.04 ships 3.28) ---
CMAKE_VERSION=$(cmake --version 2>/dev/null | head -1 | grep -oP '\d+\.\d+' | head -1)
if [ "$(echo "$CMAKE_VERSION < 3.30" | bc)" -eq 1 ] 2>/dev/null || [ -z "$CMAKE_VERSION" ]; then
    echo "Installing CMake 3.30+ from Kitware APT repo..."
    sudo apt install -y ca-certificates gpg wget
    wget -qO - https://apt.kitware.com/keys/kitware-archive-latest.asc | \
        gpg --dearmor | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ noble main" | \
        sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null
    sudo apt update
    sudo apt install -y cmake
    echo "CMake version: $(cmake --version | head -1)"
fi

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
    xwayland \
    gcc-14 g++-14

BUILD_DIR=$(mktemp -d)
trap 'rm -rf "$BUILD_DIR"' EXIT
cd "$BUILD_DIR"

# --- Clone Hyprland with bundled dependencies ---
# Recursive clone gets compatible versions of all deps as submodules.
# We then build and install each submodule before building Hyprland,
# since Hyprland's CMake expects them as system-installed libraries.
echo "--- Cloning Hyprland (with submodules) ---"
git clone --recursive https://github.com/hyprwm/Hyprland.git
cd Hyprland

# Use latest stable release tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || git tag -l 'v*' --sort=-v:refname | head -1)
if [ -n "$LATEST_TAG" ]; then
    echo "Checking out latest release: $LATEST_TAG"
    git checkout "$LATEST_TAG"
    git submodule update --init --recursive
fi

HYPRLAND_DIR="$PWD"
CMAKE_OPTS="-DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=gcc-14 -DCMAKE_CXX_COMPILER=g++-14"

# --- Build and install submodule dependencies in order ---
build_submodule() {
    local dir=$1
    local name=$(basename "$dir")
    echo "--- Building $name ---"
    cd "$dir"
    cmake -B build $CMAKE_OPTS
    cmake --build build -j"$(nproc)"
    sudo cmake --install build
    sudo ldconfig
    cd "$HYPRLAND_DIR"
}

build_submodule subprojects/hyprwayland-scanner
build_submodule subprojects/hyprutils
build_submodule subprojects/hyprlang
build_submodule subprojects/hyprland-protocols
build_submodule subprojects/hyprcursor
build_submodule subprojects/aquamarine

# --- Build Hyprland itself ---
echo "--- Building Hyprland ---"
cmake -B build $CMAKE_OPTS
cmake --build build -j"$(nproc)"
sudo cmake --install build
cd "$BUILD_DIR"

# --- Install xdg-desktop-portal-hyprland ---
echo "--- Building xdg-desktop-portal-hyprland ---"
if git clone --depth 1 "https://github.com/hyprwm/xdg-desktop-portal-hyprland.git" 2>/dev/null; then
    cd xdg-desktop-portal-hyprland
    cmake -B build $CMAKE_OPTS
    cmake --build build -j"$(nproc)"
    sudo cmake --install build
    cd "$BUILD_DIR"
else
    echo "Warning: could not clone xdg-desktop-portal-hyprland, screen sharing may not work"
fi

# --- Verify ---
sudo ldconfig
echo ""
echo "=== Hyprland installed successfully ==="
Hyprland --version
