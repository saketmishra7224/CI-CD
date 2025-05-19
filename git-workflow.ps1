# Git Workflow Helper Script
# This script helps automate common Git workflow operations

param (
    [Parameter(Mandatory = $false)]
    [ValidateSet("feature", "hotfix", "release", "promote")]
    [string]$Operation,
    
    [Parameter(Mandatory = $false)]
    [string]$Name = ""
)

# Check if git is installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git is not installed or not in the PATH. Please install Git." -ForegroundColor Red
    exit 1
}

# Check current branch
$currentBranch = git rev-parse --abbrev-ref HEAD

function Start-Feature {
    param (
        [string]$FeatureName
    )
    
    if ([string]::IsNullOrEmpty($FeatureName)) {
        Write-Host "Feature name is required. Usage: .\git-workflow.ps1 -Operation feature -Name <feature-name>" -ForegroundColor Red
        exit 1
    }
    
    # Make sure we're starting from development branch
    if ($currentBranch -ne "development") {
        Write-Host "Switching to development branch..." -ForegroundColor Cyan
        git checkout development
        
        # Pull latest changes
        Write-Host "Pulling latest changes from development..." -ForegroundColor Cyan
        git pull origin development
    }
    
    # Create and checkout feature branch
    $branchName = "feature/$FeatureName"
    Write-Host "Creating and checking out feature branch: $branchName" -ForegroundColor Cyan
    git checkout -b $branchName
    
    # Push to remote to track
    Write-Host "Pushing feature branch to remote..." -ForegroundColor Cyan
    git push -u origin $branchName
    
    Write-Host "Feature branch '$branchName' created and pushed. You can now start working on your feature." -ForegroundColor Green
}

function Start-Hotfix {
    param (
        [string]$HotfixName
    )
    
    if ([string]::IsNullOrEmpty($HotfixName)) {
        Write-Host "Hotfix name is required. Usage: .\git-workflow.ps1 -Operation hotfix -Name <hotfix-name>" -ForegroundColor Red
        exit 1
    }
    
    # Make sure we're starting from main branch
    if ($currentBranch -ne "main") {
        Write-Host "Switching to main branch..." -ForegroundColor Cyan
        git checkout main
        
        # Pull latest changes
        Write-Host "Pulling latest changes from main..." -ForegroundColor Cyan
        git pull origin main
    }
    
    # Create and checkout hotfix branch
    $branchName = "hotfix/$HotfixName"
    Write-Host "Creating and checking out hotfix branch: $branchName" -ForegroundColor Cyan
    git checkout -b $branchName
    
    # Push to remote to track
    Write-Host "Pushing hotfix branch to remote..." -ForegroundColor Cyan
    git push -u origin $branchName
    
    Write-Host "Hotfix branch '$branchName' created and pushed. You can now start working on your hotfix." -ForegroundColor Green
}

function Start-Release {
    param (
        [string]$ReleaseName
    )
    
    if ([string]::IsNullOrEmpty($ReleaseName)) {
        Write-Host "Release name/version is required. Usage: .\git-workflow.ps1 -Operation release -Name <version>" -ForegroundColor Red
        exit 1
    }
    
    # Make sure we're starting from development branch
    if ($currentBranch -ne "development") {
        Write-Host "Switching to development branch..." -ForegroundColor Cyan
        git checkout development
        
        # Pull latest changes
        Write-Host "Pulling latest changes from development..." -ForegroundColor Cyan
        git pull origin development
    }
    
    # Create and checkout release branch
    $branchName = "release/$ReleaseName"
    Write-Host "Creating and checking out release branch: $branchName" -ForegroundColor Cyan
    git checkout -b $branchName
    
    # Push to remote to track
    Write-Host "Pushing release branch to remote..." -ForegroundColor Cyan
    git push -u origin $branchName
    
    Write-Host "Release branch '$branchName' created and pushed. You can now prepare for the release." -ForegroundColor Green
    Write-Host "After testing, use the 'promote' operation to merge to main." -ForegroundColor Yellow
}

function Promote-ToProduction {
    if ($currentBranch -notmatch "^release/") {
        Write-Host "You must be on a release branch to promote to production. Current branch: $currentBranch" -ForegroundColor Red
        exit 1
    }
    
    # Pull latest changes from current branch
    Write-Host "Pulling latest changes from $currentBranch..." -ForegroundColor Cyan
    git pull origin $currentBranch
    
    # Checkout main branch
    Write-Host "Checking out main branch..." -ForegroundColor Cyan
    git checkout main
    
    # Pull latest changes from main
    Write-Host "Pulling latest changes from main..." -ForegroundColor Cyan
    git pull origin main
    
    # Merge release branch into main
    Write-Host "Merging $currentBranch into main..." -ForegroundColor Cyan
    git merge --no-ff $currentBranch -m "Merge $currentBranch into main for production release"
    
    # Push to main
    Write-Host "Pushing changes to main..." -ForegroundColor Cyan
    git push origin main
    
    # Create tag
    $tagName = $currentBranch -replace "^release/", "v"
    Write-Host "Creating tag $tagName..." -ForegroundColor Cyan
    git tag -a $tagName -m "Release $tagName"
    
    # Push tag
    Write-Host "Pushing tag $tagName..." -ForegroundColor Cyan
    git push origin $tagName
    
    # Checkout development branch
    Write-Host "Checking out development branch..." -ForegroundColor Cyan
    git checkout development
    
    # Pull latest changes from development
    Write-Host "Pulling latest changes from development..." -ForegroundColor Cyan
    git pull origin development
    
    # Merge release branch into development
    Write-Host "Merging $currentBranch into development..." -ForegroundColor Cyan
    git merge --no-ff $currentBranch -m "Merge $currentBranch into development"
    
    # Push to development
    Write-Host "Pushing changes to development..." -ForegroundColor Cyan
    git push origin development
    
    Write-Host "Promotion completed successfully! The release has been merged into main and development branches." -ForegroundColor Green
}

# Main script execution
switch ($Operation) {
    "feature" {
        Start-Feature -FeatureName $Name
    }
    "hotfix" {
        Start-Hotfix -HotfixName $Name
    }
    "release" {
        Start-Release -ReleaseName $Name
    }
    "promote" {
        Promote-ToProduction
    }
    default {
        Write-Host @"
Git Workflow Helper Script

Usage: 
  .\git-workflow.ps1 -Operation <operation> -Name <name>

Operations:
  feature <name>  - Create a new feature branch from development
  hotfix <name>   - Create a new hotfix branch from main
  release <name>  - Create a new release branch from development
  promote         - Promote current release branch to production (main)

Examples:
  .\git-workflow.ps1 -Operation feature -Name add-login
  .\git-workflow.ps1 -Operation hotfix -Name fix-critical-bug
  .\git-workflow.ps1 -Operation release -Name 1.0.0
  .\git-workflow.ps1 -Operation promote
"@ -ForegroundColor Cyan
    }
}
