#!/bin/bash
# Provisioning/Init Script
set -e


echo "Initializing your environment"

BASE_DIR="$HOME/repos/starter.nvim"
CONFIG_DIR="$HOME/.config"

# 1. Debian Specific Installation
if [ -f /etc/debian_version ]; then
    echo "Detected Debian/Ubuntu base..."
    sudo apt update 
    sudo apt install -y curl
    # Add NodeSource for latest Node.js
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    # ONLY add Debian Backports if the OS is strictly Debian
    if grep -q 'ID=debian' /etc/os-release; then
        echo "Strict Debian detected, adding backports..."
        echo "deb http://deb.debian.org/debian bookworm-backports main" | sudo tee /etc/apt/sources.list.d/backports.list
    fi
    sudo apt update
    # Install packages
    sudo apt install -y make gcc g++ ripgrep fd-find unzip git xclip curl nodejs python3-full python3-pip dnsutils procps jq tmux htop wget tar
fi

# 2. RHEL Specific Instillation
if [ -f /etc/fedora-release ] || [ -f /etc/redhat-release ]; then
    echo "Detected RHEL/Fedora base..."
    sudo dnf update -y
    sudo dnf install -y curl
    # Add NodeSource for latest Node.js
    curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo -E bash -
    # Install packages 
    sudo dnf install -y make gcc gcc-c++ ripgrep fd-find unzip git xclip curl nodejs python3 python3-pip bind-utils procps-ng jq tmux htop wget tar
fi

# 3. Arch Specific Instillation
if [ -f /etc/arch-release ]; then
    # Update OS
    sudo pacman -Syu --noconfirm
    # Install basic packages
    sudo pacman -S --noconfirm make gcc ripgrep fd unzip git xclip curl nodejs npm python python-pip bind procps-ng jq tmux htop wget tar
fi

# 4. NEOVIM Latest (Manual install to /opt)
echo "Installing Neovim..."
curl -L https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz -o /tmp/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf /tmp/nvim-linux-x86_64.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
rm -rf /tmp/nvim-linux-x86_64.tar.gz

# 5. NPM Install
echo "Installing Tree-Sitter..."
sudo npm install -g tree-sitter-cli@0.22.6


# 6. Symlinks for config files (With Safety Backups)
echo "Linking dotfiles..."
mkdir -p "$CONFIG_DIR"
mkdir -p "$HOME/backups"

if [ -f "$HOME/.bashrc" ] && [ ! -L "$HOME/.bashrc" ]; then
    mv "$HOME/.bashrc" "$HOME/backups/.bashrc.bak"
    echo "Backed up original .bashrc to $HOME/backups/.bashrc.bak"
fi
if [ -f "$HOME/.gitconfig" ] && [ ! -L "$HOME/.gitconfig" ]; then
    mv "$HOME/.gitconfig" "$HOME/backups/.gitconfig.bak"
    echo "Backed up original .gitconfig to $HOME/backups/.gitconfig.bak"
fi
if [ -d "$CONFIG_DIR/nvim" ] && [ ! -L "$CONFIG_DIR/nvim" ]; then
    mv "$CONFIG_DIR/nvim" "$HOME/backups/nvim.bak"
    echo "Backed up original nvim directory into /backups/nvim.bak"
fi

ln -sf "$BASE_DIR/.bashrc" "$HOME/.bashrc"
ln -sf "$BASE_DIR/.gitconfig" "$HOME/.gitconfig"
ln -sfn "$BASE_DIR" "$CONFIG_DIR/nvim"

# 7. Creates ssh key if they do not exist
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-keygen -t ed25519 -N "" -f "$HOME/.ssh/id_ed25519"
    echo "New SSH key generated. Add this to GitHub!"
fi

echo "Environment Successfully Initialized! Run 'source ~/.bashrc' nerd"
