# Zsh Configuration Structure

This directory contains a platform-separated Zsh configuration system that supports MacOS and Linux with shared common configurations.

## Directory Structure

```
shells/zsh/
├── common/           # Shared configurations across all platforms
│   ├── base.zsh     # Base Zsh configuration and plugin setup
│   ├── paths.zsh    # Common PATH and environment setup
│   ├── functions.zsh # Utility functions
│   ├── aliases.zsh  # Common aliases
│   ├── fzf.zsh      # FZF configuration
│   ├── lazyload.zsh # Lazy loading for tools
│   └── final.zsh    # Final configuration loading
├── mac/             # MacOS-specific configurations
│   ├── env.zsh      # MacOS environment variables
│   ├── path.zsh     # MacOS-specific paths
│   └── tools.zsh    # MacOS-specific tools
├── linux/           # Linux-specific configurations
│   ├── env.zsh      # Linux environment variables
│   ├── path.zsh     # Linux-specific paths
│   └── tools.zsh    # Linux-specific tools
├── zshrc.symlink    # Main Zsh configuration loader
├── zprofile.symlink # Platform detection
├── zshenv.symlink   # Basic environment variables
└── migrate-to-new-structure.sh # Migration script from old structure
```

## Key Features

### 1. **Modular Design**
Configuration is split into logical modules:
- **Common modules**: Shared across all platforms
- **Platform-specific modules**: Tailored for MacOS or Linux

### 2. **Automatic Platform Detection**
The configuration automatically detects the platform and loads appropriate modules:
- MacOS (`Darwin`)
- Linux (`Linux`)
- Cygwin (`Cygwin`)

### 3. **Lazy Loading**
Heavy tools are loaded on-demand to improve shell startup time:
- `autojump`
- `jenv`
- `rbenv`
- `direnv`

### 4. **FZF Integration**
Smart FZF configuration with platform-specific fallbacks.

### 5. **Android SDK Support**
Platform-specific Android SDK paths and tool configurations.

## File Details

### Common Files (`common/`)

#### `base.zsh`
- Zinit plugin manager setup
- Oh My Zsh components loading
- Essential plugin loading (completions, autosuggestions, syntax highlighting)

#### `functions.zsh`
- Platform detection function
- PATH management utilities
- `lazy_load` function for on-demand tool loading

#### `paths.zsh`
- Basic environment setup
- Common PATH configurations
- Loads platform-specific paths

#### `aliases.zsh`
- Common aliases for all platforms
- Basic command improvements

#### `fzf.zsh`
- FZF configuration with preview
- FD integration for file search
- Platform-aware completion functions

#### `lazyload.zsh`
- On-demand loading for heavy tools
- iTerm2 integration (MacOS)
- Autojump setup

#### `final.zsh`
- Local configuration loading
- SDKMAN setup
- Final prompt configuration

### MacOS Files (`mac/`)

#### `env.zsh`
- Homebrew paths setup
- NVM configuration via Homebrew
- Android SDK MacOS paths

#### `path.zsh`
- Homebrew binary paths
- MacOS Applications paths
- Xcode command line tools

#### `tools.zsh`
- Android SDK setup
- Clipboard integration (`pbcopy`, `pbpaste`)
- Finder integration (`open`, `show`)

### Linux Files (`linux/`)

#### `env.zsh`
- Clean Homebrew removal
- Linux-specific Android SDK paths
- NVM direct setup

#### `path.zsh`
- Standard Linux binary locations
- Snap packages support
- Flatpak support
- Package manager specific paths

#### `tools.zsh`
- Android SDK setup
- X11 clipboard integration (`xclip`, `xsel`)
- Package manager helpers (`apt`, `yum`, `pacman`)
- System information commands

## Migration

To migrate from the old structure to the new one:

```bash
cd shells/zsh
./migrate-to-new-structure.sh
```

This script will:
1. Create backups of existing configurations
2. Replace old files with new structured ones
3. Show you the differences (if requested)

## Performance Optimizations

1. **Caching**: File lists are cached to avoid repeated directory scanning
2. **Lazy Loading**: Heavy tools are loaded only when first used
3. **Conditional Loading**: Platform-specific code only runs on appropriate platforms
4. **Minimal Plugins**: Only essential Oh My Zsh components are loaded

## Customization

### Adding Platform-Specific Features

1. **MacOS**: Add files to `mac/` directory and load them in the MacOS section of `zshrc.symlink`
2. **Linux**: Add files to `linux/` directory and load them in the Linux section of `zshrc.symlink`

### Adding Common Features

1. Add common functionality to `common/` directory
2. Update `zshrc.symlink` to source the new file in the appropriate section

## Troubleshooting

1. **Shell startup slow**: Check for network timeouts or heavy command executions
2. **Commands not found**: Verify platform detection works: `echo $PLATFORM`
3. **Missing features**: Check if platform-specific files are loaded in the main `zshrc.symlink` file

## Testing

To test the configuration across platforms:

```bash
# Check platform detection
echo $PLATFORM

# Verify loaded modules
grep "source.*\.zsh" ~/.zshrc

# Test specific functionality
# MacOS:
pbcopy "test"  # Should copy to clipboard
open .         # Should open Finder

# Linux:
xclip -version  # Should show xclip version
xdg-open .      # Should open file manager
```