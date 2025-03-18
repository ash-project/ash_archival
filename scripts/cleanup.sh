#!/bin/bash
set -e

echo "Stopping and removing PostgreSQL container and volumes..."
docker-compose down -v

echo "Cleanup complete!"
