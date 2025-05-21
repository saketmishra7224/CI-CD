#!/bin/bash
# Script to install Git hooks

echo "Setting up Git hooks for the CI/CD pipeline..."

# Create hooks directory in the repository
HOOKS_DIR=".githooks"
mkdir -p $HOOKS_DIR

# Create pre-commit hook
cat > $HOOKS_DIR/pre-commit << 'EOF'
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
EOF

# Make hooks executable
chmod +x $HOOKS_DIR/pre-commit

# Create PowerShell pre-commit hook for Windows users
cat > $HOOKS_DIR/pre-commit.ps1 << 'EOF'
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
EOF

# Configure Git to use the hooks from the repository
git config core.hooksPath .githooks

echo "Git hooks have been set up successfully!"
echo "The following hooks are now active:"
echo "- pre-commit: Checks for CSS linting errors before commit"
