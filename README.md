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
