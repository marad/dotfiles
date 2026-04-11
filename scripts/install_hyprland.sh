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
    libtomlplusplus-dev libmagic-dev libzip-dev librsvg2-dev \
    xwayland

BUILD_DIR=$(mktemp -d)
trap 'rm -rf "$BUILD_DIR"' EXIT
cd "$BUILD_DIR"

# Helper function to build a CMake project
build_cmake() {
    local name=$1
    local repo=$2
    local tag=${3:-""}

    echo "--- Building $name ---"
    if [ -n "$tag" ]; then
        git clone --depth 1 --branch "$tag" "https://github.com/hyprwm/$repo.git"
    else
        git clone --depth 1 "https://github.com/hyprwm/$repo.git"
    fi
    cd "$repo"
    cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
    cmake --build build -j"$(nproc)"
    sudo cmake --install build
    cd "$BUILD_DIR"
}

# Helper function to build a Meson project
build_meson() {
    local name=$1
    local repo=$2

    echo "--- Building $name ---"
    git clone --depth 1 "https://github.com/hyprwm/$repo.git"
    cd "$repo"
    meson setup build --prefix=/usr --buildtype=release
    ninja -C build
    sudo ninja -C build install
    cd "$BUILD_DIR"
}

# --- Build dependency chain in order ---
build_cmake "hyprwayland-scanner" "hyprwayland-scanner"
build_cmake "hyprutils" "hyprutils"
build_cmake "hyprlang" "hyprlang"
build_cmake "hyprcursor" "hyprcursor"
build_cmake "hyprland-protocols" "hyprland-protocols"
build_cmake "aquamarine" "aquamarine"

# --- Build Hyprland ---
echo "--- Building Hyprland ---"
git clone --depth 1 "https://github.com/hyprwm/Hyprland.git"
cd Hyprland
cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
cmake --build build -j"$(nproc)"
sudo cmake --install build
cd "$BUILD_DIR"

# --- Install xdg-desktop-portal-hyprland if available ---
echo "--- Building xdg-desktop-portal-hyprland ---"
if git clone --depth 1 "https://github.com/hyprwm/xdg-desktop-portal-hyprland.git" 2>/dev/null; then
    cd xdg-desktop-portal-hyprland
    cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
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
