#!/bin/bash

# Environment variables for Data Science Template

# Python environment
export PYTHONPATH="${PYTHONPATH}:$HOME/Projects/data-science"
export PYTHONIOENCODING="utf-8"
export PYTHONDONTWRITEBYTECODE=1

# Conda configuration
export CONDA_HOME="$HOME/miniconda3"
export PATH="$CONDA_HOME/bin:$PATH"
export CONDA_AUTO_UPDATE_CONDA=false
export CONDA_CHANGEPS1=true

# Jupyter configuration
export JUPYTER_CONFIG_DIR="$HOME/.jupyter"
export JUPYTER_DATA_DIR="$HOME/.local/share/jupyter"
export JUPYTER_RUNTIME_DIR="$HOME/.local/share/jupyter/runtime"
export JUPYTERLAB_DIR="$HOME/.local/share/jupyter/lab"

# Jupyter ports
export JUPYTER_PORT=8888
export JUPYTER_LAB_PORT=8889
export STREAMLIT_PORT=8501
export DASH_PORT=8050
export SHINY_PORT=3838

# R environment
export R_LIBS_USER="$HOME/R/library"
export R_LIBS_SITE="$HOME/R/site-library"
export R_PROFILE_USER="$HOME/.Rprofile"
export R_HISTSIZE=100000
export R_HISTFILE="$HOME/.Rhistory"

# Data directories
export DATA_HOME="$HOME/Projects/data-science"
export DATASETS_DIR="$DATA_HOME/datasets"
export NOTEBOOKS_DIR="$DATA_HOME/notebooks"
export MODELS_DIR="$DATA_HOME/models"
export EXPERIMENTS_DIR="$DATA_HOME/experiments"

# Database configurations
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
export POSTGRES_USER=datascientist
export POSTGRES_PASSWORD=datascience
export POSTGRES_DB=datascience

export REDIS_HOST=localhost
export REDIS_PORT=6379

export MONGO_URI="mongodb://localhost:27017/datascience"

# Cloud configurations
export AWS_DEFAULT_REGION=us-west-2
export AWS_CONFIG_FILE="$HOME/.aws/config"
export AWS_SHARED_CREDENTIALS_FILE="$HOME/.aws/credentials"

export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.google/service-account.json"
export GCLOUD_PROJECT="my-data-science-project"

# Machine learning configurations
export MLFLOW_TRACKING_URI="http://localhost:5000"
export TENSORBOARD_LOGDIR="$EXPERIMENTS_DIR/tensorboard"
export WANDB_DIR="$EXPERIMENTS_DIR/wandb"

# GPU support
export CUDA_VISIBLE_DEVICES=all
export CUDA_HOME=/usr/local/cuda
export PATH="$CUDA_HOME/bin:$PATH"
export LD_LIBRARY_PATH="$CUDA_HOME/lib64:$LD_LIBRARY_PATH"

# Performance optimizations
export OMP_NUM_THREADS=4
export MKL_NUM_THREADS=4
export NUMEXPR_NUM_THREADS=4
export OPENBLAS_NUM_THREADS=4

# Memory management
export PYTHONMALLOC=malloc
export MALLOC_TRIM_THRESHOLD_=100000

# Development tools
export EDITOR="code"
export BROWSER="chrome"

# Data visualization
export PLOTLY_RENDERER="browser"
export BOkeh_SERVER_PORT=5006

# Dask configuration
export DASK_SCHEDULER_ADDRESS="tcp://localhost:8786"
export DASK_DISTRIBUTED__COMM__TIMEOUT__CONNECT=100

# Polars configuration
export POLARS_MAX_THREADS=4

# Pandas configuration
export PANDAS_DISPLAY_MAX_ROWS=100
export PANDAS_DISPLAY_MAX_COLUMNS=50

# NumPy configuration
export NUMPY_EXPERIMENTAL_ARRAY_FUNCTION=1

# Development aliases
alias ds-cd="cd $DATA_HOME"
alias ds-notebooks="cd $NOTEBOOKS_DIR"
alias ds-datasets="cd $DATASETS_DIR"
alias ds-models="cd $MODELS_DIR"
alias ds-experiments="cd $EXPERIMENTS_DIR"

# Python environment management
alias ds-activate="source $CONDA_HOME/bin/activate datascience"
alias ds-deactivate="conda deactivate"
alias ds-env-create="conda create -n datascience python=3.11 -y"
alias ds-env-install="pip install -r requirements.txt"
alias ds-env-export="conda env export > environment.yml"

# Jupyter aliases
alias ds-jupyter="jupyter notebook --port=$JUPYTER_PORT --no-browser"
alias ds-jupyter-lab="jupyter lab --port=$JUPYTER_LAB_PORT --no-browser"
alias ds-jupyter-stop="pkill -f jupyter"

# R aliases
alias ds-r="R --vanilla"
alias ds-rstudio="open -a RStudio"

# Database aliases
alias ds-pg-start="brew services start postgresql || sudo systemctl start postgresql"
alias ds-pg-stop="brew services stop postgresql || sudo systemctl stop postgresql"
alias ds-redis-start="brew services start redis || sudo systemctl start redis"
alias ds-redis-stop="brew services stop redis || sudo systemctl stop redis"

# MLflow aliases
alias ds-mlflow="mlflow ui"
alias ds-mlflow-stop="pkill -f mlflow"

# TensorBoard aliases
alias ds-tensorboard="tensorboard --logdir=$TENSORBOARD_LOGDIR"
alias ds-tensorboard-stop="pkill -f tensorboard"

# Streamlit aliases
alias ds-streamlit="streamlit run"
alias ds-streamlit-stop="pkill -f streamlit"

# Dataset aliases
alias ds-dataset-info="ls -la $DATASETS_DIR"
alias ds-dataset-download="wget -P $DATASETS_DIR"

# Model aliases
alias ds-model-list="ls -la $MODELS_DIR"
alias ds-model-clean="find $MODELS_DIR -name '*.pkl' -mtime +30 -delete"

# Utility aliases
alias ds-clean="find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null; find . -name '*.pyc' -delete"
alias ds-deps-update="pip install --upgrade -r requirements.txt"
alias ds-deps-check="pip-check"
alias ds-port-check="lsof -i :8888 -i :8889 -i :8501 -i :8050"

# Project creation template
alias ds-project-create="mkdir -p {data,notebooks,src,tests,models,outputs,docs} && touch README.md requirements.txt .gitignore"

# Quick start commands
ds-quick-start() {
    echo "🚀 Starting Data Science Environment..."

    # Start databases if needed
    if ! pgrep postgres > /dev/null; then
        echo "📊 Starting PostgreSQL..."
        ds-pg-start
    fi

    if ! pgrep redis-server > /dev/null; then
        echo "🔴 Starting Redis..."
        ds-redis-start
    fi

    # Activate conda environment
    if command -v conda > /dev/null; then
        if conda env list | grep -q "datascience"; then
            echo "🐍 Activating conda environment..."
            ds-activate
        else
            echo "📦 Creating conda environment..."
            ds-env-create
            ds-activate
        fi
    fi

    # Start Jupyter Lab
    echo "📓 Starting Jupyter Lab..."
    ds-jupyter-lab &

    echo "✅ Data Science Environment is ready!"
    echo "🌐 Jupyter Lab: http://localhost:$JUPYTER_LAB_PORT"
    echo "📊 Datasets: $DATASETS_DIR"
    echo "📓 Notebooks: $NOTEBOOKS_DIR"
}

echo "Data science environment variables loaded!"
echo "Template: data-science"