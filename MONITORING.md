# Continuous Monitoring

This document describes the continuous monitoring system implemented for the Todo List application CI/CD pipeline.

## Overview

The continuous monitoring system provides real-time insights into application health, performance, and availability. It's designed to:

1. Detect issues before they impact users
2. Track performance trends over time
3. Ensure high availability of both development and production environments
4. Generate alerts when metrics exceed defined thresholds
5. Provide historical data for optimization efforts

## Monitoring Components

### 1. Performance Monitoring

The `performance-monitor.js` script performs one-time performance analysis:

```bash
# Run performance monitoring on development environment
npm run monitor:dev

# Run performance monitoring on production environment
npm run monitor:prod

# Run performance monitoring on local environment
npm run monitor:local
```

This generates a detailed report of:
- Response time metrics
- Page size analysis
- Potential performance bottlenecks

### 2. Continuous Health Monitoring

The `continuous-monitor.js` script provides ongoing health checks:

```bash
# Monitor development environment continuously
npm run watch:dev

# Monitor production environment with alerts
npm run alert:prod

# Custom monitoring configuration
node continuous-monitor.js prod --interval=5 --duration=30 --notify
```

Parameters:
- `--interval=X`: Check frequency in seconds
- `--duration=Y`: Total monitoring duration in minutes (0 = indefinitely)
- `--notify`: Enable alert notifications

### 3. Automated Scheduled Monitoring

Scheduled monitoring is configured through GitHub Actions:

- Runs every 6 hours automatically
- Can be manually triggered as needed
- Configurable duration and notification settings
- Stores metrics and logs as artifacts for analysis

## Metrics and Thresholds

Different environments have different performance expectations:

| Environment | Response Time | Availability |
|-------------|---------------|-------------|
| Development | 1500ms        | 95%         |
| Production  | 800ms         | 99.9%       |
| Local       | 300ms         | 99%         |

## Alerts

The monitoring system generates alerts when:

1. Response time exceeds the threshold for the environment
2. Availability drops below the defined threshold
3. HTTP errors occur during health checks

Alert notifications can be sent via:
- Email (integrated with CI/CD pipeline)
- Slack (using existing CI/CD notification channels)

## Reports and Logs

The monitoring system generates:

1. Real-time console output during monitoring
2. Detailed JSON metrics stored in `metrics-{env}.json`
3. Summary logs in `monitor-{env}.log`
4. Email reports when running in GitHub Actions

## Integration with CI/CD Pipeline

Monitoring is integrated with the CI/CD pipeline in several ways:

1. Post-deployment verification in production workflow
2. Scheduled monitoring via GitHub Actions
3. On-demand monitoring via workflow dispatch
4. Alert generation feeds into notification system

## Monitoring Dashboard

A basic monitoring dashboard template is included with the project:

```
monitoring-dashboard.html
```

This HTML dashboard provides:
- Visualization of key performance metrics
- Status indicators for different environments
- Alert history and deployment status

To view the dashboard:
1. Open `monitoring-dashboard.html` in your browser
2. In a production environment, this could be deployed to a static web server
3. Future enhancements will add dynamic data loading from monitoring metrics

## Future Enhancements

Planned improvements for the monitoring system:

1. Integration with APM tools (New Relic, Datadog, etc.)
2. Advanced metrics collection (memory usage, error rates, etc.)
3. Interactive visualizations for the monitoring dashboard
4. Anomaly detection using historical data
5. Real-time updates using WebSockets or Server-Sent Events

## Usage Examples

### Running a Quick Health Check

```powershell
# Using the monitoring utility script (Windows)
npm run monitor -- -Operation health -Environment prod -Duration 5

# Using the monitoring utility script (Unix)
npm run monitor:unix -- health prod --duration=5

# Direct method
node continuous-monitor.js prod --duration=5
```

### Setting Up Continuous Monitoring

```powershell
# Using the monitoring utility script (Windows)
npm run monitor -- -Operation continuous -Environment prod -Interval 10 -Notify

# Using the monitoring utility script (Unix)
npm run monitor:unix -- continuous prod --interval=10 --notify

# Using npm scripts
npm run alert:prod
```

### Triggering Monitoring from GitHub Actions

1. Go to Actions tab in the GitHub repository
2. Select "Continuous Monitoring" workflow
3. Click "Run workflow"
4. Select environment, duration, and notification options
5. Review the results in the action logs and artifacts
