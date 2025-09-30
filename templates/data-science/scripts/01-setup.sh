#!/bin/bash

# Setup script for Data Science Template
# Installs and configures data science tools and libraries

set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../scripts/common/utils.sh"

main() {
    section "Setting Up Data Science Environment"

    # Install system packages
    install_system_packages

    # Setup Python environment
    setup_python_environment

    # Setup R environment
    setup_r_environment

    # Install and configure Jupyter
    setup_jupyter

    # Setup development tools
    setup_development_tools

    # Configure databases
    setup_databases

    # Setup VS Code extensions
    if command_exists code; then
        setup_vscode_extensions
    fi

    # Create project structure
    create_project_structure

    # Configure environment
    configure_environment

    log_success "Data science environment setup complete!"
}

install_system_packages() {
    log_info "Installing system packages..."

    local platform=$(detect_platform)

    case "$platform" in
        "macos")
            install_macos_packages
            ;;
        "linux")
            install_linux_packages
            ;;
    esac
}

install_macos_packages() {
    if ! command_exists brew; then
        log_error "Homebrew not found. Please install it first."
        return 1
    fi

    # Core packages
    local core_packages=(
        "python@3.11"
        "r"
        "jupyterlab"
        "node"
        "sqlite"
        "postgresql"
        "redis"
        "docker"
        "docker-compose"
        "git"
        "wget"
        "curl"
    )

    for package in "${core_packages[@]}"; do
        if brew list "$package" >/dev/null 2>&1; then
            log_info "$package already installed"
        else
            log_info "Installing $package..."
            brew install "$package"
        fi
    done

    # GUI applications
    local cask_packages=(
        "rstudio"
        "datagrip"
        "postman"
    )

    for package in "${cask_packages[@]}"; do
        if brew list --cask "$package" >/dev/null 2>&1; then
            log_info "$package already installed"
        else
            log_info "Installing $package..."
            brew install --cask "$package"
        fi
    done
}

install_linux_packages() {
    local package_manager=$(detect_package_manager)

    case "$package_manager" in
        "apt")
            sudo apt-get update

            local packages=(
                "python3.11"
                "python3.11-venv"
                "python3-pip"
                "python3-dev"
                "r-base"
                "r-base-dev"
                "git"
                "sqlite3"
                "postgresql"
                "postgresql-contrib"
                "redis-server"
                "docker.io"
                "docker-compose"
                "wget"
                "curl"
                "build-essential"
            )

            for package in "${packages[@]}"; do
                if dpkg -l | grep -q "^ii.*$package"; then
                    log_info "$package already installed"
                else
                    log_info "Installing $package..."
                    sudo apt-get install -y "$package"
                fi
            done
            ;;
        "yum"|"dnf")
            sudo "$package_manager" groupinstall -y "Development Tools"

            local packages=(
                "python3.11"
                "python3-pip"
                "python3-devel"
                "R"
                "git"
                "sqlite"
                "postgresql-server"
                "redis"
                "docker"
                "docker-compose"
                "wget"
                "curl"
            )

            for package in "${packages[@]}"; do
                if rpm -q "$package" >/dev/null 2>&1; then
                    log_info "$package already installed"
                else
                    log_info "Installing $package..."
                    sudo "$package_manager" install -y "$package"
                fi
            done
            ;;
    esac
}

setup_python_environment() {
    log_info "Setting up Python environment..."

    # Install Miniconda if not present
    if [[ ! -d "$HOME/miniconda3" ]]; then
        log_info "Installing Miniconda..."
        local platform=$(detect_platform)
        local arch=$(uname -m)

        case "$platform" in
            "macos")
                if [[ "$arch" == "arm64" ]]; then
                    local miniconda_url="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh"
                else
                    local miniconda_url="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh"
                fi
                ;;
            "linux")
                if [[ "$arch" == "aarch64" ]]; then
                    local miniconda_url="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh"
                else
                    local miniconda_url="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
                fi
                ;;
        esac

        cd /tmp
        curl -O "$miniconda_url"
        bash Miniconda3-latest-*.sh -b -p "$HOME/miniconda3"
        rm Miniconda3-latest-*.sh
        cd - >/dev/null
    fi

    # Add conda to PATH
    export PATH="$HOME/miniconda3/bin:$PATH"

    # Initialize conda
    if [[ -f "$HOME/miniconda3/bin/conda" ]]; then
        "$HOME/miniconda3/bin/conda" init bash
        "$HOME/miniconda3/bin/conda" init zsh
    fi

    # Create data science environment
    if "$HOME/miniconda3/bin/conda" env list | grep -q "datascience"; then
        log_info "Conda environment 'datascience' already exists"
    else
        log_info "Creating conda environment 'datascience'..."
        "$HOME/miniconda3/bin/conda" create -n datascience python=3.11 -y
    fi

    # Activate environment and install packages
    source "$HOME/miniconda3/bin/activate" datascience

    # Upgrade pip
    pip install --upgrade pip

    # Install core data science packages
    local core_packages=(
        "numpy>=1.21.0"
        "pandas>=1.3.0"
        "matplotlib>=3.4.0"
        "seaborn>=0.11.0"
        "plotly>=5.0.0"
        "scipy>=1.7.0"
        "scikit-learn>=1.0.0"
        "jupyterlab>=3.0.0"
        "jupyter>=1.0.0"
        "ipywidgets>=7.6.0"
        "notebook>=6.4.0"
    )

    for package in "${core_packages[@]}"; do
        log_info "Installing $package..."
        pip install "$package"
    done

    # Install machine learning packages
    local ml_packages=(
        "tensorflow>=2.8.0"
        "torch>=1.11.0"
        "torchvision>=0.12.0"
        "xgboost>=1.6.0"
        "lightgbm>=3.3.0"
        "catboost>=1.0.0"
        "transformers>=4.18.0"
        "datasets>=2.0.0"
    )

    for package in "${ml_packages[@]}"; do
        log_info "Installing $package..."
        pip install "$package"
    done

    # Install data packages
    local data_packages=(
        "sqlalchemy>=1.4.0"
        "psycopg2-binary>=2.9.0"
        "pymongo>=4.0.0"
        "redis>=4.1.0"
        "openpyxl>=3.0.0"
        "xlrd>=2.0.0"
        "requests>=2.27.0"
        "beautifulsoup4>=4.10.0"
        "scrapy>=2.5.0"
        "boto3>=1.21.0"
    )

    for package in "${data_packages[@]}"; do
        log_info "Installing $package..."
        pip install "$package"
    done

    # Install visualization packages
    local viz_packages=(
        "bokeh>=2.4.0"
        "altair>=4.2.0"
        "dash>=2.0.0"
        "streamlit>=1.8.0"
        "folium>=0.12.0"
        "wordcloud>=1.8.0"
        "networkx>=2.8.0"
    )

    for package in "${viz_packages[@]}"; do
        log_info "Installing $package..."
        pip install "$package"
    done

    # Install Jupyter extensions
    local jupyter_extensions=(
        "jupyterlab-git"
        "jupyterlab-toc"
        "jupyterlab-code-formatter"
        "jupyterlab-variableInspector"
    )

    for extension in "${jupyter_extensions[@]}"; do
        log_info "Installing Jupyter extension: $extension"
        pip install "$extension"
        jupyter labextension install "$extension" || log_warn "Failed to install $extension"
    done

    # Enable Jupyter extensions
    jupyter nbextension enable --py widgetsnbextension
    jupyter server extension enable --py jupyterlab_git

    conda deactivate
}

setup_r_environment() {
    log_info "Setting up R environment..."

    if command_exists R; then
        # Create R library directories
        mkdir -p "$HOME/R/library"
        mkdir -p "$HOME/R/site-library"

        # Install CRAN packages
        local r_packages=(
            "tidyverse"
            "ggplot2"
            "dplyr"
            "readr"
            "tidyr"
            "lubridate"
            "stringr"
            "forcats"
            "purrr"
            "caret"
            "randomForest"
            "e1071"
            "xgboost"
            "glmnet"
            "nnet"
            "DBI"
            "RPostgreSQL"
            "readxl"
            "writexl"
            "httr"
            "rvest"
            "jsonlite"
            "plotly"
            "shiny"
            "leaflet"
            "DT"
            "flexdashboard"
        )

        for package in "${r_packages[@]}"; do
            log_info "Installing R package: $package"
            R --slave -e "if (!require('$package', quietly = TRUE)) install.packages('$package', repos='https://cran.r-project.org')"
        done

        # Install IRkernel
        log_info "Installing IRkernel..."
        R --slave -e "if (!require('IRkernel', quietly = TRUE)) install.packages('IRkernel', repos='https://cran.r-project.org')"
        R --slave -e "IRkernel::installspec()"
    else
        log_warn "R not found, skipping R environment setup"
    fi
}

setup_jupyter() {
    log_info "Setting up Jupyter configuration..."

    # Create Jupyter config directory
    mkdir -p "$HOME/.jupyter"

    # Generate Jupyter config
    if [[ ! -f "$HOME/.jupyter/jupyter_lab_config.py" ]]; then
        source "$HOME/miniconda3/bin/activate" datascience
        jupyter lab --generate-config
        conda deactivate
    fi

    # Configure Jupyter Lab
    cat >> "$HOME/.jupyter/jupyter_lab_config.py" << 'EOF'

# Data Science Environment Configuration
c.LabApp.default_url = '/lab'
c.LabApp.open_browser = False
c.LabApp.port = 8889
c.LabApp.ip = 'localhost'

# Enable server extensions
c.ServerProxy.servers = {
    'tensorboard': {
        'command': ['tensorboard', '--logdir', '{args}']
    }
}

# Security settings
c.LabApp.token = ''
c.LabApp.password = ''

# Working directory
c.LabApp.root_dir = '~/Projects/data-science'

# Performance settings
c.LabApp.extra_labextensions_path = []

# Logging
c.LabApp.log_level = 'INFO'
EOF

    # Create custom Jupyter kernel spec
    mkdir -p "$HOME/.local/share/jupyter/kernels/datascience"
    cat > "$HOME/.local/share/jupyter/kernels/datascience/kernel.json" << 'EOF'
{
    "argv": [
        "~/miniconda3/envs/datascience/bin/python",
        "-m",
        "ipykernel_launcher",
        "-f",
        "{connection_file}"
    ],
    "display_name": "Data Science (datascience)",
    "language": "python",
    "env": {
        "PYTHONPATH": "~/Projects/data-science",
        "PYTHONIOENCODING": "utf-8"
    }
}
EOF
}

setup_development_tools() {
    log_info "Setting up development tools..."

    # Install additional Python tools
    source "$HOME/miniconda3/bin/activate" datascience

    local dev_tools=(
        "black"
        "flake8"
        "isort"
        "mypy"
        "pytest"
        "jupyter-black"
        "pre-commit"
        "mlflow"
        "dvc"
    )

    for tool in "${dev_tools[@]}"; do
        log_info "Installing $tool..."
        pip install "$tool"
    done

    conda deactivate

    # Configure git for data science
    git config --global init.templateDir "$HOME/.git-template"
    mkdir -p "$HOME/.git-template/info"

    cat > "$HOME/.git-template/info/attributes" << 'EOF'
# Git attributes for data science
*.csv text diff=csv
*.tsv text diff=csv
*.json text diff=json
*.xml text diff=xml

# Large files
*.pkl binary
*.h5 binary
*.hdf5 binary
*.model binary
*.joblib binary

# Jupyter notebooks
*.ipynb text

# Data files
*.csv text eol=lf
*.json text eol=lf
*.yml text eol=lf
*.yaml text eol=lf
EOF
}

setup_databases() {
    log_info "Setting up databases..."

    local platform=$(detect_platform)

    # Start PostgreSQL services
    case "$platform" in
        "macos")
            if command_exists brew; then
                brew services start postgresql || true
                brew services start redis || true
            fi
            ;;
        "linux")
            sudo systemctl start postgresql || true
            sudo systemctl start redis-server || true
            ;;
    esac

    # Create data science database
    if command_exists psql; then
        log_info "Creating data science database..."
        createdb -U postgres datascience 2>/dev/null || log_info "Database 'datascience' already exists"
    fi
}

setup_vscode_extensions() {
    log_info "Installing VS Code extensions for data science..."

    local extensions=(
        "ms-python.python"
        "ms-python.vscode-pylance"
        "ms-toolsai.jupyter"
        "ms-toolsai.jupyter-keymap"
        "ms-toolsai.jupyter-renderers"
        "RDebugger.r-debugger"
        "REditorSupport.r"
        "Reditorsupport.r-lsp"
        "ms-vscode.vscode-json"
        "ms-vscode.vscode-markdown"
        "formulahendry.code-runner"
        "ms-vscode.vscode-docker"
    )

    for extension in "${extensions[@]}"; do
        log_info "Installing VS Code extension: $extension"
        code --install-extension "$extension" || log_warn "Failed to install $extension"
    done

    # Create VS Code settings for data science
    local vscode_dir="$HOME/Library/Application Support/Code/User"
    if [[ ! -d "$vscode_dir" ]]; then
        vscode_dir="$HOME/.config/Code/User"
    fi

    ensure_dir "$vscode_dir"

    cat > "$vscode_dir/settings.json" << 'EOF'
{
    "python.defaultInterpreterPath": "~/miniconda3/envs/datascience/bin/python",
    "python.terminal.activateEnvironment": true,
    "python.linting.enabled": true,
    "python.linting.flake8Enabled": true,
    "python.formatting.provider": "black",
    "jupyter.askForKernelRestart": false,
    "jupyter.jupyterServerType": "local",
    "r.rterm.option": "--no-save",
    "r.lsp.enabled": true,
    "r.lsp.debug": true,
    "r.bracketedPaste": true,
    "r.plot.useHttpgd": true,
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 1000,
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    },
    "search.exclude": {
        "**/node_modules": true,
        "**/__pycache__": true,
        "**/.ipynb_checkpoints": true,
        "**/*.pkl": true,
        "**/*.h5": true
    }
}
EOF
}

create_project_structure() {
    log_info "Creating project structure..."

    local base_dir="$HOME/Projects/data-science"
    local directories=(
        "$base_dir"
        "$base_dir/notebooks"
        "$base_dir/datasets"
        "$base_dir/models"
        "$base_dir/experiments"
        "$base_dir/src"
        "$base_dir/tests"
        "$base_dir/outputs"
        "$base_dir/docs"
        "$base_dir/scripts"
    )

    for dir in "${directories[@]}"; do
        ensure_dir "$dir"
    done

    # Create README files
    cat > "$base_dir/README.md" << 'EOF'
# Data Science Projects

This directory contains all data science projects and experiments.

## Structure

- `notebooks/` - Jupyter notebooks for analysis and experimentation
- `datasets/` - Raw and processed datasets
- `models/` - Trained machine learning models
- `experiments/` - MLflow experiments and results
- `src/` - Source code for data processing and modeling
- `tests/` - Unit tests and validation scripts
- `outputs/` - Generated outputs and reports
- `docs/` - Documentation and project notes
- `scripts/` - Utility scripts and automation

## Getting Started

1. Activate the conda environment: `conda activate datascience`
2. Start Jupyter Lab: `jupyter lab`
3. Create a new project in the appropriate subdirectory

Happy data sciencing! 🚀
EOF

    # Create .gitignore
    cat > "$base_dir/.gitignore" << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Jupyter
.ipynb_checkpoints
*.ipynb

# Data files
*.csv
*.tsv
*.json
*.xml
*.parquet
*.feather
*.h5
*.hdf5
*.pkl
*.pickle
*.joblib
*.model
*.bin

# MLflow
mlruns/
mlartifacts/

# Environment
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# R
.Rhistory
.RData
.Ruserdata

# Outputs
outputs/
reports/
figures/
plots/

# DVC
.dvc/
.dvcignore
EOF
}

configure_environment() {
    log_info "Configuring environment..."

    # Create .Rprofile
    cat > "$HOME/.Rprofile" << 'EOF'
# R configuration for data science
options(repos = c(CRAN = "https://cran.r-project.org"))
options(stringsAsFactors = FALSE)
options(scipen = 999)

# Set working directory
if (interactive()) {
    setwd("~/Projects/data-science")
}

# Load common packages silently
suppressPackageStartupMessages({
    library(tidyverse)
})

# Custom functions
ds.project <- function(name) {
    dir.create(name, recursive = TRUE, showWarnings = FALSE)
    dir.create(file.path(name, "data"), showWarnings = FALSE)
    dir.create(file.path(name, "notebooks"), showWarnings = FALSE)
    dir.create(file.path(name, "src"), showWarnings = FALSE)
    dir.create(file.path(name, "figures"), showWarnings = FALSE)
    setwd(name)
    cat("Project", name, "created successfully!\n")
}
EOF

    # Create conda environment file
    source "$HOME/miniconda3/bin/activate" datascience
    conda env export > "$HOME/Projects/data-science/environment.yml"
    conda deactivate

    # Set up MLflow
    if command_exists mlflow; then
        mkdir -p "$HOME/Projects/data-science/experiments/mlruns"
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi