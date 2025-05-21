#!/bin/bash

# Deployment script for Todo List application
# This script can be used to deploy the application to different environments

# Usage: ./deploy.sh [environment] [deploy-target]
# Where environment is either "dev" or "prod"
# Where deploy-target is one of: local, azure, aws, github-pages (defaults to local)

set -e  # Exit on error

ENVIRONMENT=${1:-dev}  # Default to dev if no argument provided
DEPLOY_TARGET=${2:-local}  # Default to local if no target provided
TIMESTAMP=$(date +%Y%m%d%H%M%S)

echo "Starting deployment to $ENVIRONMENT environment on $DEPLOY_TARGET..."

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
    
    # Add development environment configuration file
    cat > deploy/config.json << EOF
{
    "env": "development",
    "apiEndpoint": "https://dev-api.example.com",
    "loggingLevel": "debug",
    "features": {
        "enableDebugTools": true,
        "mockAuth": true
    }
}
EOF
    
elif [[ "$ENVIRONMENT" == "prod" ]]; then
    echo "Applying production-specific configurations..."
    # Example: Minify CSS and JS files for production
    if [ -d "node_modules" ]; then
        echo "Minifying assets for production..."
        npm run build
        cp -r build/* deploy/
    fi
    
    # Add production environment configuration file
    cat > deploy/config.json << EOF
{
    "env": "production",
    "apiEndpoint": "https://api.example.com",
    "loggingLevel": "error",
    "features": {
        "enableDebugTools": false,
        "mockAuth": false
    }
}
EOF
fi

# Create a version file for tracking deployment
echo "Environment: $ENVIRONMENT" > deploy/version.txt
echo "Timestamp: $TIMESTAMP" >> deploy/version.txt
echo "Commit: $(git rev-parse HEAD)" >> deploy/version.txt

# Deploy to the specified target
case "$DEPLOY_TARGET" in
    "local")
        echo "Deploying to local directory..."
        DEPLOY_PATH="./deployed-$ENVIRONMENT"
        mkdir -p "$DEPLOY_PATH"
        cp -r deploy/* "$DEPLOY_PATH"
        echo "Deployed to $DEPLOY_PATH"
        ;;
        
    "azure")
        echo "Deploying to Azure..."
        # Check for Azure CLI installation
        if ! command -v az &> /dev/null; then
            echo "Azure CLI not found. Please install Azure CLI first."
            exit 1
        fi
        
        # Deploy to Azure Static Web Apps or App Service
        # This example uses Azure Storage static website hosting
        STORAGE_ACCOUNT=$([ "$ENVIRONMENT" == "dev" ] && echo "todoappdevstatic" || echo "todoapprodstatic")
        
        echo "Deploying to Azure Storage account: $STORAGE_ACCOUNT"
        echo "az storage blob upload-batch -s deploy -d \$web --account-name $STORAGE_ACCOUNT"
        # Uncomment to actually deploy:
        # az storage blob upload-batch -s deploy -d '$web' --account-name $STORAGE_ACCOUNT
        
        echo "Deployed to Azure Storage static website: https://$STORAGE_ACCOUNT.z13.web.core.windows.net/"
        ;;
        
    "aws")
        echo "Deploying to AWS S3..."
        # Check for AWS CLI installation
        if ! command -v aws &> /dev/null; then
            echo "AWS CLI not found. Please install AWS CLI first."
            exit 1
        fi
        
        # Deploy to AWS S3 bucket
        S3_BUCKET=$([ "$ENVIRONMENT" == "dev" ] && echo "todo-app-dev" || echo "todo-app-prod")
        
        echo "Deploying to S3 bucket: $S3_BUCKET"
        echo "aws s3 sync deploy s3://$S3_BUCKET --delete"
        # Uncomment to actually deploy:
        # aws s3 sync deploy s3://$S3_BUCKET --delete
        
        # If CloudFront is used, invalidate cache
        # DISTRIBUTION_ID=$([ "$ENVIRONMENT" == "dev" ] && echo "DEV_DISTRIBUTION_ID" || echo "PROD_DISTRIBUTION_ID")
        # aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
        
        echo "Deployed to AWS S3: http://$S3_BUCKET.s3-website-us-east-1.amazonaws.com/"
        ;;
        
    "github-pages")
        echo "Deploying to GitHub Pages..."
        # This would typically be done via GitHub Actions
        # But for manual deployment, we can push to the gh-pages branch
        
        echo "For GitHub Pages deployment, use the GitHub Actions workflow instead."
        echo "Manual deployment to gh-pages branch can be implemented if needed."
        ;;
        
    *)
        echo "Unknown deployment target: $DEPLOY_TARGET"
        echo "Supported targets: local, azure, aws, github-pages"
        exit 1
        ;;
esac

echo "Deployment completed successfully!"
