# PowerShell script to install Git hooks
# This script should be run by all team members to set up the hooks

$ErrorActionPreference = "Stop"

Write-Host "Setting up Git hooks for the CI/CD pipeline..." -ForegroundColor Cyan

# Create hooks directory in the repository
$hooksDir = ".githooks"
if (-not (Test-Path $hooksDir)) {
    Write-Host "Creating $hooksDir directory..." -ForegroundColor Yellow
    New-Item -Path $hooksDir -ItemType Directory -Force | Out-Null
}

# Create pre-commit hook for Unix systems
$preCommitUnix = @"
#!/bin/sh
# Pre-commit hook to check for CSS linting errors

echo "Running CSS linting check..."
FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(css)$')

if [ -z "$FILES" ]; then
  echo "No CSS files to check. Skipping CSS linting."
  exit 0
fi

# Run stylelint on the staged CSS files
npx stylelint $FILES

if [ $? -ne 0 ]; then
  echo "❌ CSS linting failed. Please fix the above errors and try again."
  exit 1
fi

echo "✅ CSS linting passed!"
exit 0
"@

# Create pre-commit hook for Windows systems
$preCommitPS = @"
# PowerShell Pre-commit hook to check for CSS linting errors
Write-Host "Running CSS linting check..." -ForegroundColor Cyan

# Get list of staged CSS files
$files = (git diff --cached --name-only --diff-filter=ACM | Where-Object { $_ -match '\.css$' })

if ($files.Count -eq 0) {
    Write-Host "No CSS files to check. Skipping CSS linting." -ForegroundColor Yellow
    exit 0
}

# Run stylelint on the staged CSS files
foreach ($file in $files) {
    Write-Host "Checking `$file..." -ForegroundColor Gray
    $result = npx stylelint `$file 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ CSS linting failed for `$file" -ForegroundColor Red
        Write-Host `$result -ForegroundColor Red
        exit 1
    }
}

Write-Host "✅ CSS linting passed!" -ForegroundColor Green
exit 0
"@

# Save hooks to the repository
$preCommitUnix | Out-File -FilePath "$hooksDir/pre-commit" -Encoding utf8 -NoNewline
$preCommitPS | Out-File -FilePath "$hooksDir/pre-commit.ps1" -Encoding utf8

# Make the Unix hook executable
if (Test-Path "/bin/chmod") {
    Write-Host "Making Unix hook executable..." -ForegroundColor Yellow
    /bin/chmod +x "$hooksDir/pre-commit"
}

# Configure Git to use the hooks from the repository
git config core.hooksPath .githooks

Write-Host "Git hooks have been set up successfully!" -ForegroundColor Green
Write-Host "The following hooks are now active:" -ForegroundColor Green
Write-Host "- pre-commit: Checks for CSS linting errors before commit" -ForegroundColor Green
