.PHONY: help install dev dev-worker build start start-worker test lint format clean \
        docker-build docker-up docker-down docker-logs docker-restart docker-clean \
        db-setup db-migrate env-setup

help:
	@echo "╔════════════════════════════════════════════════════════════════╗"
	@echo "║                    EWSDB4 - Makefile Commands                  ║"
	@echo "╚════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "📦 Setup & Installation:"
	@echo "  make install         - Install dependencies"
	@echo "  make env-setup       - Create .env file from .env.example"
	@echo ""
	@echo "🚀 Development:"
	@echo "  make dev             - Run API server (port 3000)"
	@echo "  make dev-worker      - Run worker process"
	@echo "  make dev-all         - Run API + Worker in parallel"
	@echo ""
	@echo "🏗️  Build & Production:"
	@echo "  make build           - Build TypeScript to dist/"
	@echo "  make start           - Start production API server"
	@echo "  make start-worker    - Start production worker"
	@echo ""
	@echo "🧪 Testing & Quality:"
	@echo "  make test            - Run tests with coverage"
	@echo "  make test-watch      - Run tests in watch mode"
	@echo "  make lint            - Run ESLint"
	@echo "  make lint-fix        - Run ESLint with auto-fix"
	@echo "  make format          - Format code with Prettier"
	@echo "  make format-check    - Check code formatting"
	@echo "  make typecheck       - Run TypeScript type checking"
	@echo ""
	@echo "🐳 Docker Commands:"
	@echo "  make docker-build    - Build Docker images"
	@echo "  make docker-up       - Start all containers (detached)"
	@echo "  make docker-down     - Stop all containers"
	@echo "  make docker-restart  - Restart all containers"
	@echo "  make docker-logs     - View logs from all containers"
	@echo "  make docker-logs-api - View API logs"
	@echo "  make docker-logs-worker - View worker logs"
	@echo "  make docker-ps       - Show running containers"
	@echo "  make docker-clean    - Remove containers, volumes, and images"
	@echo ""
	@echo "🗄️  Database:"
	@echo "  make db-setup        - Run database setup script"
	@echo ""
	@echo "🧹 Cleanup:"
	@echo "  make clean           - Clean build artifacts"
	@echo "  make clean-all       - Clean everything (dist, node_modules, docker)"
	@echo ""

# Setup & Installation
install:
	@echo "📦 Installing dependencies..."
	npm install

env-setup:
	@if [ ! -f .env ]; then \
		echo "📝 Creating .env file from .env.example..."; \
		cp .env.example .env; \
		echo "✅ .env created. Please update with your credentials."; \
	else \
		echo "⚠️  .env already exists. Skipping..."; \
	fi

# Development
dev:
	@echo "🚀 Starting API server in development mode..."
	npm run dev

dev-worker:
	@echo "⚙️  Starting worker in development mode..."
	npm run dev:worker

dev-all:
	@echo "🚀 Starting API + Worker in parallel..."
	@make -j2 dev dev-worker

# Build & Production
build:
	@echo "🏗️  Building project..."
	npm run build

start:
	@echo "▶️  Starting production API server..."
	npm start

start-worker:
	@echo "▶️  Starting production worker..."
	npm run start:worker

# Testing & Quality
test:
	@echo "🧪 Running tests..."
	npm test

test-watch:
	@echo "🧪 Running tests in watch mode..."
	npm run test:watch

lint:
	@echo "🔍 Running ESLint..."
	npm run lint

lint-fix:
	@echo "🔧 Running ESLint with auto-fix..."
	npm run lint:fix

format:
	@echo "✨ Formatting code..."
	npm run format

format-check:
	@echo "🔍 Checking code formatting..."
	npm run format:check

typecheck:
	@echo "🔍 Running TypeScript type checking..."
	npm run typecheck

# Docker Commands
docker-build:
	@echo "🐳 Building Docker images..."
	docker-compose build

docker-up:
	@echo "🐳 Starting Docker containers..."
	docker-compose up -d
	@echo "✅ Containers started!"
	@echo "📊 API: http://localhost:3000"
	@echo "📊 RabbitMQ UI: http://localhost:15672 (admin/admin)"

docker-down:
	@echo "🛑 Stopping Docker containers..."
	docker-compose down

docker-restart:
	@echo "🔄 Restarting Docker containers..."
	docker-compose restart

docker-logs:
	@echo "📋 Viewing logs from all containers..."
	docker-compose logs -f

docker-logs-api:
	@echo "📋 Viewing API logs..."
	docker-compose logs -f app

docker-logs-worker:
	@echo "📋 Viewing worker logs..."
	docker-compose logs -f worker

docker-ps:
	@echo "📊 Running containers:"
	docker-compose ps

docker-clean:
	@echo "🧹 Cleaning Docker resources..."
	docker-compose down -v --rmi all
	@echo "✅ Docker resources cleaned!"

# Database
db-setup:
	@echo "🗄️  Setting up database..."
	@if [ -f scripts/setup-db.sql ]; then \
		mysql -h localhost -u root -p < scripts/setup-db.sql; \
		echo "✅ Database setup complete!"; \
	else \
		echo "❌ scripts/setup-db.sql not found!"; \
	fi

# Cleanup
clean:
	@echo "🧹 Cleaning build artifacts..."
	rm -rf dist coverage node_modules/.cache
	@echo "✅ Clean complete!"

clean-all: docker-clean clean
	@echo "🧹 Cleaning everything..."
	rm -rf node_modules
	@echo "✅ All clean!"
