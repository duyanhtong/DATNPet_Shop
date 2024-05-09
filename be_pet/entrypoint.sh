#!/bin/bash

# Run migrations
npm run migration:run

# Start the application
exec "$@"
