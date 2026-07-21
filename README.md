# dotfiles

Personal system settings across Linux and macOS.

## Installation

```bash
bash <(curl https://raw.githubusercontent.com/jondong/dotfiles/master/bootstrap.sh -L)
```

## Options

```bash
./bootstrap.sh --with-packages --auto   # full automated setup
./scripts/doctor.sh                     # check & repair config
```

## Layout

- `bootstrap.sh` — single entry point
- `apps/` — application configs (symlinked to `~/`)
- `platforms/` — OS-specific package installers
- `shells/zsh/` — zsh configuration
- `scripts/doctor.sh` — health check

## fzf

fzf is installed per platform and configured centrally in
`shells/zsh/common/fzf.zsh`. macOS uses Homebrew; Linux tracks the latest
upstream release from `~/.fzf`. The shared configuration does not depend on a
generated `~/.fzf.zsh` file.

- `Ctrl-T` — select files and directories
- `Ctrl-R` — search shell history
- `Alt-C` — change to a selected directory
- `**<Tab>` — fuzzy-complete paths and directories
- `F2` — toggle the preview in file and directory pickers
- `Ctrl-Y` — copy a file or history selection when a supported clipboard tool
  is available
