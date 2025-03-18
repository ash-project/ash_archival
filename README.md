![Logo](https://github.com/ash-project/ash/blob/main/logos/cropped-for-header-black-text.png?raw=true#gh-light-mode-only)
![Logo](https://github.com/ash-project/ash/blob/main/logos/cropped-for-header-white-text.png?raw=true#gh-dark-mode-only)

![Elixir CI](https://github.com/ash-project/ash_storage/workflows/CI/badge.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Hex version badge](https://img.shields.io/hexpm/v/ash_storage.svg)](https://hex.pm/packages/ash_storage)
[![Hexdocs badge](https://img.shields.io/badge/docs-hexdocs-purple)](https://hexdocs.pm/ash_storage)

# AshStorage

AshStorage is an [Ash](https://hexdocs.pm/ash) extension that provides a push-button solution for soft deleting records, instead of destroying them.

## Tutorials

- [Get Started with AshStorage](documentation/tutorials/get-started-with-ash-storage.md)

## Topics

- [How does AshStorage work?](documentation/topics/how-does-ash-storage-work.md)
- [Unstorage](documentation/topics/unstorage.md)

## Reference

- [AshStorage DSL](documentation/dsls/DSL-AshStorage.Resource.md)

## Development

### Testing

This project uses Docker to run PostgreSQL for testing. You can use the provided scripts or Makefile commands to run tests:

#### Using the Makefile (recommended)

```bash
# Run all tests
make test

# Run specific test file
make test.storage    # Runs storage_test.exs
make test.argument   # Runs argument_test.exs
make test.postgres   # Runs postgres_test.exs

# Clean up Docker resources when done
make test.cleanup

# See all available commands
make help
```

#### Using scripts directly

```bash
# Start PostgreSQL container and run all tests
./scripts/test.sh

# Run specific test file
./scripts/test.sh test/storage_test.exs

# Clean up Docker resources when done
./scripts/cleanup.sh
```

Make sure you have Docker and Docker Compose installed on your system.
