# Dotfiles

This document covers setting up a modern, resilient development environment on macOS.

## Design Principles

1. **Minimize cascade failures**: Shell should work without Python. nvim should edit files without plugins. Each layer degrades gracefully.
2. **Survive OS upgrades**: Prefer tools that install to `~/.local` (mise) over system package managers (MacPorts) for critical path tools.
3. **Understand what you have**: Handcrafted configs over frameworks.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│ Layer 1: Always Works (survives OS upgrades)                    │
│   - System zsh (/bin/zsh)                                       │
│   - System git (Xcode CLI tools)                                │
│   - ~/dotfiles/ (version controlled, GitHub backup)             │
│   - ~/.zshrc (symlink to dotfiles)                              │
└─────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│ Layer 2: mise-managed tools (~/.local/share/mise/)              │
│   - Survives OS upgrades (prebuilt binaries in home dir)        │
│   - node, python, uv, neovim, starship, fzf, tree-sitter, stow   │
└─────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│ Layer 3: MacPorts (/opt/local/)                                 │
│   - Will need rebuild after OS upgrades                         │
│   - rg, fd, jq, and other CLI conveniences                      │
│   - NOT on critical path - shell/nvim work without these        │
└─────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│ Layer 4: Language-specific tooling                              │
│   - LSP servers (via mise's npm: prefix)                        │
│   - Python venvs (via uv, using mise's python)                  │
│   - Survives OS upgrades because mise survives                  │
└─────────────────────────────────────────────────────────────────┘
```

## Order of Operations

Starting from scratch. Each step should leave you with a working system.

### Phase 1: Bootstrap mise (before touching anything else)

mise installs to ~/.local and downloads prebuilt binaries. If MacPorts breaks
later, key tools like python and nvim still work.

```zsh
# Install mise (one-liner from mise docs, or via MacPorts initially)
curl https://mise.run | sh

# Add to current shell (temporary, before .zshrc changes)
eval "$(~/.local/bin/mise activate zsh)"
```

Then install global tools via `mise use -g`.
Manifest in [the mise config.toml](./mise/.config/mise/config.toml).

### Phase 2: Shell configuration

Back up your existing config, then create a new minimal one.

```zsh
# Backup
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d)

# Install zsh plugins via git (not dependent on any package manager)
mkdir -p ~/.zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting
```

To update these plugins later:
```zsh
# cd ~/.zsh/zsh-autosuggestions && git pull
# cd ~/.zsh/zsh-syntax-highlighting && git pull
```

Create new `~/.zshrc` based on [the zshrc in this repo](./zsh/.zshrc).

Create new `~/.config/starship.toml` based on [the starship.toml in this
repo](./starship/.config/starship.toml):

Test the shell:

```zsh
source ~/.zshrc
# Verify: prompt works, completions work, fzf Ctrl-R works
```

### Phase 3: nvim configuration

Back up existing config:

```zsh
# Backup
cp -r ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d)
cp ~/.vimrc ~/.vimrc.backup.$(date +%Y%m%d) 2>/dev/null || true
```

Update your existing config. If using vim-plug, ensure it's installed:

```zsh
# vim-plug installation (if not present)
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```

Create new `~/.config/nvim/init.lua` based on [the init.lua in this repo](./nvim/.config/nvim/init.lua).

Install plugins and LSP servers:

Install vim plugins
```zsh
nvim +PlugInstall +qall
```

Install treesitter parsers (run inside nvim, requires tree-sitter CLI)
```zsh
# :TSInstall javascript typescript tsx python lua vim vimdoc json yaml toml markdown html css bash
```
Check status with `:checkhealth nvim-treesitter`. LSP servers such as `npm:typescript-language-server` should already be installed via mise.

Test nvim:

```zsh
nvim some-file.ts
# Verify: syntax highlighting, completion popup, go-to-definition
```

### Phase 4: MacPorts (optional conveniences)

Nice-to-have but not critical. If MacPorts breaks after an OS upgrade, shell and
nvim still work.

```zsh
# If MacPorts needs reinstalling after OS upgrade:
# Download from https://www.macports.org/install.php

sudo port selfupdate

# CLI tools
sudo port install ripgrep fd jq bat eza git-delta
```

### Phase 5: Dotfile Management with Stow

Once your config is working, set up version-controlled dotfiles using GNU Stow.
(Stow was already installed in Phase 1 via mise.)

#### How stow works

Stow creates symlinks by mirroring directory structure. When you run `stow <package>`
from `~/dotfiles`, it creates symlinks in `~/` matching the paths inside the package:

```
~/dotfiles/zsh/.zshrc           →  symlink at ~/.zshrc
~/dotfiles/nvim/.config/nvim/   →  symlink at ~/.config/nvim/
```

#### Initial setup

```zsh
# Create dotfiles repo
mkdir ~/dotfiles && cd ~/dotfiles
git init

# Create package directories and move existing configs
mkdir -p zsh
mv ~/.zshrc zsh/.zshrc

mkdir -p nvim/.config
mv ~/.config/nvim nvim/.config/

mkdir -p starship/.config
mv ~/.config/starship.toml starship/.config/

mkdir -p git/.config/git
# Git supports XDG location natively
mv ~/.gitconfig git/.config/git/config 2>/dev/null || true

# Create symlinks back to original locations
stow zsh
stow nvim
stow starship
stow git

# Verify
ls -la ~/.zshrc              # should show -> ~/dotfiles/zsh/.zshrc
ls -la ~/.config/nvim        # should show -> ~/dotfiles/nvim/.config/nvim
```

#### Resulting structure

```
~/dotfiles/
├── .git/
├── zsh/
│   └── .zshrc
├── nvim/
│   └── .config/
│       └── nvim/
│           └── init.lua
├── starship/
│   └── .config/
│       └── starship.toml
├── git/
│   └── .config/
│       └── git/
│           └── config
└── install.sh               # optional automation script
```

#### Ignore files

Create `.stow-local-ignore` in each package to exclude files from symlinking:

```
# ~/dotfiles/nvim/.stow-local-ignore

# Stow/git metadata
\.git
\.gitignore
\.stow-local-ignore

# Generated files (don't belong in repo)
\.DS_Store
plugged/.*
undo/.*
```

Note: `.stow-local-ignore` uses Perl regex syntax (hence `\.` to match literal
dots). When this file exists, it overrides stow's defaults, so include the
patterns above to maintain expected behavior.

#### Push to GitHub

```zsh
cd ~/dotfiles
git add -A
git commit -m "Initial dotfiles"
git remote add origin git@github.com:YOU/dotfiles.git
git push -u origin main
```

#### Restoring on a new machine

```zsh
# Clone dotfiles
git clone git@github.com:YOU/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Install stow (may need mise first, or use system package manager)
mise use -g stow   # or: brew install stow / sudo port install stow

# Handle conflicts with existing files
# Option A: Remove/backup existing files first
mv ~/.zshrc ~/.zshrc.original

# Option B: Use --adopt to pull existing files into repo
stow --adopt zsh   # moves ~/.zshrc into ~/dotfiles/zsh/, creates symlink
git diff           # review what was adopted

# Stow all packages
stow zsh nvim starship git

# Install ripgrep, jq, etc. with MacPorts
```

When upgrading macOS

### Before upgrade

```zsh
# Document what you have (mise config.toml is the source of truth, but good to verify)
mise list > ~/mise-tools-backup.txt
port installed > ~/macports-installed-backup.txt

# Ensure dotfiles are committed/backed up
cd ~/dotfiles && git status
```

### After upgrade

```zsh
# 1. Open Terminal - zsh should work (system binary)

# 2. Verify mise still works (it should - lives in ~/.local)
~/.local/bin/mise doctor

# 3. Source your config
source ~/.zshrc

# 4. Verify mise-managed tools work
which node && node --version
which nvim && nvim --version
which python && python --version

# 5. If anything is broken in mise:
mise install  # reinstalls from ~/.config/mise/config.toml

# 6. Rebuild MacPorts (this is the slow/painful part, but non-critical)
# Download new MacPorts installer from macports.org
# Then:
sudo port selfupdate
sudo port upgrade outdated
# Or reinstall from your backup list

# 7. Reinstall Xcode CLI tools if needed
xcode-select --install
```

## Troubleshooting

**mise command not found after OS upgrade**:

```zsh
# mise binary should still exist
ls -la ~/.local/bin/mise
# Add to PATH manually if needed
export PATH="$HOME/.local/bin:$PATH"
```

**LSP not working**:

```zsh
# Check if LSP servers are installed and in PATH
which typescript-language-server
which pyright
which ruff

# Check LSP status in nvim (open a file of the relevant type first)
:checkhealth lsp
```

**Treesitter highlighting broken**:

```zsh
# Treesitter parsers require the tree-sitter CLI to compile
which tree-sitter   # if missing: mise use -g tree-sitter

# Check parser status in nvim
:checkhealth nvim-treesitter

# Reinstall parsers
:TSInstall javascript typescript tsx python lua vim vimdoc json yaml toml markdown html css bash
```

**MacPorts completely broken after OS upgrade**:

```zsh
# Shell and nvim should still work via mise
# Reinstall MacPorts from https://www.macports.org/install.php
# Then: sudo port selfupdate && sudo port install <packages>
```
