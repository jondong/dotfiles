#!/bin/bash

# Environment variables for Web Development Template

# Node.js and npm configuration
export NODE_ENV=development
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"

# Yarn configuration
export YARN_CONFIG_PREFIX="$HOME/.yarn-global"
export PATH="$YARN_CONFIG_PREFIX/bin:$PATH"

# pnpm configuration
export PNPM_HOME="$HOME/.pnpm-global"
export PATH="$PNPM_HOME:$PATH"

# Web development tools
export CHROME_BIN="/usr/bin/google-chrome"
export CHROME_PATH="/usr/bin/google-chrome"
export FIREFOX_BIN="/usr/bin/firefox"

# Database connection variables (for local development)
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=postgres
export POSTGRES_DB=webdev

export REDIS_HOST=localhost
export REDIS_PORT=6379

export MONGO_URI="mongodb://localhost:27017/webdev"

# Development server ports
export REACT_APP_PORT=3000
export VUE_APP_PORT=8080
export NG_PORT=4200
export EXPRESS_PORT=5000
export FASTIFY_PORT=3000
export KOA_PORT=3000

# Docker development
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Browser testing
export SELENIUM_REMOTE_URL="http://localhost:4444/wd/hub"
export CYPRESS_BASE_URL="http://localhost:3000"

# API endpoints (for development)
export API_BASE_URL="http://localhost:5000/api"
export GRAPHQL_ENDPOINT="http://localhost:5000/graphql"

# Frontend build tools
export NODE_OPTIONS="--max-old-space-size=4096"
export GENERATE_SOURCEMAP=true
export TSC_COMPILE_ON_ERROR=false

# Code quality
export ESLINT_NO_DEV_ERRORS=true
export PRETTIER_IGNORE_PATH=".gitignore"

# Git hooks
export HUSKY=0
export LINT_STAGED=true

# Development tools
export EDITOR="code"
export BROWSER="chrome"

# Local development domains
export LOCAL_DOMAIN="localhost"
export DEV_DOMAIN="dev.local"

# SSL certificates (for local HTTPS)
export SSL_CERT_PATH="$HOME/.ssl/cert.pem"
export SSL_KEY_PATH="$HOME/.ssl/key.pem"

# Performance monitoring
export BUNDLE_ANALYZE=false
export SPEED_MEASURE=false

# Hot module replacement
export FAST_REFRESH=true
export LIVE_RELOAD=true

# Debug flags
export DEBUG="app:*"
export LOG_LEVEL="debug"

# Development shortcuts
alias dev-run="npm run dev"
alias dev-build="npm run build"
alias dev-test="npm run test"
alias dev-lint="npm run lint"
alias dev-format="npm run format"
alias dev-clean="rm -rf node_modules package-lock.json && npm install"

# Docker aliases
alias dev-docker-up="docker-compose up -d"
alias dev-docker-down="docker-compose down"
alias dev-docker-logs="docker-compose logs -f"

# Database aliases
alias dev-pg-start="brew services start postgresql || sudo systemctl start postgresql"
alias dev-pg-stop="brew services stop postgresql || sudo systemctl stop postgresql"
alias dev-redis-start="brew services start redis || sudo systemctl start redis"
alias dev-redis-stop="brew services stop redis || sudo systemctl stop redis"

# Port checking
alias dev-ports="lsof -i :3000 -i :8080 -i :5000 -i :5432 -i :6379"

# Process management
alias dev-kill-node="pkill -f node"
alias dev-kill-npm="pkill -f npm"

# Template specific aliases
alias web-init="npx create-react-app . --template typescript"
alias vue-init="npx @vue/cli create ."
alias angular-init="ng new ."
alias next-init="npx create-next-app ."
alias nuxt-init="npx create-nuxt-app ."

echo "Web development environment variables loaded!"
echo "Template: web-development"