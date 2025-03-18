.PHONY: test test.setup test.cleanup

# Run all tests
test: test.setup
	@./scripts/test.sh

# Run specific test file
test.%: test.setup
	@./scripts/test.sh test/$*.exs

# Setup test environment
test.setup:
	@echo "Setting up test environment..."
	@docker-compose up -d postgres

# Clean up test environment
test.cleanup:
	@echo "Cleaning up test environment..."
	@./scripts/cleanup.sh

# Help command
help:
	@echo "Available commands:"
	@echo "  make test          - Run all tests"
	@echo "  make test.storage  - Run storage_test.exs"
	@echo "  make test.argument - Run argument_test.exs"
	@echo "  make test.postgres - Run postgres_test.exs"
	@echo "  make test.cleanup  - Clean up test environment"
