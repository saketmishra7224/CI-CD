# Using the CI/CD Pipeline

This document provides step-by-step instructions on how to use the CI/CD pipeline for this project.

## Getting Started

1. Clone the repository:
   ```
   git clone https://github.com/saketmishra7224/CI-CD.git
   cd CI-CD
   ```

2. Install dependencies:
   ```
   npm install
   ```

## Development Workflow

### Creating a Feature Branch

Use the Git workflow helper script to create a new feature branch:

```powershell
.\git-workflow.ps1 -Operation feature -Name my-feature
```

This will:
- Switch to the development branch
- Pull the latest changes
- Create and switch to a new feature branch named `feature/my-feature`

### Working on Your Feature

1. Make your changes to the codebase
2. Test your changes locally:
   ```
   npm run start:dev
   ```
3. Lint your code:
   ```
   npm run lint
   ```

### Committing Changes

1. Add your changes:
   ```
   git add .
   ```

2. Commit your changes:
   ```
   git commit -m "Descriptive message about your changes"
   ```

3. Push your feature branch:
   ```
   git push -u origin feature/my-feature
   ```

### Creating a Pull Request

1. Go to GitHub repository: https://github.com/saketmishra7224/CI-CD
2. Click on "Pull Requests" tab
3. Click "New Pull Request"
4. Set base branch to `development` and compare branch to your feature branch
5. Fill in the PR template with details about your changes
6. Submit the pull request

The CI pipeline will run automatically to validate your code.

### Merging to Development

Once your PR is approved:

1. PR will be merged into the development branch
2. CI/CD pipeline will deploy to the development environment

## Production Release

### Creating a Release

When you're ready to release to production:

```powershell
.\git-workflow.ps1 -Operation release -Name 1.0.1
```

This creates a release branch where you can make final adjustments and version changes.

### Promoting to Production

When the release is ready:

```powershell
.\git-workflow.ps1 -Operation promote
```

This will:
1. Create a PR from the release branch to main
2. Once approved and merged, the production pipeline will deploy to production

### Hotfixes

For critical fixes that need to go directly to production:

```powershell
.\git-workflow.ps1 -Operation hotfix -Name critical-fix
```

This creates a hotfix branch from main. When complete:

1. Create a PR from the hotfix branch to main
2. Once merged, create another PR to merge the hotfix into development

## Monitoring Deployments

You can monitor the status of deployments in the GitHub Actions tab of the repository.

1. Go to the repository on GitHub
2. Click the "Actions" tab
3. Select the workflow you want to view
4. Check the logs and status of each step in the pipeline
