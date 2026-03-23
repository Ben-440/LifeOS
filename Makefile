.PHONY: help install backend-dev backend-build backend-clean ios-build macos-build test clean all

help:
	@echo "Finance Tracker - Development Commands"
	@echo ""
	@echo "Backend:"
	@echo "  make backend-dev          Start backend in development mode"
	@echo "  make backend-build        Build backend for production"
	@echo "  make backend-clean        Clean backend build artifacts"
	@echo ""
	@echo "Database:"
	@echo "  make db-reset            Reset database (WARNING: destroys data)"
	@echo "  make db-query            Query database with sqlite3"
	@echo ""
	@echo "Testing:"
	@echo "  make test                Run backend tests"
	@echo "  make lint                Lint backend code"
	@echo ""
	@echo "Utilities:"
	@echo "  make install             Install all dependencies"
	@echo "  make clean               Clean all build artifacts"
	@echo "  make setup               Full project setup"
	@echo ""

install:
	@echo "Installing backend dependencies..."
	cd backend && npm install
	@echo "✓ Dependencies installed"

backend-dev:
	@echo "Starting backend in development mode..."
	cd backend && npm run dev

backend-build:
	@echo "Building backend..."
	cd backend && npm run build
	@echo "✓ Build complete"

backend-clean:
	@echo "Cleaning backend..."
	rm -rf backend/dist
	rm -rf backend/node_modules
	@echo "✓ Backend cleaned"

db-reset:
	@echo "Reset database? This will destroy all data!"
	@read -p "Type 'yes' to confirm: " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		rm -f backend/finance_tracker.db; \
		echo "✓ Database reset"; \
	else \
		echo "✗ Cancelled"; \
	fi

db-query:
	sqlite3 backend/finance_tracker.db

test:
	@echo "Running tests..."
	cd backend && npm test

lint:
	@echo "Linting backend..."
	cd backend && npm run lint 2>/dev/null || echo "No linter configured"

clean:
	@echo "Cleaning project..."
	make backend-clean
	rm -rf .DS_Store
	find . -name "*.swiftpm" -type d -exec rm -rf {} + 2>/dev/null || true
	@echo "✓ Project cleaned"

setup: install
	@echo ""
	@echo "✓ Project setup complete!"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Start backend:  make backend-dev"
	@echo "  2. Open iOS:       open ios/FinanceTrackerApp.swift"
	@echo "  3. Open macOS:     open macos/FinanceTrackerMacApp.swift"
	@echo ""
	@echo "See QUICKSTART.md for more info!"

.DEFAULT_GOAL := help
