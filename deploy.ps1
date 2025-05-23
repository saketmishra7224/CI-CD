# PowerShell script to deploy the application
# Usage: .\deploy.ps1 [destination_server]

param (
    [string]$destination = "production"
)

# Build the project
Write-Host "Building project..." -ForegroundColor Green
npm run build

if ($destination -eq "production") {
    Write-Host "Deploying to production server..." -ForegroundColor Green
    # Replace with your production server deployment commands
    # Example using PowerShell: 
    # $sourcePath = ".\dist\*"
    # $destinationPath = "\\production-server\wwwroot\"
    # Copy-Item -Path $sourcePath -Destination $destinationPath -Recurse -Force
}
elseif ($destination -eq "development") {
    Write-Host "Deploying to development server..." -ForegroundColor Green
    # Replace with your development server deployment commands
    # Example using PowerShell:
    # $sourcePath = ".\dist\*"
    # $destinationPath = "\\dev-server\wwwroot\"
    # Copy-Item -Path $sourcePath -Destination $destinationPath -Recurse -Force
}
else {
    Write-Host "Unknown destination: $destination" -ForegroundColor Red
    Write-Host "Usage: .\deploy.ps1 [production|development]" -ForegroundColor Yellow
    exit 1
}

Write-Host "Deployment complete!" -ForegroundColor Green
