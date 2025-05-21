# Environment Variables

This document describes the environment variables used in the CI/CD pipeline.

## GitHub Actions Environment Variables

These variables are defined in the GitHub Actions workflow files:

### Common Variables

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `NODE_ENV` | Defines the environment (development or production) | Depends on workflow |
| `DEPLOY_TARGET` | Deployment target (local, azure, aws, github-pages) | azure |

### Azure Deployment Variables

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `AZURE_STORAGE_ACCOUNT` | Azure Storage account name | todoappdevstatic (dev) <br> todoapprodstatic (prod) |

### AWS Deployment Variables

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `AWS_S3_BUCKET` | AWS S3 bucket name | todo-app-dev (dev) <br> todo-app-prod (prod) |
| `CLOUDFRONT_DISTRIBUTION_ID` | CloudFront distribution ID | - (from secrets) |

## GitHub Secrets

These secrets should be configured in your GitHub repository settings:

### Authentication

| Secret | Description |
|--------|-------------|
| `AZURE_CREDENTIALS` | Azure service principal credentials JSON |
| `AWS_ACCESS_KEY_ID` | AWS access key with S3 permissions |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key |

### Notification

| Secret | Description |
|--------|-------------|
| `SLACK_WEBHOOK` | Slack webhook URL for notifications |
| `MAIL_SERVER` | SMTP server address |
| `MAIL_PORT` | SMTP server port |
| `MAIL_USERNAME` | SMTP username |
| `MAIL_PASSWORD` | SMTP password |
| `NOTIFICATION_EMAIL` | Email address for notifications |

## Local Environment Variables

When running deployment scripts locally, you can pass environment variables:

### PowerShell (Windows)

```powershell
$env:AZURE_ACCOUNT_NAME = "mytodoappstore"
.\deploy.ps1 -Environment dev -DeployTarget azure
```

### Bash (Unix)

```bash
AZURE_ACCOUNT_NAME=mytodoappstore ./deploy.sh dev azure
```

## Configuration Files

Environment-specific configuration files are generated during the deployment process:

### Development (`config.json`)

```json
{
  "env": "development",
  "apiEndpoint": "https://dev-api.example.com",
  "loggingLevel": "debug",
  "features": {
    "enableDebugTools": true,
    "mockAuth": true
  }
}
```

### Production (`config.json`)

```json
{
  "env": "production",
  "apiEndpoint": "https://api.example.com",
  "loggingLevel": "error",
  "features": {
    "enableDebugTools": false,
    "mockAuth": false
  }
}
```

## Customizing Environment Variables

To customize environment variables for your project:

1. Edit the `.github/workflows/development.yml` and `.github/workflows/production.yml` files
2. Update the `env:` section at the top of each file
3. Add new variables as needed for your deployment targets
4. Add corresponding secrets in GitHub repository settings

## Environment Variables in Deployment Scripts

The deployment scripts (`deploy.ps1` and `deploy.sh`) can access environment variables to customize the deployment behavior.

You can also pass additional parameters to these scripts:

```powershell
.\deploy.ps1 -Environment prod -DeployTarget azure -CustomParam "value"
```

This allows for flexible and extensible deployment configurations.
