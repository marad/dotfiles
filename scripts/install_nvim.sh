#!/bin/bash

if [ -d "/opt/nvim-linux64" ]; then
    echo "Neovim is already installed!"
    exit 0
fi

curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim-linux64
sudo tar -C /opt -xzf nvim-linux64.tar.gz
rm nvim-linux64.tar.gz
