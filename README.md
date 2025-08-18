# 🚀 zero-to-dev

One-click shell script to bootstrap your Debian / WSL2 dev environment in minutes.

## 📦 Features

- Install Git, Zsh + Oh My Zsh (with zsh-autosuggestions & zsh-syntax-highlighting)
- Install NVM + latest Node.js + global packages (nrm, pnpm, yarn, @antfu/ni)
- Install build-essential, cmake, pkg-config, redis, fzf, neovim, curl, wget, unzip, zip, tar
- Install fastfetch (system info display), man-db & manpages (manual pages)
- Install pyenv, Go
- Auto-skip installed tools
- Progress bar during install
- Works on Debian, Ubuntu, WSL2

## 🛠 Requirements

- Debian-based system
- bash shell
- Internet connection

## 📥 Installation

```bash
git clone https://github.com/cerebralatlas/zero-to-dev.git
cd zero-to-dev
chmod +x install.sh
./install.sh
```

## 📂 Installed Tools

| Tool                               | Purpose              |
| ---------------------------------- | -------------------- |
| git                                | Version control      |
| zsh + Oh My Zsh                    | Modern shell         |
| zsh-autosuggestions                | Command suggestions  |
| zsh-syntax-highlighting            | Syntax highlighting  |
| nvm                                | Node.js manager      |
| nrm                                | npm registry manager |
| pnpm, yarn, @antfu/ni              | Package managers     |
| build-essential, cmake, pkg-config | Compilation          |
| redis                              | In-memory DB         |
| fzf                                | Fuzzy finder         |
| neovim                             | Vim-based editor     |
| fastfetch                          | System info display  |
| man-db, manpages                   | Manual pages         |
| curl, wget                         | Download             |
| unzip, zip, tar                    | Archives             |
| pyenv                              | Python manager       |
| golang                             | Go language          |
