#!/bin/bash
set -euo pipefail

if command -v Hyprland &>/dev/null; then
    echo "Hyprland is already installed!"
    Hyprland --version
    exit 0
fi

echo "=== Installing Hyprland ==="

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
# Using recursive clone so Hyprland builds its own compatible versions
# of hyprutils, hyprlang, hyprcursor, etc. as submodules.
# This avoids version mismatches between HEAD of each repo.
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

# --- Build with GCC 14 (C++23 support) ---
echo "--- Building Hyprland ---"
cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=gcc-14 -DCMAKE_CXX_COMPILER=g++-14
cmake --build build -j"$(nproc)"
sudo cmake --install build
cd "$BUILD_DIR"

# --- Install xdg-desktop-portal-hyprland ---
echo "--- Building xdg-desktop-portal-hyprland ---"
if git clone --depth 1 "https://github.com/hyprwm/xdg-desktop-portal-hyprland.git" 2>/dev/null; then
    cd xdg-desktop-portal-hyprland
    cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER=gcc-14 -DCMAKE_CXX_COMPILER=g++-14
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
