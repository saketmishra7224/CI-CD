# Deployment script for Todo List application
# This script can be used to deploy the application to different environments

# Usage: .\deploy.ps1 [environment]
# Where environment is either "dev" or "prod"

param (
    [string]$Environment = "dev"  # Default to dev if no argument provided
)

$Timestamp = Get-Date -Format "yyyyMMddHHmmss"

Write-Host "Starting deployment to $Environment environment..." -ForegroundColor Cyan

# Validate environment argument
if ($Environment -ne "dev" -and $Environment -ne "prod") {
    Write-Host "Error: Environment must be either 'dev' or 'prod'" -ForegroundColor Red
    exit 1
}

# Create a deployment package
Write-Host "Creating deployment package..." -ForegroundColor Cyan
New-Item -Path "deploy" -ItemType Directory -Force | Out-Null
Copy-Item -Path "*.html" -Destination "deploy\" -Force
Copy-Item -Path "*.js" -Destination "deploy\" -Force
Copy-Item -Path "*.css" -Destination "deploy\" -Force
Copy-Item -Path "*.png" -Destination "deploy\" -Force
Copy-Item -Path "*.ico" -Destination "deploy\" -ErrorAction SilentlyContinue

# Environment-specific configurations
if ($Environment -eq "dev") {
    Write-Host "Applying development-specific configurations..." -ForegroundColor Cyan
    # Example: Set development API endpoints or enable debug features
    # (Get-Content "deploy\script.js") -replace "production-api.example.com", "dev-api.example.com" | Set-Content "deploy\script.js"
} elseif ($Environment -eq "prod") {
    Write-Host "Applying production-specific configurations..." -ForegroundColor Cyan
    # Example: Minify CSS and JS files for production
    # If you have minification tools installed, uncomment these lines
    # npx uglifyjs deploy/script.js -o deploy/script.min.js
    # npx cleancss deploy/style.css -o deploy/style.min.css
    # Move-Item -Path "deploy\script.min.js" -Destination "deploy\script.js" -Force
    # Move-Item -Path "deploy\style.min.css" -Destination "deploy\style.css" -Force
}

# Create a version file for tracking deployment
"Environment: $Environment" | Out-File -FilePath "deploy\version.txt"
"Timestamp: $Timestamp" | Out-File -FilePath "deploy\version.txt" -Append
"Commit: $(git rev-parse HEAD)" | Out-File -FilePath "deploy\version.txt" -Append

Write-Host "Deployment package created successfully!" -ForegroundColor Green

# In a real-world scenario, you would deploy to your hosting provider here
# Examples:
if ($Environment -eq "dev") {
    Write-Host "Deploying to development server..." -ForegroundColor Cyan
    # Example: AWS S3 deployment for dev
    # aws s3 sync deploy/ s3://your-dev-bucket/ --delete
    
    # Example: Azure deployment for dev
    # az storage blob upload-batch -d your-dev-container -s deploy/
    
    # Example: Netlify deployment for dev
    # npx netlify deploy --dir=deploy/
} elseif ($Environment -eq "prod") {
    Write-Host "Deploying to production server..." -ForegroundColor Cyan
    # Example: AWS S3 deployment for production
    # aws s3 sync deploy/ s3://your-prod-bucket/ --delete
    
    # Example: Azure deployment for production
    # az storage blob upload-batch -d your-prod-container -s deploy/
    
    # Example: Netlify production deployment
    # npx netlify deploy --dir=deploy/ --prod
}

Write-Host "Deployment to $Environment completed successfully!" -ForegroundColor Green
