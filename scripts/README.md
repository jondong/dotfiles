# Scripts Directory

This directory contains utility scripts for managing and maintaining the dotfiles environment.

## Directory Structure

```
scripts/
├── health/                  # Health checking and diagnostic tools
│   ├── health-check.sh     # Comprehensive system health check
│   ├── validate-config.sh  # Configuration file validation
│   └── diagnose-issues.sh  # Issue diagnosis and troubleshooting
├── backup/                  # Backup and restore utilities
│   ├── config-backup.sh    # Configuration backup
│   ├── restore-config.sh   # Configuration restore
│   └── migrate-config.sh   # Configuration migration
├── package-management/      # Package management utilities
│   ├── install-packages.sh # Smart package installation
│   ├── update-all.sh       # Update all packages and configs
│   └── cleanup-unused.sh   # Clean up unused packages
├── monitoring/              # Monitoring and analytics
│   ├── performance-metrics.sh # Performance metrics collection
│   └── usage-analytics.sh  # Usage statistics and analysis
├── dotfile-manager.sh       # Unified configuration manager
└── common/                  # Common utilities and functions
    ├── logging.sh          # Logging utilities
    ├── platform-detect.sh  # Platform detection
    └── utils.sh            # Common utility functions
```

## Usage

Most scripts can be run directly from the dotfiles root:

```bash
# Health check
./scripts/health/health-check.sh

# Configuration validation
./scripts/health/validate-config.sh

# Unified management
./scripts/dotfile-manager.sh status
./scripts/dotfile-manager.sh update
```

## Development

When adding new scripts:
1. Follow the naming conventions
2. Include proper error handling
3. Add logging and status output
4. Update this README
5. Test on all supported platforms