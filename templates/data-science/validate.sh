#!/bin/bash

# Validation script for Data Science Template
# Verifies that all data science tools and libraries are properly installed

set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../scripts/common/utils.sh"

# Validation counters
VALIDATIONS_PASSED=0
VALIDATIONS_FAILED=0
VALIDATIONS_WARNED=0

# Validation functions
validate_python_environment() {
    section "Validating Python Environment"

    # Check Python installation
    if command_exists python3.11 || command_exists python3.10 || command_exists python3; then
        local python_cmd=$(command -v python3.11 || command -v python3.10 || command -v python3)
        local python_version=$("$python_cmd" --version 2>&1)
        status_ok "Python: $python_version"
        ((VALIDATIONS_PASSED++))

        # Check Python version
        local major_version=$(echo "$python_version" | sed 's/.*Python \([0-9]*\).*/\1/')
        if [[ $major_version -ge 3 ]]; then
            local minor_version=$(echo "$python_version" | sed 's/.*Python [0-9]*\.\([0-9]*\).*/\1/')
            if [[ $minor_version -ge 8 ]]; then
                status_ok "Python version >= 3.8 (recommended for data science)"
                ((VALIDATIONS_PASSED++))
            else
                status_warn "Python version < 3.8 (upgrade recommended)"
                ((VALIDATIONS_WARNED++))
            fi
        else
            status_error "Python version < 3.x"
            ((VALIDATIONS_FAILED++))
        fi
    else
        status_error "Python not installed"
        ((VALIDATIONS_FAILED++))
    fi

    # Check Conda installation
    if [[ -d "$HOME/miniconda3" ]]; then
        status_ok "Miniconda installation found"
        ((VALIDATIONS_PASSED++))

        # Check conda command
        if command_exists "$HOME/miniconda3/bin/conda"; then
            local conda_version=$("$HOME/miniconda3/bin/conda" --version 2>&1)
            status_ok "Conda: $conda_version"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "Conda command not accessible"
            ((VALIDATIONS_WARNED++))
        fi

        # Check datascience environment
        if "$HOME/miniconda3/bin/conda" env list | grep -q "datascience"; then
            status_ok "Conda environment 'datascience' exists"
            ((VALIDATIONS_PASSED++))
        else
            status_error "Conda environment 'datascience' not found"
            ((VALIDATIONS_FAILED++))
        fi
    else
        status_error "Miniconda not installed"
        ((VALIDATIONS_FAILED++))
    fi
}

validate_core_packages() {
    section "Validating Core Data Science Packages"

    if [[ -d "$HOME/miniconda3/envs/datascience" ]]; then
        source "$HOME/miniconda3/bin/activate" datascence 2>/dev/null || true

        local core_packages=(
            "numpy"
            "pandas"
            "matplotlib"
            "seaborn"
            "plotly"
            "scipy"
            "scikit-learn"
        )

        for package in "${core_packages[@]}"; do
            if python -c "import $package" 2>/dev/null; then
                local version=$(python -c "import $package; print($package.__version__)" 2>/dev/null)
                status_ok "$package: $version"
                ((VALIDATIONS_PASSED++))
            else
                status_error "$package not installed"
                ((VALIDATIONS_FAILED++))
            fi
        done

        conda deactivate 2>/dev/null || true
    else
        status_warn "Cannot validate packages: datascience environment not found"
        ((VALIDATIONS_WARNED++))
    fi
}

validate_jupyter() {
    section "Validating Jupyter Installation"

    if command_exists jupyter; then
        local jupyter_version=$(jupyter --version 2>/dev/null)
        status_ok "Jupyter: $jupyter_version"
        ((VALIDATIONS_PASSED++))
    else
        status_error "Jupyter not installed"
        ((VALIDATIONS_FAILED++))
    fi

    if command_exists jupyter-lab; then
        local lab_version=$(jupyter-lab --version 2>/dev/null)
        status_ok "JupyterLab: $lab_version"
        ((VALIDATIONS_PASSED++))
    else
        status_error "JupyterLab not installed"
        ((VALIDATIONS_FAILED++))
    fi

    # Check Jupyter configuration
    if [[ -f "$HOME/.jupyter/jupyter_lab_config.py" ]]; then
        status_ok "JupyterLab configuration found"
        ((VALIDATIONS_PASSED++))
    else
        status_warn "JupyterLab configuration not found"
        ((VALIDATIONS_WARNED++))
    fi

    # Check kernels
    if [[ -d "$HOME/.local/share/jupyter/kernels" ]]; then
        local kernel_count=$(find "$HOME/.local/share/jupyter/kernels" -maxdepth 1 -type d | wc -l)
        status_ok "Jupyter kernels available: $((kernel_count - 1))"
        ((VALIDATIONS_PASSED++))
    else
        status_warn "No Jupyter kernels found"
        ((VALIDATIONS_WARNED++))
    fi
}

validate_r_environment() {
    section "Validating R Environment"

    if command_exists R; then
        local r_version=$(R --version | head -1)
        status_ok "R: $r_version"
        ((VALIDATIONS_PASSED++))

        # Check R version
        local major_version=$(echo "$r_version" | sed 's/.*R version \([0-9]*\).*/\1/')
        if [[ $major_version -ge 4 ]]; then
            status_ok "R version >= 4.x (recommended)"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "R version < 4.x (upgrade recommended)"
            ((VALIDATIONS_WARNED++))
        fi

        # Check key R packages
        local r_packages=("tidyverse" "ggplot2" "dplyr")
        for package in "${r_packages[@]}"; do
            if R --slave -e "if (!require('$package', quietly = TRUE)) quit(1)" 2>/dev/null; then
                status_ok "R package: $package"
                ((VALIDATIONS_PASSED++))
            else
                status_warn "R package not installed: $package"
                ((VALIDATIONS_WARNED++))
            fi
        done
    else
        status_warn "R not installed (optional for data science)"
        ((VALIDATIONS_WARNED++))
    fi
}

validate_databases() {
    section "Validating Database Tools"

    # Check PostgreSQL
    if command_exists psql; then
        local psql_version=$(psql --version 2>/dev/null | head -1)
        status_ok "PostgreSQL client: $psql_version"
        ((VALIDATIONS_PASSED++))

        # Check if PostgreSQL server is running
        if pgrep postgres > /dev/null; then
            status_ok "PostgreSQL server is running"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "PostgreSQL server is not running"
            ((VALIDATIONS_WARNED++))
        fi
    else
        status_warn "PostgreSQL client not installed"
        ((VALIDATIONS_WARNED++))
    fi

    # Check Redis
    if command_exists redis-cli; then
        local redis_version=$(redis-cli --version 2>/dev/null)
        status_ok "Redis client: $redis_version"
        ((VALIDATIONS_PASSED++))

        # Check if Redis server is running
        if pgrep redis-server > /dev/null; then
            status_ok "Redis server is running"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "Redis server is not running"
            ((VALIDATIONS_WARNED++))
        fi
    else
        status_warn "Redis client not installed"
        ((VALIDATIONS_WARNED++))
    fi

    # Check SQLite
    if command_exists sqlite3; then
        local sqlite_version=$(sqlite3 --version | cut -d' ' -f1)
        status_ok "SQLite: $sqlite_version"
        ((VALIDATIONS_PASSED++))
    else
        status_warn "SQLite not installed"
        ((VALIDATIONS_WARNED++))
    fi
}

validate_ml_frameworks() {
    section "Validating Machine Learning Frameworks"

    if [[ -d "$HOME/miniconda3/envs/datascience" ]]; then
        source "$HOME/miniconda3/bin/activate" datascience 2>/dev/null || true

        local ml_packages=(
            "tensorflow"
            "torch"
            "xgboost"
        )

        for package in "${ml_packages[@]}"; do
            if python -c "import $package" 2>/dev/null; then
                local version=$(python -c "import $package; print($package.__version__)" 2>/dev/null)
                status_ok "$package: $version"
                ((VALIDATIONS_PASSED++))
            else
                status_warn "$package not installed (optional)"
                ((VALIDATIONS_WARNED++))
            fi
        done

        conda deactivate 2>/dev/null || true
    else
        status_warn "Cannot validate ML frameworks: datascience environment not found"
        ((VALIDATIONS_WARNED++))
    fi
}

validate_development_tools() {
    section "Validating Development Tools"

    # Check Git
    if command_exists git; then
        local git_version=$(git --version)
        status_ok "Git: $git_version"
        ((VALIDATIONS_PASSED++))
    else
        status_error "Git not installed"
        ((VALIDATIONS_FAILED++))
    fi

    # Check VS Code
    if command_exists code; then
        local code_version=$(code --version 2>/dev/null | head -1)
        status_ok "VS Code: $code_version"
        ((VALIDATIONS_PASSED++))
    else
        status_warn "VS Code not installed (optional)"
        ((VALIDATIONS_WARNED++))
    fi

    # Check Docker
    if command_exists docker; then
        local docker_version=$(docker --version 2>/dev/null)
        status_ok "Docker: $docker_version"

        # Check if Docker daemon is running
        if docker info >/dev/null 2>&1; then
            status_ok "Docker daemon is running"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "Docker daemon is not running"
            ((VALIDATIONS_WARNED++))
        fi
    else
        status_warn "Docker not installed (optional)"
        ((VALIDATIONS_WARNED++))
    fi

    # Check Docker Compose
    if command_exists docker-compose; then
        local compose_version=$(docker-compose --version 2>/dev/null)
        status_ok "Docker Compose: $compose_version"
        ((VALIDATIONS_PASSED++))
    else
        status_warn "Docker Compose not installed (optional)"
        ((VALIDATIONS_WARNED++))
    fi
}

validate_project_structure() {
    section "Validating Project Structure"

    local required_dirs=(
        "$HOME/Projects/data-science"
        "$HOME/Projects/data-science/notebooks"
        "$HOME/Projects/data-science/datasets"
        "$HOME/Projects/data-science/models"
        "$HOME/Projects/data-science/experiments"
    )

    for dir in "${required_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            status_ok "Directory exists: $(basename "$dir")"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "Directory missing: $(basename "$dir")"
            ((VALIDATIONS_WARNED++))
        fi
    done

    # Check README
    if [[ -f "$HOME/Projects/data-science/README.md" ]]; then
        status_ok "README.md found in project directory"
        ((VALIDATIONS_PASSED++))
    else
        status_warn "README.md not found in project directory"
        ((VALIDATIONS_WARNED++))
    fi

    # Check .gitignore
    if [[ -f "$HOME/Projects/data-science/.gitignore" ]]; then
        status_ok ".gitignore found in project directory"
        ((VALIDATIONS_PASSED++))
    else
        status_warn ".gitignore not found in project directory"
        ((VALIDATIONS_WARNED++))
    fi
}

validate_environment_variables() {
    section "Validating Environment Variables"

    local required_vars=(
        "DATA_HOME"
        "DATASETS_DIR"
        "NOTEBOOKS_DIR"
        "CONDA_HOME"
    )

    for var in "${required_vars[@]}"; do
        if [[ -n "${!var:-}" ]]; then
            status_ok "$var is set"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "$var is not set"
            ((VALIDATIONS_WARNED++))
        fi
    done

    # Check PATH includes conda
    if echo "$PATH" | grep -q "miniconda3"; then
        status_ok "PATH includes Miniconda"
        ((VALIDATIONS_PASSED++))
    else
        status_warn "PATH may not include Miniconda"
        ((VALIDATIONS_WARNED++))
    fi
}

validate_performance() {
    section "Validating Performance"

    # Check Python performance
    if command_exists python3; then
        local startup_time=$(time_command python3 -c "print('test')" 2>/dev/null)
        if (( $(echo "$startup_time < 1.0" | bc -l) )); then
            status_ok "Python startup time: ${startup_time}s"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "Python startup time: ${startup_time}s (slow)"
            ((VALIDATIONS_WARNED++))
        fi
    fi

    # Check available memory (simplified check)
    if command_exists free; then
        local total_mem=$(free -m | awk 'NR==2{printf "%.0f", $2/1024}')
        if [[ $total_mem -ge 8 ]]; then
            status_ok "Available memory: ${total_mem}GB (>= 8GB recommended)"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "Available memory: ${total_mem}GB (8GB+ recommended)"
            ((VALIDATIONS_WARNED++))
        fi
    fi

    # Check available disk space for data projects
    local data_dir="$HOME/Projects/data-science"
    if [[ -d "$data_dir" ]]; then
        local available_space=$(df -h "$data_dir" | awk 'NR==2 {print $4}')
        status_ok "Available disk space: $available_space"
        ((VALIDATIONS_PASSED++))
    fi
}

validate_gpu_support() {
    section "Validating GPU Support"

    # Check NVIDIA GPU
    if command_exists nvidia-smi; then
        local gpu_info=$(nvidia-smi --query-gpu=name,driver_version --format=csv,noheader 2>/dev/null | head -1)
        status_ok "NVIDIA GPU detected: $gpu_info"
        ((VALIDATIONS_PASSED++))

        # Check CUDA
        if command_exists nvcc; then
            local cuda_version=$(nvcc --version | grep "release" | awk '{print $6}' | cut -c2-)
            status_ok "CUDA version: $cuda_version"
            ((VALIDATIONS_PASSED++))
        else
            status_warn "CUDA not installed (GPU acceleration unavailable)"
            ((VALIDATIONS_WARNED++))
        fi
    else
        status_info "No NVIDIA GPU detected (CPU-only mode)"
    fi

    # Check TensorFlow GPU support
    if [[ -d "$HOME/miniconda3/envs/datascience" ]]; then
        source "$HOME/miniconda3/bin/activate" datascience 2>/dev/null || true

        if python -c "import tensorflow as tf; print('GPU Available:', tf.config.list_physical_devices('GPU'))" 2>/dev/null; then
            status_ok "TensorFlow GPU support available"
            ((VALIDATIONS_PASSED++))
        else
            status_info "TensorFlow GPU support not available"
        fi

        conda deactivate 2>/dev/null || true
    fi
}

# Print validation summary
print_validation_summary() {
    echo -e "\n${WHITE}=== Data Science Environment Validation Summary ===${NC}"
    echo "Total validations: $((VALIDATIONS_PASSED + VALIDATIONS_WARNED + VALIDATIONS_FAILED))"
    echo -e "  ${GREEN}Passed: $VALIDATIONS_PASSED${NC}"
    echo -e "  ${YELLOW}Warnings: $VALIDATIONS_WARNED${NC}"
    echo -e "  ${RED}Failed: $VALIDATIONS_FAILED${NC}"

    if [[ $VALIDATIONS_FAILED -eq 0 ]]; then
        if [[ $VALIDATIONS_WARNED -eq 0 ]]; then
            echo -e "\n${GREEN}🎉 All validations passed! Your data science environment is ready.${NC}"
        else
            echo -e "\n${YELLOW}⚠ Environment is functional but has some warnings.${NC}"
            echo "Consider addressing the warnings for optimal experience."
        fi
        return 0
    else
        echo -e "\n${RED}❌ Critical issues found! Please address the failed validations.${NC}"
        echo "Run the setup script again or manually install missing components."
        return 1
    fi
}

# Main validation function
main() {
    section "Data Science Environment Validation"
    log_info "Checking that all data science components are properly installed and configured..."

    # Run all validations
    validate_python_environment
    validate_core_packages
    validate_jupyter
    validate_r_environment
    validate_databases
    validate_ml_frameworks
    validate_development_tools
    validate_project_structure
    validate_environment_variables
    validate_performance
    validate_gpu_support

    # Print summary
    print_validation_summary
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi