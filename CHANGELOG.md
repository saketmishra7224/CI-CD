# Changelog

All notable changes to this project will be documented in this file.

## [1.0.6] - 2025-05-21

### Added
- Comprehensive monitoring utility scripts for Windows and Unix
- HTML monitoring dashboard template for future visualization
- Additional monitoring-related npm scripts
- Scheduled monitoring workflow with manual trigger option
- Support for monitoring multiple environments with the same tools
- Monitoring documentation with detailed usage examples

## [1.0.5] - 2025-05-21

### Added
- Comprehensive continuous monitoring system with health checks
- Real-time performance and availability metrics collection
- Alert generation for performance and availability issues
- Scheduled monitoring via GitHub Actions workflows
- Metrics storage for trend analysis
- Configurable monitoring parameters (interval, duration, etc.)
- Detailed monitoring reports and logs
- Integration with notification systems for alerts

## [1.0.4] - 2025-05-21

### Added
- Enhanced deployment scripts with cloud provider support (AWS, Azure, GitHub Pages)
- Environment-specific configuration files for development and production
- Notification system for build and deployment status via Slack
- Email notifications for deployment status and performance reports
- CloudFront cache invalidation for AWS deployments
- Continuous environment monitoring capabilities for production and development
- Performance benchmarking for production deployments
- Release asset creation and uploading for GitHub releases
- Support for deploying to multiple hosting providers

### Changed
- Improved GitHub Actions workflows with better conditional logic
- Updated deployment scripts to use environment variables
- Enhanced error handling in deployment processes
- Added GitHub Environments protection for production deployments

### Fixed
- Fixed YAML syntax issues in GitHub Actions workflow files
- Improved deployment target validation in shell scripts

## [1.0.3] - 2025-05-21

### Fixed
- ESLint errors in build.js - fixed string quotes and added Node.js environment
- Updated ESLint configuration to disable linebreak-style rule for cross-platform compatibility
- Improved production workflow linting by using npm scripts instead of direct commands

## [1.0.2] - 2025-05-21

### Added
- Git hooks for pre-commit validation of CSS files
- Setup scripts for Git hooks (Windows and Unix)
- Automatic CSS linting before commits
- Documentation for Git hooks in GIT-HOOKS.md

### Fixed
- CSS linting errors throughout style.css
- Stylelint configuration to handle deprecated rules
- Improved indentation and formatting consistency

## [1.0.1] - 2025-05-20

### Added
- Footer to the To-Do List application
- Improved meta information in HTML file
- Updated CSS styles for the footer
