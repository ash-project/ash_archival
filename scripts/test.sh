#!/bin/bash
set -e

# Start the PostgreSQL container
echo "Starting PostgreSQL container..."
docker-compose up -d postgres

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
until docker-compose exec -T postgres pg_isready -U postgres; do
  echo "PostgreSQL is not ready yet... waiting"
  sleep 2
done
echo "PostgreSQL is ready!"

# Create and migrate the test database
echo "Setting up test database..."
MIX_ENV=test mix test.create
MIX_ENV=test mix test.migrate

# Run the tests
echo "Running tests..."
if [ "$1" ]; then
  MIX_ENV=test mix test "$@"
else
  MIX_ENV=test mix test
fi

# Optionally, stop the container after tests
# Uncomment the following line if you want to stop the container after tests
# docker-compose down
