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
    Write-Host "Checking $file..." -ForegroundColor Gray
    $result = npx stylelint $file 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ CSS linting failed for $file" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
        exit 1
    }
}

Write-Host "✅ CSS linting passed!" -ForegroundColor Green
exit 0
