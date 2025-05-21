# Monitoring Utility Script for Todo List Application
#
# This script provides easy access to monitoring functions
# 
# Usage:
#   .\monitor-app.ps1 -Operation <operation> -Environment <environment> -Duration <minutes> -Interval <seconds> -Notify
#
# Examples:
#   .\monitor-app.ps1 -Operation health -Environment dev -Duration 5
#   .\monitor-app.ps1 -Operation performance -Environment prod
#   .\monitor-app.ps1 -Operation continuous -Environment prod -Interval 10 -Notify

param (
    [Parameter(Mandatory=$true)]
    [ValidateSet('health', 'performance', 'continuous')]
    [string]$Operation,

    [Parameter(Mandatory=$true)]
    [ValidateSet('dev', 'prod', 'local')]
    [string]$Environment,

    [Parameter(Mandatory=$false)]
    [int]$Duration = 5,

    [Parameter(Mandatory=$false)]
    [int]$Interval = 5,
    
    [Parameter(Mandatory=$false)]
    [switch]$Notify = $false
)

# Configuration
$environmentUrls = @{
    'dev' = 'https://todoappdevstatic.z13.web.core.windows.net/';
    'prod' = 'https://todoapprodstatic.z13.web.core.windows.net/';
    'local' = 'http://localhost:8080';
}

# Ensure Node.js is installed
try {
    $nodeVersion = node --version
    Write-Host "Node.js version $nodeVersion found." -ForegroundColor Green
} catch {
    Write-Host "Node.js is required but not found. Please install Node.js and try again." -ForegroundColor Red
    exit 1
}

# Ensure npm packages are installed
if (-not (Test-Path -Path "node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm install
}

# Get URL for the selected environment
$url = $environmentUrls[$Environment]

Write-Host "Starting $Operation monitoring for $Environment environment ($url)..." -ForegroundColor Cyan

switch ($Operation) {
    'health' {
        # Run a quick health check
        Write-Host "Running health check..." -ForegroundColor Cyan
        $command = "node continuous-monitor.js $Environment --duration=$Duration"
        if ($Notify) {
            $command += " --notify"
        }
        Invoke-Expression $command
    }
    'performance' {
        # Run performance analysis
        Write-Host "Running performance analysis..." -ForegroundColor Cyan
        $detailedParam = if ($Duration -gt 5) { "--detailed" } else { "" }
        Invoke-Expression "node performance-monitor.js $url $detailedParam"
    }
    'continuous' {
        # Run continuous monitoring
        Write-Host "Running continuous monitoring..." -ForegroundColor Cyan
        $command = "node continuous-monitor.js $Environment --interval=$Interval"
        if ($Duration -gt 0) {
            $command += " --duration=$Duration"
        }
        if ($Notify) {
            $command += " --notify"
        }
        Invoke-Expression $command
    }
}

# Process monitoring results
if ($LASTEXITCODE -eq 0) {
    Write-Host "`nMonitoring completed successfully!" -ForegroundColor Green
    
    # Show available reports
    $reportFiles = @()
    if (Test-Path "metrics-$Environment.json") {
        $reportFiles += "metrics-$Environment.json"
    }
    if (Test-Path "monitor-$Environment.log") {
        $reportFiles += "monitor-$Environment.log"
    }
    if (Test-Path "performance-report.json") {
        $reportFiles += "performance-report.json"
    }
    
    if ($reportFiles.Count -gt 0) {
        Write-Host "`nAvailable reports:" -ForegroundColor Cyan
        foreach ($file in $reportFiles) {
            Write-Host " - $file"
        }
    }
} else {
    Write-Host "`nMonitoring completed with issues. Check the output for details." -ForegroundColor Yellow
}
