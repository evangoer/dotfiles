# Development Environment Setup Guide

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

Do these in order. Each step should leave you with a working system.

### Phase 1: Bootstrap mise (before touching anything else)

mise installs to ~/.local and downloads prebuilt binaries. This is your
resilient foundation.

```zsh
# Install mise (one-liner from mise docs, or via MacPorts initially)
curl https://mise.run | sh

# Add to current shell (temporary, before .zshrc changes)
eval "$(~/.local/bin/mise activate zsh)"

# Install critical tools via mise
mise use -g node@lts          # LTS node
mise use -g python@3.12       # Python
mise use -g uv                # Python package/venv manager
mise use -g neovim@stable     # nvim (not dependent on MacPorts)
mise use -g starship          # Prompt
mise use -g fzf               # Fuzzy finder
mise use -g tree-sitter       # Needed by nvim-treesitter to compile parsers
TODO mise use -g stow              # Dotfile management

# Verify
which node     # should be ~/.local/share/mise/installs/...
which nvim     # should be ~/.local/share/mise/installs/...
```

**Why this first**: If MacPorts breaks later, you still have node, python,
and nvim via mise.

### Phase 2: Shell configuration

Back up your existing config, then create a new minimal one.

```zsh
# Backup
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d)

# Install zsh plugins via git (not dependent on any package manager)
mkdir -p ~/.zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting

# To update these plugins later:
# cd ~/.zsh/zsh-autosuggestions && git pull
# cd ~/.zsh/zsh-syntax-highlighting && git pull
```

Create new `~/.zshrc`:

```zsh
# ~/.zshrc - Minimal, resilient shell configuration

#=============================================================================
# SECTION 1: Always works (no external dependencies)
#=============================================================================

# History
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks

# Basic options
setopt auto_cd
setopt interactive_comments

# Completions (built into zsh)
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Key bindings
bindkey -e  # emacs mode (or -v for vim)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

#=============================================================================
# SECTION 2: mise-managed tools (resilient - survives OS upgrades)
#=============================================================================

# mise activation (provides node, python, nvim, starship, fzf, uv)
if [[ -f ~/.local/bin/mise ]]; then
  eval "$(~/.local/bin/mise activate zsh)"
fi

# Starship prompt (installed via mise)
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# fzf integration (installed via mise)
if command -v fzf &> /dev/null; then
  eval "$(fzf --zsh)"
fi

#=============================================================================
# SECTION 3: Optional enhancements (may break after OS upgrade, non-critical)
#=============================================================================

# MacPorts (rebuild after OS upgrades with: sudo port selfupdate && sudo port upgrade outdated)
if [[ -d /opt/local/bin ]]; then
  export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
fi

# zsh plugins (cloned to ~/.zsh/, no package manager dependency)
[[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#=============================================================================
# SECTION 4: Local customizations
#=============================================================================

# Machine-specific config (not checked into dotfiles)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
```

Create `~/.config/starship.toml` (customize as desired):

```toml
# ~/.config/starship.toml

# Minimal prompt - customize from here
format = """
$directory$git_branch$git_status$python$nodejs$character"""

[character]
success_symbol = "[❯](green)"
error_symbol = "[❯](red)"

[directory]
truncation_length = 3
truncate_to_repo = true

[git_branch]
format = "[$branch]($style) "
style = "purple"

[git_status]
format = '([$all_status$ahead_behind]($style) )'
style = "red"

[python]
format = '[${pyenv_prefix}(${version})(\($virtualenv\))]($style) '
style = "yellow"

[nodejs]
format = "[$version]($style) "
style = "green"
```

**Test the shell**:

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

Recommended `~/.config/nvim/init.lua` structure:

```lua
-- ~/.config/nvim/init.lua
--
-- Structure:
--   1. Core settings (no plugins, always works)
--   2. Plugin declarations
--   3. Plugin configuration

--=============================================================================
-- SECTION 1: Core settings (works even if plugins fail)
--=============================================================================

vim.g.mapleader = ' '

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.hidden = true
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand('~/.local/share/nvim/undo')
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 300
vim.opt.termguicolors = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'

-- Basic keymaps that don't depend on plugins
vim.keymap.set('n', '<leader>w', '<cmd>w<CR>')
vim.keymap.set('n', '<leader>q', '<cmd>q<CR>')
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

--=============================================================================
-- SECTION 2: Plugins (vim-plug)
--=============================================================================

local Plug = vim.fn['plug#']
vim.call('plug#begin', '~/.local/share/nvim/plugged')

-- LSP
Plug('neovim/nvim-lspconfig')

-- Completion
Plug('saghen/blink.cmp')

-- Treesitter (modern syntax highlighting)
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
Plug('nvim-treesitter/nvim-treesitter-textobjects')

-- Fuzzy finding (integrates with fzf/rg)
Plug('ibhagwan/fzf-lua')

-- Formatting and linting
Plug('stevearc/conform.nvim')

-- Quality of life
Plug('lewis6991/gitsigns.nvim')
Plug('windwp/nvim-autopairs')

-- Colorscheme (pick one you like)
Plug('folke/tokyonight.nvim')

-- Keep any of your existing plugins that you still want below
-- Plug('your/existing-plugin')

vim.call('plug#end')

--=============================================================================
-- SECTION 3: Plugin configuration
--=============================================================================

-- Colorscheme (do this first so errors are visible)
vim.cmd('colorscheme tokyonight')

-- Completion (blink.cmp)
require('blink.cmp').setup({
  fuzzy = { implementation = 'lua' },
  keymap = { preset = 'default' },
  sources = {
    default = { 'lsp', 'path', 'buffer', 'snippets' },
  },
  completion = {
    documentation = { auto_show = true },
  },
  signature = { enabled = true },
})

-- LSP: shared capabilities from blink.cmp, applied to all servers
vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
})

-- LSP: ts_ls needs to know where mise installed the typescript library
vim.lsp.config('ts_ls', {
  init_options = {
    tsserver = {
      path = vim.fn.expand('~/.local/share/mise/installs/npm-typescript/latest/lib/node_modules/typescript'),
    },
  },
})

vim.lsp.enable({ 'ts_ls', 'pyright', 'ruff' })

-- LSP keymaps: nvim 0.11 provides these as built-in defaults:
--   K          hover docs
--   grn        rename
--   gra        code action
--   grr        references
--   gri        implementation
--   gO         document symbols
--   [d / ]d    prev/next diagnostic
--   CTRL-]     go to definition

-- Treesitter: highlighting and indent are built into nvim 0.11.
-- Install parsers with :TSInstall <lang> (requires tree-sitter CLI via mise)
-- Check parser status with :checkhealth nvim-treesitter

-- Textobjects
require('nvim-treesitter-textobjects').setup({
  select = { lookahead = true },
})
local ts_select = require('nvim-treesitter-textobjects.select')
vim.keymap.set({ 'x', 'o' }, 'af', function() ts_select.select_textobject('@function.outer') end)
vim.keymap.set({ 'x', 'o' }, 'if', function() ts_select.select_textobject('@function.inner') end)
vim.keymap.set({ 'x', 'o' }, 'ac', function() ts_select.select_textobject('@class.outer') end)
vim.keymap.set({ 'x', 'o' }, 'ic', function() ts_select.select_textobject('@class.inner') end)

-- fzf-lua (fuzzy finding)
local fzf = require('fzf-lua')
vim.keymap.set('n', '<leader>ff', fzf.files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', fzf.live_grep, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', fzf.buffers, { desc = 'Buffers' })
vim.keymap.set('n', '<leader>fh', fzf.help_tags, { desc = 'Help tags' })
vim.keymap.set('n', '<leader>fr', fzf.oldfiles, { desc = 'Recent files' })
vim.keymap.set('n', '<leader>fs', fzf.lsp_document_symbols, { desc = 'Document symbols' })

-- conform.nvim (formatting)
require('conform').setup({
  formatters_by_ft = {
    javascript = { 'prettier' },
    typescript = { 'prettier' },
    typescriptreact = { 'prettier' },
    javascriptreact = { 'prettier' },
    json = { 'prettier' },
    yaml = { 'prettier' },
    markdown = { 'prettier' },
    python = { 'ruff_format' },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})

-- gitsigns
require('gitsigns').setup()

-- autopairs
require('nvim-autopairs').setup()
```

Install plugins and LSP servers:

```zsh
# Install vim plugins
nvim +PlugInstall +qall

# Install treesitter parsers (run inside nvim, requires tree-sitter CLI)
# :TSInstall javascript typescript tsx python lua vim vimdoc json yaml toml markdown html css bash
# Check status with :checkhealth nvim-treesitter

# Install LSP servers via mise (already in config.toml, but can also run directly)
mise use -g "npm:typescript-language-server"
mise use -g "npm:typescript"
mise use -g "npm:pyright"
mise use -g ruff
```

**Test nvim**:

```zsh
nvim some-file.ts
# Verify: syntax highlighting, completion popup, go-to-definition
```

### Phase 4: MacPorts (optional conveniences)

These are nice-to-have but not critical. If MacPorts breaks after an OS
upgrade, your shell and nvim still work.

```zsh
# If MacPorts needs reinstalling after OS upgrade:
# Download from https://www.macports.org/install.php

sudo port selfupdate

# CLI tools (rg and fzf already via mise, but you can use MacPorts versions too)
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

Stow has no knowledge of specific tools—it purely mirrors paths from the package
directory to the parent of where you run stow.

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
```

#### Optional: install script

```bash
#!/bin/bash
# ~/dotfiles/install.sh

set -e
cd "$(dirname "$0")"

packages=(zsh nvim starship git)

for pkg in "${packages[@]}"; do
  echo "Stowing $pkg..."
  stow "$pkg"
done

echo "Done. Run 'git diff' to review any changes."
echo "If stow fails due to existing files, either:"
echo "  1. Back up and remove the existing file, then re-run"
echo "  2. Use 'stow --adopt <pkg>' to pull existing file into repo (review with git diff)"
```

#### Consolidating to .config (optional)

Many tools now support XDG base directories (`~/.config/`). The main guide
above keeps `~/.zshrc` in its traditional location for simplicity. If you
prefer full XDG consolidation:

| Tool     | Traditional location                  | XDG location           |
| -------- | ------------------------------------- | ---------------------- |
| git      | ~/.gitconfig                          | ~/.config/git/config   |
| nvim     | ~/.config/nvim (already XDG)          | —                      |
| starship | ~/.config/starship.toml (already XDG) | —                      |
| zsh      | ~/.zshrc (no native XDG)              | Use ZDOTDIR workaround |

For zsh, you can redirect via ZDOTDIR. Keep a minimal `~/.zshrc` (not stowed):

```zsh
# ~/.zshrc - redirect to .config (this file stays outside dotfiles repo)
export ZDOTDIR="$HOME/.config/zsh"
source "$ZDOTDIR/.zshrc"
```

Then your real config lives at `~/.config/zsh/.zshrc`. Your stow structure
would change to:

```
~/dotfiles/zsh/.config/zsh/.zshrc    →  symlinks to ~/.config/zsh/.zshrc
```

This is more complex to set up, so the main guide uses the simpler traditional
`~/.zshrc` approach. Choose based on how much you value XDG consistency.

### Phase 6: Tool Manifests

Keep declarative lists of installed tools so you can reproduce your environment.

#### mise: ~/.config/mise/config.toml

mise reads this file for global tool versions. Add it to your dotfiles:

```toml
# ~/dotfiles/mise/.config/mise/config.toml

[tools]
# Runtimes
node = "lts"
python = "3.12"

# Dev tools
uv = "latest"
neovim = "stable"
starship = "latest"
fzf = "latest"
tree-sitter = "latest"
stow = "latest"
ruff = "latest"

# LSP servers (via npm backend)
"npm:typescript-language-server" = "latest"
"npm:typescript" = "latest"
"npm:pyright" = "latest"

# Formatters (via npm backend)
"npm:prettier" = "latest"
```

Stow this alongside your other configs:

```zsh
mkdir -p ~/dotfiles/mise/.config/mise
mv ~/.config/mise/config.toml ~/dotfiles/mise/.config/mise/
stow mise
```

On a new machine, after installing mise:

```zsh
mise install   # reads config.toml, installs all tools including LSP servers
```

#### npm globals: avoid entirely

With LSP servers managed by mise, you likely don't need any npm globals.

For one-off tools, use npx:

```zsh
npx prettier --write .
npx eslint .
```

For project tooling, use devDependencies:

```zsh
npm install -D prettier eslint
```

#### MacPorts: package list

```
# ~/dotfiles/manifests/macports.txt

ripgrep
fd
jq
bat
eza
git-delta
```

Install script:

```bash
#!/bin/bash
# ~/dotfiles/manifests/install-macports.sh
xargs sudo port install < "$(dirname "$0")/macports.txt"
```

#### Updated dotfiles structure

```
~/dotfiles/
├── zsh/
│   └── .zshrc
├── nvim/
│   └── .config/nvim/
├── starship/
│   └── .config/starship.toml
├── git/
│   └── .config/git/config
├── mise/
│   └── .config/mise/config.toml    # includes LSP servers
├── manifests/
│   ├── macports.txt
│   └── install-macports.sh
└── install.sh
```

#### Master install script

```bash
#!/bin/bash
# ~/dotfiles/install.sh

set -e
cd "$(dirname "$0")"

echo "=== Stowing dotfiles ==="
for pkg in zsh nvim starship git mise; do
  echo "  Stowing $pkg..."
  stow "$pkg"
done

echo "=== Installing mise tools (including LSP servers) ==="
mise install

echo "=== MacPorts ==="
if command -v port &> /dev/null; then
  echo "  Run manually: ./manifests/install-macports.sh"
else
  echo "  MacPorts not installed, skipping"
fi

echo ""
echo "Done."
echo "If stow failed due to existing files, back them up and re-run,"
echo "or use 'stow --adopt <pkg>' then 'git diff' to review changes."
```

#### Keeping manifests up to date

When you install a new tool, add it to the mise config or MacPorts manifest:

```zsh
# Added a new mise tool (including LSP servers)
mise use -g bun
mise use -g "npm:vscode-langservers-extracted"
# Then update ~/dotfiles/mise/.config/mise/config.toml to match

# Added a new MacPorts package
sudo port install htop
# Then add 'htop' to ~/dotfiles/manifests/macports.txt
```

Commit the changes:

```zsh
cd ~/dotfiles && git add -A && git commit -m "Add <tool>"
```

## OS Upgrade Checklist

When upgrading macOS (e.g., to Tahoe):

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

## Removing Old Plugins

Once the new setup is working, you can remove old plugins from your config.
Plugins that are likely superseded:

| Old plugin            | Replacement                                          |
| --------------------- | ---------------------------------------------------- |
| ale                   | Built-in LSP diagnostics                             |
| coc.nvim              | nvim-lspconfig + blink.cmp                           |
| deoplete              | blink.cmp                                            |
| YouCompleteMe         | blink.cmp                                            |
| syntastic             | LSP diagnostics                                      |
| vim-polyglot          | treesitter                                           |
| nerdtree              | nvim's built-in netrw, or nvim-tree, or just fzf-lua |
| ctrlp                 | fzf-lua or telescope                                 |
| vim-airline/lightline | lualine, or just use starship in terminal            |

## File Locations Reference

```
# Dotfiles (version controlled, symlinked via stow)
~/dotfiles/                       # Dotfiles repo (push to GitHub)
~/dotfiles/zsh/.zshrc             # Shell config (stowed to ~/.zshrc)
~/dotfiles/nvim/.config/nvim/     # nvim config (stowed to ~/.config/nvim/)
~/dotfiles/starship/.config/      # Prompt config (stowed to ~/.config/)
~/dotfiles/git/.config/git/       # Git config (stowed to ~/.config/git/)

# Symlink targets (created by stow, don't edit directly)
~/.zshrc                          # -> ~/dotfiles/zsh/.zshrc
~/.config/nvim/                   # -> ~/dotfiles/nvim/.config/nvim/
~/.config/starship.toml           # -> ~/dotfiles/starship/.config/starship.toml
~/.config/git/config              # -> ~/dotfiles/git/.config/git/config

# Machine-specific (not in dotfiles repo)
~/.zshrc.local                    # Machine-specific shell overrides

# mise (survives OS upgrades)
~/.local/bin/mise                 # mise binary
~/.local/share/mise/              # mise-installed tools

# nvim state (not version controlled)
~/.local/share/nvim/plugged/      # vim-plug plugins
~/.local/share/nvim/site/parser/  # treesitter compiled parsers
~/.local/share/nvim/undo/         # nvim undo history

# zsh plugins (git cloned, could also be in dotfiles)
~/.zsh/                           # zsh-autosuggestions, zsh-syntax-highlighting

# System package manager (will break on OS upgrade)
/opt/local/                       # MacPorts
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
# Don't panic - your shell and nvim still work via mise
# Reinstall MacPorts from https://www.macports.org/install.php
# Then: sudo port selfupdate && sudo port install <packages>
```
