# PowerShell Pre-commit hook to check for CSS and JavaScript linting errors

# CSS Linting
Write-Host "Running CSS linting check..." -ForegroundColor Cyan

# Get list of staged CSS files
$cssFiles = (git diff --cached --name-only --diff-filter=ACM | Where-Object { $_ -match '\.css$' })

if ($cssFiles.Count -eq 0) {
    Write-Host "No CSS files to check. Skipping CSS linting." -ForegroundColor Yellow
} else {
    # Run stylelint on the staged CSS files
    foreach ($file in $cssFiles) {
        Write-Host "Checking $file..." -ForegroundColor Gray
        $result = npx stylelint $file 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ CSS linting failed for $file" -ForegroundColor Red
            Write-Host $result -ForegroundColor Red
            exit 1
        }
    }

    Write-Host "✅ CSS linting passed!" -ForegroundColor Green
}

# JavaScript Linting
Write-Host "Running JavaScript linting check..." -ForegroundColor Cyan

# Get list of staged JavaScript files
$jsFiles = (git diff --cached --name-only --diff-filter=ACM | Where-Object { $_ -match '\.js$' })

if ($jsFiles.Count -eq 0) {
    Write-Host "No JavaScript files to check. Skipping JavaScript linting." -ForegroundColor Yellow
} else {
    # Run eslint on the staged JavaScript files
    foreach ($file in $jsFiles) {
        Write-Host "Checking $file..." -ForegroundColor Gray
        $result = npx eslint $file 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ JavaScript linting failed for $file" -ForegroundColor Red
            Write-Host $result -ForegroundColor Red
            exit 1
        }
    }

    Write-Host "✅ JavaScript linting passed!" -ForegroundColor Green
}

exit 0
