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
- `apps/` — application configs (symlinked to their platform-specific locations)
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

## Herdr

Herdr settings are managed in `apps/herdr/config.toml` and linked to
`~/.config/herdr/config.toml`. Ghostty settings are managed in
`apps/ghostty/config.ghostty`; Linux uses
`${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config.ghostty`.

Ghostty starts Herdr through `bin/herdr-launcher`; if Herdr is unavailable,
the launcher falls back to a login shell. On Debian/Ubuntu, Herdr is installed
by `./bootstrap.sh --with-packages`. Install Ghostty using the package provided
for your Linux distribution.
