#!/usr/bin/env bash

set -e

# ==============================
#  Zero to Dev - Universal Setup
#  Works on WSL2 + Debian + Docker
# ==============================

# Detect if root
if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

# Progress bar function
progress() {
    local pid=$!
    local delay=0.1
    local spin='|/-\'
    while [ -d /proc/$pid ]; do
        for i in $(seq 0 3); do
            printf "\r[%c] $1" "${spin:$i:1}"
            sleep $delay
        done
    done
    printf "\r[✔] $1\n"
}

# Install a package if not installed
install_pkg() {
    if command -v "$1" >/dev/null 2>&1; then
        echo "[✔] $1 already installed, skipping."
    else
        echo "[...] Installing $1..."
        ($SUDO apt-get install -y "$1") & progress "Installing $1"
    fi
}

# Update apt
echo "[...] Updating package list..."
($SUDO apt-get update -y) & progress "Updating apt"

# Basic packages (remove cmake here, install separately with fast method)
BASIC_PKGS=(git zsh build-essential pkg-config redis fzf neovim curl wget unzip zip tar)
for pkg in "${BASIC_PKGS[@]}"; do
    install_pkg "$pkg"
done

# Fast CMake install
install_cmake_fast() {
    if command -v cmake >/dev/null 2>&1; then
        echo "[✔] cmake already installed, skipping."
        return
    fi

    echo "[...] Installing cmake (fast method)..."
    CMAKE_VERSION=3.30.2
    # 检测是否能访问 npmmirror
    if curl -s --head https://npmmirror.com/mirrors/cmake/ | grep "200 OK" >/dev/null; then
        echo "[...] Using npmmirror for cmake..."
        wget https://npmmirror.com/mirrors/cmake/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-linux-x86_64.tar.gz
    else
        echo "[...] npmmirror not reachable, using GitHub..."
        wget https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-linux-x86_64.tar.gz
    fi
    tar -zxvf cmake-$CMAKE_VERSION-linux-x86_64.tar.gz
    $SUDO mv cmake-$CMAKE_VERSION-linux-x86_64 /opt/cmake
    $SUDO ln -sf /opt/cmake/bin/* /usr/local/bin/
    rm cmake-$CMAKE_VERSION-linux-x86_64.tar.gz
}
install_cmake_fast

# Install fastfetch
install_pkg fastfetch

# Add fastfetch to zshrc if not already present
if ! grep -q "fastfetch" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "# Show system info on shell start" >> ~/.zshrc
    echo "fastfetch" >> ~/.zshrc
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "[...] Installing Oh My Zsh..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" & progress "Installing Oh My Zsh"
else
    echo "[✔] Oh My Zsh already installed."
fi

# Install zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    echo "[...] Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions & progress "Installing zsh-autosuggestions"
fi

# Install zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    echo "[...] Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting & progress "Installing zsh-syntax-highlighting"
fi

# Enable plugins in .zshrc
if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
fi

# Install NVM + Node + global packages (with Taobao mirror for speed)
if [ ! -d "$HOME/.nvm" ]; then
    echo "[...] Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
else
    echo "[✔] NVM already installed."
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

# Use Taobao mirror for Node.js to speed up installation
export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node
echo "[...] Installing latest Node.js..."
nvm install node
nvm use node
npm install -g nrm pnpm yarn @antfu/ni

# Install pyenv
if [ ! -d "$HOME/.pyenv" ]; then
    echo "[...] Installing pyenv..."
    curl https://pyenv.run | bash
else
    echo "[✔] pyenv already installed."
fi

# Install Go
if ! command -v go >/dev/null 2>&1; then
    echo "[...] Installing Go..."
    GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n 1)
    wget https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz
    $SUDO rm -rf /usr/local/go
    $SUDO tar -C /usr/local -xzf ${GO_VERSION}.linux-amd64.tar.gz
    rm ${GO_VERSION}.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc
else
    echo "[✔] Go already installed."
fi

# Change default shell to zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "[...] Changing default shell to zsh..."
    chsh -s "$(which zsh)"
fi

echo "✅ All set! Please restart your terminal."

