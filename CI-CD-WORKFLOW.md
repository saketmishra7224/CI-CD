# CI/CD Workflow Documentation

This document explains the CI/CD workflow setup for this project.

## Git Workflow

This project follows a simplified GitFlow workflow:

```
main (production)
  │
  ├── development
  │     │
  │     ├── feature/feature-1
  │     │
  │     ├── feature/feature-2
  │     │
  │     └── release/v1.0.0
  │           │
  │           └── (merged to main for production)
  │
  └── hotfix/critical-fix
        │
        └── (merged to both main and development)
```

### Branches

- **main**: Production-ready code
- **development**: Integration branch for new features
- **feature/***:  Individual feature branches created from development
- **release/***:  Release branches created from development for preparing releases
- **hotfix/***:   Urgent fixes applied directly to main and then merged back to development

### Workflow Helpers

We've created a Git workflow helper script to assist with common operations:

```powershell
# Create a new feature branch
.\git-workflow.ps1 -Operation feature -Name add-login

# Create a hotfix branch
.\git-workflow.ps1 -Operation hotfix -Name fix-critical-bug

# Create a release branch
.\git-workflow.ps1 -Operation release -Name 1.0.0

# Promote a release branch to production
.\git-workflow.ps1 -Operation promote
```

## CI/CD Pipeline

### Development Pipeline

The development pipeline is triggered on pushes to the development branch and performs the following steps:

1. Code checkout
2. Install dependencies
3. Lint HTML, CSS, and JavaScript files
4. (Future) Run tests
5. Archive artifacts
6. Deploy to development environment

### Production Pipeline

The production pipeline is triggered on pushes to the main branch and performs the following steps:

1. Code checkout
2. Install dependencies
3. Strict linting of HTML, CSS, and JavaScript files
4. (Future) Run tests
5. Build and optimize assets
6. Archive artifacts
7. Deploy to production environment

## Deployment Scripts

Two deployment scripts are provided:

- `deploy.sh` for Unix-based systems
- `deploy.ps1` for Windows systems

These scripts handle:

1. Creating a deployment package
2. Applying environment-specific configurations
3. Tracking deployment versions
4. Deploying to the appropriate environment

## Build Process

The `build.js` script handles the build process for production:

1. Minifying HTML files
2. Optimizing CSS files
3. Compressing JavaScript files
4. Copying assets to the build directory

## NPM Scripts

The following NPM scripts are available:

```
npm run lint         # Run all linters
npm run lint:html    # Lint HTML files
npm run lint:css     # Lint CSS files
npm run lint:js      # Lint JavaScript files
npm run build        # Build for production
npm run deploy:dev   # Deploy to development environment
npm run deploy:prod  # Deploy to production environment
npm run start        # Start local development server
npm run start:dev    # Lint and start local server
npm run start:prod   # Lint, build, and start production server
npm run lint:fix     # Fix linting errors automatically
npm run setup:hooks  # Set up Git hooks for Windows users
npm run setup:hooks:unix # Set up Git hooks for Unix users
```

## Git Hooks

The repository contains Git hooks to ensure code quality at every commit. These hooks automatically check code quality before allowing commits.

### Available Hooks

- **pre-commit**: Checks CSS files for linting errors before allowing commits

### Setting Up Hooks

Run the hook setup script:

```bash
# For Windows users
npm run setup:hooks

# For Unix-based users (Linux/macOS)
npm run setup:hooks:unix
```

For more details about the Git hooks, see [GIT-HOOKS.md](GIT-HOOKS.md).
