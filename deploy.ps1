# Deployment script for Todo List application
# This script can be used to deploy the application to different environments

# Usage: .\deploy.ps1 [environment]
# Where environment is either "dev" or "prod"

param (
    [string]$Environment = "dev",  # Default to dev if no argument provided
    [string]$DeployTarget = "local" # Default to local if no target provided
    # Other targets could be: "azure", "aws", "netlify", "github-pages"
)

$Timestamp = Get-Date -Format "yyyyMMddHHmmss"

Write-Host "Starting deployment to $Environment environment on $DeployTarget..." -ForegroundColor Cyan

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
    
    # Add development environment configuration file
    @{
        "env" = "development";
        "apiEndpoint" = "https://dev-api.example.com";
        "loggingLevel" = "debug";
        "features" = @{
            "enableDebugTools" = $true;
            "mockAuth" = $true;
        }
    } | ConvertTo-Json | Set-Content "deploy\config.json"
    
} elseif ($Environment -eq "prod") {
    Write-Host "Applying production-specific configurations..." -ForegroundColor Cyan
    # Example: Minify CSS and JS files for production
    if (Test-Path node_modules) {
        Write-Host "Minifying assets for production..." -ForegroundColor Cyan
        npm run build
        Copy-Item -Path "build\*" -Destination "deploy\" -Recurse -Force
    }
    
    # Add production environment configuration file
    @{
        "env" = "production";
        "apiEndpoint" = "https://api.example.com";
        "loggingLevel" = "error";
        "features" = @{
            "enableDebugTools" = $false;
            "mockAuth" = $false;
        }
    } | ConvertTo-Json | Set-Content "deploy\config.json"
}

# Create a version file for tracking deployment
"Environment: $Environment" | Out-File -FilePath "deploy\version.txt"
"Timestamp: $Timestamp" | Out-File -FilePath "deploy\version.txt" -Append
"Commit: $(git rev-parse HEAD)" | Out-File -FilePath "deploy\version.txt" -Append

# Deploy to the specified target
switch ($DeployTarget) {
    "local" {
        Write-Host "Deploying to local directory..." -ForegroundColor Cyan
        $DeployPath = ".\deployed-$Environment"
        New-Item -Path $DeployPath -ItemType Directory -Force | Out-Null
        Copy-Item -Path "deploy\*" -Destination $DeployPath -Recurse -Force
        Write-Host "Deployed to $DeployPath" -ForegroundColor Green
    }
    "azure" {
        Write-Host "Deploying to Azure..." -ForegroundColor Cyan
        # Check for Azure CLI installation
        $azCliExists = Get-Command az -ErrorAction SilentlyContinue
        if (-not $azCliExists) {
            Write-Host "Azure CLI not found. Please install Azure CLI first." -ForegroundColor Red
            exit 1
        }
        
        # Deploy to Azure Static Web Apps or App Service
        # This example uses Azure Storage static website hosting
        $storageAccount = if ($Environment -eq "dev") { "todoappdevstatic" } else { "todoapprodstatic" }
        
        Write-Host "Deploying to Azure Storage account: $storageAccount" -ForegroundColor Cyan
        Write-Host "az storage blob upload-batch -s deploy -d `$web --account-name $storageAccount" -ForegroundColor Gray
        # Uncomment to actually deploy:
        # az storage blob upload-batch -s deploy -d '$web' --account-name $storageAccount
        
        Write-Host "Deployed to Azure Storage static website: https://$storageAccount.z13.web.core.windows.net/" -ForegroundColor Green
    }
    "aws" {
        Write-Host "Deploying to AWS S3..." -ForegroundColor Cyan
        # Check for AWS CLI installation
        $awsCliExists = Get-Command aws -ErrorAction SilentlyContinue
        if (-not $awsCliExists) {
            Write-Host "AWS CLI not found. Please install AWS CLI first." -ForegroundColor Red
            exit 1
        }
        
        # Deploy to AWS S3 bucket
        $s3Bucket = if ($Environment -eq "dev") { "todo-app-dev" } else { "todo-app-prod" }
        
        Write-Host "Deploying to S3 bucket: $s3Bucket" -ForegroundColor Cyan
        Write-Host "aws s3 sync deploy s3://$s3Bucket --delete" -ForegroundColor Gray
        # Uncomment to actually deploy:
        # aws s3 sync deploy s3://$s3Bucket --delete
        
        # If CloudFront is used, invalidate cache
        # $distributionId = if ($Environment -eq "dev") { "DEV_DISTRIBUTION_ID" } else { "PROD_DISTRIBUTION_ID" }
        # aws cloudfront create-invalidation --distribution-id $distributionId --paths "/*"
        
        Write-Host "Deployed to AWS S3: http://$s3Bucket.s3-website-us-east-1.amazonaws.com/" -ForegroundColor Green
    }
    "github-pages" {
        Write-Host "Deploying to GitHub Pages..." -ForegroundColor Cyan
        # This would typically be done via GitHub Actions
        # But for manual deployment, we can push to the gh-pages branch
        
        Write-Host "For GitHub Pages deployment, use the GitHub Actions workflow instead." -ForegroundColor Yellow
        Write-Host "Manual deployment to gh-pages branch can be implemented if needed." -ForegroundColor Yellow
    }
    default {
        Write-Host "Unknown deployment target: $DeployTarget" -ForegroundColor Red
        Write-Host "Supported targets: local, azure, aws, github-pages" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "Deployment completed successfully!" -ForegroundColor Green
