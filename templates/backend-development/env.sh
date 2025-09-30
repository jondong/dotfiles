#!/bin/bash

# Environment variables for Backend Development Template

# Node.js configuration
export NODE_ENV=development
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"
export NODE_OPTIONS="--max-old-space-size=4096"

# Node.js version manager support
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    source "$NVM_DIR/nvm.sh"
fi

# Yarn configuration
export YARN_CONFIG_PREFIX="$HOME/.yarn-global"
export PATH="$YARN_CONFIG_PREFIX/bin:$PATH"

# pnpm configuration
export PNPM_HOME="$HOME/.pnpm-global"
export PATH="$PNPM_HOME:$PATH"

# Python configuration
export PYTHONPATH="${PYTHONPATH}:$HOME/Projects/backend"
export PYTHONIOENCODING="utf-8"
export PYTHONDONTWRITEBYTECODE=1
export PYTHON_VENV_NAME="backend"

# Virtual environment
export VIRTUAL_ENV="$HOME/.venvs/backend"
if [[ -d "$VIRTUAL_ENV" ]]; then
    export PATH="$VIRTUAL_ENV/bin:$PATH"
fi

# Go configuration
export GOPATH="$HOME/go"
export GOROOT="/usr/local/go"
export PATH="$GOPATH/bin:$GOROOT/bin:$PATH"
export GO111MODULE=on
export GOPROXY="https://proxy.golang.org,direct"
export GOSUMDB="sum.golang.org"

# Java configuration
export JAVA_HOME="/Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home"
export MAVEN_HOME="/opt/homebrew/bin/mvn"
export GRADLE_HOME="$HOME/.gradle"
export PATH="$JAVA_HOME/bin:$MAVEN_HOME/bin:$GRADLE_HOME/bin:$PATH"
export M2_HOME="$HOME/.m2"
export M2_REPO="$M2_HOME/repository"

# Rust configuration
export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"
export PATH="$CARGO_HOME/bin:$PATH"
export RUST_BACKTRACE=1
export RUST_LOG=info

# Backend directories
export BACKEND_HOME="$HOME/Projects/backend"
export APIS_DIR="$BACKEND_HOME/apis"
export SERVICES_DIR="$BACKEND_HOME/services"
export MICROSERVICES_DIR="$BACKEND_HOME/microservices"
export DATABASES_DIR="$BACKEND_HOME/databases"
export DEPLOYMENTS_DIR="$BACKEND_HOME/deployments"
export MONITORING_DIR="$BACKEND_HOME/monitoring"

# Development server ports
export API_DEV_PORT=3000
export API_PROD_PORT=8080
export NODE_API_PORT=3000
export PYTHON_API_PORT=8000
export GO_API_PORT=8080
export JAVA_API_PORT=8080
export RUST_API_PORT=8000

# Database configurations
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
export POSTGRES_USER=backenddev
export POSTGRES_PASSWORD=backenddev
export POSTGRES_DB=backend_dev

export REDIS_HOST=localhost
export REDIS_PORT=6379
export REDIS_PASSWORD=""

export MONGO_URI="mongodb://localhost:27017/backend_dev"
export MONGO_HOST=localhost
export MONGO_PORT=27017
export MONGO_USER=""
export MONGO_PASSWORD=""

# Message queue configurations
export RABBITMQ_HOST=localhost
export RABBITMQ_PORT=5672
export RABBITMQ_USER=guest
export RABBITMQ_PASSWORD=guest
export RABBITMQ_VHOST="/"

export KAFKA_BOOTSTRAP_SERVERS="localhost:9092"
export KAFKA_GROUP_ID="backend-group"

# Container and orchestration
export DOCKER_HOST="unix:///var/run/docker.sock"
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export KUBECONFIG="$HOME/.kube/config"

# API development
export API_BASE_URL="http://localhost:$API_DEV_PORT/api"
export GRAPHQL_ENDPOINT="http://localhost:$API_DEV_PORT/graphql"
export OPENAPI_SPEC="http://localhost:$API_DEV_PORT/docs"

# Security
export JWT_SECRET="your-super-secret-jwt-key-change-in-production"
export JWT_EXPIRES_IN="24h"
export BCRYPT_ROUNDS=12
export CORS_ORIGIN="http://localhost:3000"

# Database connection strings
export DATABASE_URL="postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB"
export REDIS_URL="redis://$REDIS_HOST:$REDIS_PORT"
export MONGODB_URL="$MONGO_URI"

# Cloud configurations
export AWS_DEFAULT_REGION=us-west-2
export AWS_CONFIG_FILE="$HOME/.aws/config"
export AWS_SHARED_CREDENTIALS_FILE="$HOME/.aws/credentials"

export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.google/service-account.json"
export GCLOUD_PROJECT="backend-development"

# Performance and monitoring
export PROMETHEUS_PORT=9090
export GRAFANA_PORT=3001
export JAEGER_ENDPOINT="http://localhost:14268/api/traces"
export LOG_LEVEL="debug"
export LOG_FORMAT="json"

# Testing
export TEST_DATABASE_URL="postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/${POSTGRES_DB}_test"
export TEST_REDIS_URL="redis://$REDIS_HOST:6380"
export TEST_MONGODB_URL="mongodb://localhost:27017/backend_test"

# Development tools
export EDITOR="code"
export BROWSER="chrome"
export TERMINAL="alacritty"

# Development aliases
alias be-cd="cd $BACKEND_HOME"
alias be-apis="cd $APIS_DIR"
alias be-services="cd $SERVICES_DIR"
alias be-microservices="cd $MICROSERVICES_DIR"
alias be-databases="cd $DATABASES_DIR"
alias be-deployments="cd $DEPLOYMENTS_DIR"
alias be-monitoring="cd $MONITORING_DIR"

# Node.js aliases
alias be-node-dev="npm run dev"
alias be-node-build="npm run build"
alias be-node-start="npm start"
alias be-node-test="npm test"
alias be-node-lint="npm run lint"
alias be-node-format="npm run format"
alias be-node-clean="rm -rf node_modules package-lock.json && npm install"

# Python aliases
alias be-python-dev="uvicorn main:app --reload --host 0.0.0.0 --port $PYTHON_API_PORT"
alias be-python-start="gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:$PYTHON_API_PORT"
alias be-python-test="pytest"
alias be-python-lint="flake8 ."
alias be-python-format="black . && isort ."
alias be-python-venv="source $VIRTUAL_ENV/bin/activate"
alias be-python-venv-create="python -m venv $VIRTUAL_ENV"

# Go aliases
alias be-go-dev="air"
alias be-go-build="go build -o bin/app ."
alias be-go-run="go run ."
alias be-go-test="go test ./..."
alias be-go-lint="golangci-lint run"
alias be-go-format="goimports -w ."
alias be-go-mod="go mod tidy && go mod vendor"

# Java aliases
alias be-java-dev="mvn spring-boot:run"
alias be-java-build="mvn clean package"
alias be-java-test="mvn test"
alias be-java-compile="mvn compile"
alias be-java-clean="mvn clean"
alias be-gradle-dev="gradle bootRun"
alias be-gradle-build="gradle build"
alias be-gradle-test="gradle test"

# Rust aliases
alias be-rust-dev="cargo run"
alias be-rust-build="cargo build"
alias be-rust-release="cargo build --release"
alias be-rust-test="cargo test"
alias be-rust-lint="cargo clippy"
alias be-rust-format="cargo fmt"
alias be-rust-check="cargo check"

# Database aliases
alias be-pg-start="brew services start postgresql || sudo systemctl start postgresql"
alias be-pg-stop="brew services stop postgresql || sudo systemctl stop postgresql"
alias be-pg-connect="psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB"
alias be-redis-start="brew services start redis || sudo systemctl start redis"
alias be-redis-stop="brew services stop redis || sudo systemctl stop redis"
alias be-redis-cli="redis-cli -h $REDIS_HOST -p $REDIS_PORT"
alias be-mongo-start="brew services start mongodb-community || sudo systemctl start mongod"
alias be-mongo-stop="brew services stop mongodb-community || sudo systemctl stop mongod"
alias be-mongo-connect="mongo $MONGO_URI"

# Message queue aliases
alias be-rabbitmq-start="brew services start rabbitmq || sudo systemctl start rabbitmq-server"
alias be-rabbitmq-stop="brew services stop rabbitmq || sudo systemctl stop rabbitmq-server"
alias be-kafka-start="brew services start kafka || sudo systemctl start kafka"

# Container aliases
alias be-docker-up="docker-compose up -d"
alias be-docker-down="docker-compose down"
alias be-docker-logs="docker-compose logs -f"
alias be-docker-build="docker-compose build"
alias be-docker-ps="docker-compose ps"

# API testing aliases
alias be-api-test="curl -X GET $API_BASE_URL/health"
alias be-api-docs="open $OPENAPI_SPEC"
alias be-postman="open -a Postman"

# Monitoring aliases
alias be-prometheus-start="docker run -d -p $PROMETHEUS_PORT:9090 prom/prometheus"
alias be-grafana-start="docker run -d -p $GRAFANA_PORT:3000 grafana/grafana"

# Port checking
alias be-ports="lsof -i :$API_DEV_PORT -i :$API_PROD_PORT -i :$POSTGRES_PORT -i :$REDIS_PORT -i :$MONGO_PORT"

# Process management
alias be-kill-node="pkill -f node"
alias be-kill-python="pkill -f python"
alias be-kill-go="pkill -f 'go run'"
alias be-kill-java="pkill -f java"
alias be-kill-rust="pkill -f 'cargo run'"

# Project creation templates
be-create-node-api() {
    local project_name=$1
    if [[ -z "$project_name" ]]; then
        echo "Usage: be-create-node-api <project-name>"
        return 1
    fi

    mkdir -p "$APIS_DIR/$project_name"
    cd "$APIS_DIR/$project_name"
    npm init -y
    npm install express cors helmet morgan compression
    npm install -D nodemon typescript @types/node @types/express ts-node
    echo "Node.js API project '$project_name' created!"
}

be-create-python-api() {
    local project_name=$1
    if [[ -z "$project_name" ]]; then
        echo "Usage: be-create-python-api <project-name>"
        return 1
    fi

    mkdir -p "$APIS_DIR/$project_name"
    cd "$APIS_DIR/$project_name"
    python -m venv .
    source bin/activate
    pip install fastapi uvicorn sqlalchemy alembic psycopg2-binary
    echo "Python API project '$project_name' created!"
}

be-create-go-api() {
    local project_name=$1
    if [[ -z "$project_name" ]]; then
        echo "Usage: be-create-go-api <project-name>"
        return 1
    fi

    mkdir -p "$APIS_DIR/$project_name"
    cd "$APIS_DIR/$project_name"
    go mod init "$project_name"
    go get github.com/gin-gonic/gin github.com/gin-gonic/gin github.com/jmoiron/sqlx github.com/lib/pq
    echo "Go API project '$project_name' created!"
}

# Quick start command
be-quick-start() {
    echo "🚀 Starting Backend Development Environment..."

    # Start databases
    be-pg-start
    be-redis-start

    # Start message queues
    be-rabbitmq-start

    # Set up environment
    if [[ -d "$VIRTUAL_ENV" ]]; then
        be-python-venv
    fi

    echo "✅ Backend Development Environment is ready!"
    echo "🔗 API Base URL: $API_BASE_URL"
    echo "🗄️  Databases: PostgreSQL ($POSTGRES_HOST:$POSTGRES_PORT), Redis ($REDIS_HOST:$REDIS_PORT)"
    echo "📊 Monitoring: http://localhost:$GRAFANA_PORT"
}

echo "Backend development environment variables loaded!"
echo "Template: backend-development"