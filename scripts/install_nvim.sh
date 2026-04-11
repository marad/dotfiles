#!/bin/bash

if [ -d "/opt/nvim-linux-x86_64" ]; then
    echo "Neovim is already installed!"
    exit 0
fi

curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
rm nvim-linux-x86_64.tar.gz
