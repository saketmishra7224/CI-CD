#!/bin/bash
# Simple script to deploy the application to a server
# Usage: ./deploy.sh [destination_server]

# Build the project
echo "Building project..."
npm run build

# Default to production if no argument provided
DESTINATION=${1:-production}

if [ "$DESTINATION" == "production" ]; then
  echo "Deploying to production server..."
  # Replace with your production server deployment commands
  # Example: scp -r dist/* user@production-server:/var/www/html/
elif [ "$DESTINATION" == "development" ]; then
  echo "Deploying to development server..."
  # Replace with your development server deployment commands
  # Example: scp -r dist/* user@dev-server:/var/www/html/
else
  echo "Unknown destination: $DESTINATION"
  echo "Usage: ./deploy.sh [production|development]"
  exit 1
fi

echo "Deployment complete!"
