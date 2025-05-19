#!/bin/bash

# Deployment script for Todo List application
# This script can be used to deploy the application to different environments

# Usage: ./deploy.sh [environment]
# Where environment is either "dev" or "prod"

set -e  # Exit on error

ENVIRONMENT=${1:-dev}  # Default to dev if no argument provided
TIMESTAMP=$(date +%Y%m%d%H%M%S)

echo "Starting deployment to $ENVIRONMENT environment..."

# Validate environment argument
if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "prod" ]]; then
    echo "Error: Environment must be either 'dev' or 'prod'"
    exit 1
fi

# Create a deployment package
echo "Creating deployment package..."
mkdir -p deploy
cp *.html deploy/
cp *.js deploy/
cp *.css deploy/
cp *.png deploy/
cp *.ico deploy/ 2>/dev/null || echo "No favicon found, skipping..."

# Environment-specific configurations
if [[ "$ENVIRONMENT" == "dev" ]]; then
    echo "Applying development-specific configurations..."
    # Example: Set development API endpoints or enable debug features
    # sed -i 's/production-api.example.com/dev-api.example.com/g' deploy/script.js
elif [[ "$ENVIRONMENT" == "prod" ]]; then
    echo "Applying production-specific configurations..."
    # Example: Minify CSS and JS files for production
    # If you have minification tools installed, uncomment these lines
    # npx uglifyjs deploy/script.js -o deploy/script.min.js
    # npx cleancss deploy/style.css -o deploy/style.min.css
    # mv deploy/script.min.js deploy/script.js
    # mv deploy/style.min.css deploy/style.css
fi

# Create a version file for tracking deployment
echo "Environment: $ENVIRONMENT" > deploy/version.txt
echo "Timestamp: $TIMESTAMP" >> deploy/version.txt
echo "Commit: $(git rev-parse HEAD)" >> deploy/version.txt

echo "Deployment package created successfully!"

# In a real-world scenario, you would deploy to your hosting provider here
# Examples:
if [[ "$ENVIRONMENT" == "dev" ]]; then
    echo "Deploying to development server..."
    # Example: AWS S3 deployment for dev
    # aws s3 sync deploy/ s3://your-dev-bucket/ --delete
    
    # Example: Azure deployment for dev
    # az storage blob upload-batch -d your-dev-container -s deploy/
    
    # Example: Netlify deployment for dev
    # npx netlify deploy --dir=deploy/
elif [[ "$ENVIRONMENT" == "prod" ]]; then
    echo "Deploying to production server..."
    # Example: AWS S3 deployment for production
    # aws s3 sync deploy/ s3://your-prod-bucket/ --delete
    
    # Example: Azure deployment for production
    # az storage blob upload-batch -d your-prod-container -s deploy/
    
    # Example: Netlify production deployment
    # npx netlify deploy --dir=deploy/ --prod
fi

echo "Deployment to $ENVIRONMENT completed successfully!"
