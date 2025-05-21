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

## Deployment Options

The CI/CD pipeline now supports multiple deployment targets:

### Local Deployment

Deploy to a local directory for testing:

```powershell
# For Windows
.\deploy.ps1 -Environment dev -DeployTarget local

# For Unix
./deploy.sh dev local
```

### Cloud Provider Deployment

#### Azure Deployment

To deploy to Azure Storage static websites:

1. Configure Azure credentials as GitHub Secrets:
   - `AZURE_CREDENTIALS`: Service principal credentials with access to the storage account

2. Deploy manually:
   ```powershell
   # For Windows
   .\deploy.ps1 -Environment dev -DeployTarget azure

   # For Unix
   ./deploy.sh dev azure
   ```

3. CI/CD will automatically deploy on push to appropriate branches based on the `DEPLOY_TARGET` environment variable.

#### AWS Deployment

To deploy to AWS S3 with optional CloudFront:

1. Configure AWS credentials as GitHub Secrets:
   - `AWS_ACCESS_KEY_ID`: AWS access key with S3 permissions
   - `AWS_SECRET_ACCESS_KEY`: Corresponding secret key
   - `CLOUDFRONT_DISTRIBUTION_ID`: (Optional) Distribution ID for cache invalidation

2. Deploy manually:
   ```powershell
   # For Windows
   .\deploy.ps1 -Environment prod -DeployTarget aws

   # For Unix
   ./deploy.sh prod aws
   ```

#### GitHub Pages Deployment

To deploy to GitHub Pages:

1. Deploy manually:
   ```powershell
   # This will indicate this is best done through GitHub Actions
   .\deploy.ps1 -Environment prod -DeployTarget github-pages
   
   # For Unix
   ./deploy.sh prod github-pages
   ```

2. CI/CD will automatically deploy to GitHub Pages using the gh-pages branch.

## Notifications

The CI/CD pipeline now includes notifications for build and deployment status:

### Slack Notifications

To enable Slack notifications:

1. Create a Slack webhook for your channel
2. Add the webhook URL as a GitHub Secret named `SLACK_WEBHOOK`
3. Customize the channel in the GitHub Actions workflow files

### Email Notifications

To enable email notifications:

1. Add the following GitHub Secrets:
   - `MAIL_SERVER`: SMTP server address
   - `MAIL_PORT`: SMTP server port
   - `MAIL_USERNAME`: Username for authentication
   - `MAIL_PASSWORD`: Password for authentication
   - `NOTIFICATION_EMAIL`: Email address to receive notifications

## Environment Configuration

Each environment (development and production) now has specific configuration files:

- Development: Enables debug tools and uses development APIs
- Production: Optimized for performance with production endpoints

## Monitoring and Performance

The CI/CD pipeline now includes basic monitoring:

1. Status checks for deployed websites
2. Performance benchmarking (placeholder for integration with tools like Lighthouse CI)
3. Deployment verification and reporting

## Continuous Improvement

The CI/CD pipeline is designed to be extensible. Some areas for future enhancement:

1. Add integration with monitoring services like New Relic or Datadog
2. Implement A/B testing capabilities
3. Add support for containerized deployments with Docker
4. Include security scanning with tools like OWASP ZAP
