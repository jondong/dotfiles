# dotfiles

Personal development environment for macOS and Linux, set up with one command.

This repository keeps my shell, terminal and tool configuration in one place,
so a new machine can be brought to the same working state quickly and existing
machines stay in sync.

## What it provides

- **Zsh environment**: a modular zsh setup split into shared and
  platform-specific parts, with zinit plugins, the Powerlevel10k prompt, lazy
  loading for heavy tools, and common aliases and functions.
- **Terminal workflow**: configuration for Ghostty, tmux and Herdr. Ghostty
  opens straight into Herdr or tmux, and tmux has a status bar with CPU load
  and weather.
- **fzf integration**: fuzzy search for files, directories and shell history,
  configured the same way on every platform.
- **Package installation** (optional): installs the CLI tools, developer
  tools, fonts and apps I use, through Homebrew on macOS and apt/snap on
  Linux.
- **Utility scripts** in `bin/`, available on `PATH`: terminal launchers,
  tmux status helpers, encrypted zip helpers and a few git and macOS tools.
- **Health check**: `scripts/doctor.sh` verifies links, required tools and app
  configs, and can repair common problems.

## Quick start

```bash
bash <(curl https://raw.githubusercontent.com/jondong/dotfiles/master/bootstrap.sh -L)
```

This clones the repository to `~/.dotfiles`, links the config files into
place, and sets up zsh, tmux, Ghostty and Herdr configs. Run it again at any
time to pull updates and re-link.

To also install all packages without prompts:

```bash
~/.dotfiles/bootstrap.sh --with-packages --auto
```

On macOS, package installation needs [Homebrew](https://brew.sh).

## Usage

```bash
./bootstrap.sh [options]
```

| Option | Description |
| --- | --- |
| `--auto` | Non-interactive; keep existing files instead of asking |
| `--with-packages` | Also run the platform package installer |
| `--skip-update` | Don't `git pull` before installing |
| `--skip-health` | Skip the health check at the end |
| `-v`, `--verbose` | Show more detail |

Check or repair an existing setup:

```bash
~/.dotfiles/scripts/doctor.sh
```

## How it works

Files ending in `.symlink` are linked into `$HOME` as dotfiles on every
platform (`zshrc.symlink` becomes `~/.zshrc`). `.macsymlink` and
`.linuxsymlink` files are linked only on that platform. App configs in `apps/`
are linked to each app's own config location by `bootstrap.sh`.

## Layout

```
bootstrap.sh     Single entry point
apps/            Ghostty, Herdr and tmux configs
bin/             Utility scripts (added to PATH)
platforms/       Per-OS package installers and aliases (mac/, linux/)
shells/zsh/      Zsh config: common/, mac/, linux/ and the top-level rc files
scripts/         doctor.sh health check, Linux config test
```

## License

See [LICENSE](LICENSE).
