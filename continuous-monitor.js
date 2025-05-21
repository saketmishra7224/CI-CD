#!/usr/bin/env node

/**
 * Continuous Monitoring Script for Todo List Application
 * 
 * This script runs continuous monitoring on deployed applications
 * and can be used as part of a CI/CD pipeline or run independently
 * to track application health, performance, and availability.
 * 
 * Features:
 * - Scheduled health checks
 * - Performance metrics collection
 * - Uptime monitoring
 * - Alert notifications for issues
 * - Metrics storage for trend analysis
 * 
 * Usage:
 *   node continuous-monitor.js [environment] [options]
 * 
 * Examples:
 *   node continuous-monitor.js dev --interval=5 --duration=60
 *   node continuous-monitor.js prod --notify --interval=10
 */

const https = require("https");
const http = require("http");
const fs = require("fs");
const path = require("path");
const { performance } = require("perf_hooks");
const os = require("os");

// Parse command line arguments
const args = process.argv.slice(2);
const environment = args[0] || "dev";
const options = parseCommandLineOptions(args.slice(1));

// Configuration
const config = {
  environments: {
    dev: {
      url: "https://todoappdevstatic.z13.web.core.windows.net/",
      thresholds: {
        responseTime: 1500, // ms
        availability: 95 // percentage
      }
    },
    prod: {
      url: "https://todoapprodstatic.z13.web.core.windows.net/",
      thresholds: {
        responseTime: 800, // ms
        availability: 99.9 // percentage
      }
    },
    local: {
      url: "http://localhost:8080",
      thresholds: {
        responseTime: 300, // ms
        availability: 99 // percentage
      }
    }
  },
  checkInterval: options.interval || 5, // seconds
  duration: options.duration || 0, // minutes (0 = run indefinitely)
  notify: options.notify || false,
  metricsFile: path.join(process.cwd(), `metrics-${environment}.json`),
  logFile: path.join(process.cwd(), `monitor-${environment}.log`)
};

// Current environment configuration
const currentEnv = config.environments[environment];
if (!currentEnv) {
  console.error(`Error: Unknown environment "${environment}". Valid options: dev, prod, local`);
  process.exit(1);
}

// State
const state = {
  startTime: Date.now(),
  checks: 0,
  successfulChecks: 0,
  totalResponseTime: 0,
  metrics: [],
  alerts: [],
  isRunning: true
};

// Monitoring instance
let monitoringInterval;

// Initialize metrics file if it doesn't exist
initializeMetricsFile();

// Start monitoring
console.log(`🔄 Starting continuous monitoring for ${environment} environment`);
console.log(`🌐 Target URL: ${currentEnv.url}`);
console.log(`⏱️  Check interval: ${config.checkInterval} seconds`);
if (config.duration > 0) {
  console.log(`⏳ Duration: ${config.duration} minutes`);
  // Set timer to end monitoring after specified duration
  setTimeout(() => {
    stopMonitoring();
  }, config.duration * 60 * 1000);
}
console.log("-------------------------------------------");

// Start interval
monitoringInterval = setInterval(runHealthCheck, config.checkInterval * 1000);

// Run first check immediately
runHealthCheck();

// Handle graceful shutdown
process.on("SIGINT", () => {
  console.log("\n🛑 Monitoring interrupted. Generating final report...");
  stopMonitoring();
});

/**
 * Run a single health check
 */
async function runHealthCheck() {
  const checkStartTime = performance.now();
  const timestamp = new Date().toISOString();
  
  try {
    const result = await makeRequest(currentEnv.url);
    const responseTime = performance.now() - checkStartTime;
    
    // Update state
    state.checks++;
    state.successfulChecks++;
    state.totalResponseTime += responseTime;
    
    // Store metric
    const metric = {
      timestamp,
      responseTime,
      statusCode: result.statusCode,
      contentSize: result.size,
      success: true
    };
    
    state.metrics.push(metric);
    saveMetricToFile(metric);
    
    // Log success
    console.log(`✅ [${timestamp}] Health check passed - ${responseTime.toFixed(2)}ms`);
    
    // Check for performance issues
    if (responseTime > currentEnv.thresholds.responseTime) {
      const alert = {
        timestamp,
        type: "performance",
        message: `Response time (${responseTime.toFixed(2)}ms) exceeds threshold (${currentEnv.thresholds.responseTime}ms)`
      };
      state.alerts.push(alert);
      logAlert(alert);
    }
  
  } catch (error) {
    // Handle error
    state.checks++;
    
    // Store failed metric
    const metric = {
      timestamp,
      error: error.message,
      success: false
    };
    
    state.metrics.push(metric);
    saveMetricToFile(metric);
    
    // Log error
    console.error(`❌ [${timestamp}] Health check failed - ${error.message}`);
    
    // Create availability alert if needed
    const availability = (state.successfulChecks / state.checks) * 100;
    if (availability < currentEnv.thresholds.availability) {
      const alert = {
        timestamp,
        type: "availability",
        message: `Availability (${availability.toFixed(2)}%) below threshold (${currentEnv.thresholds.availability}%)`
      };
      state.alerts.push(alert);
      logAlert(alert);
    }
  }
}

/**
 * Make an HTTP request to the target URL
 */
function makeRequest(url) {
  return new Promise((resolve, reject) => {
    const client = url.startsWith("https") ? https : http;
    const timeout = setTimeout(() => {
      req.destroy();
      reject(new Error(`Request timed out after ${10000}ms`));
    }, 10000);
    
    const req = client.get(url, (res) => {
      clearTimeout(timeout);
      
      if (res.statusCode < 200 || res.statusCode >= 300) {
        return reject(new Error(`HTTP Error ${res.statusCode}: ${res.statusMessage}`));
      }
      
      let data = "";
      res.on("data", chunk => {
        data += chunk;
      });
      
      res.on("end", () => {
        resolve({
          statusCode: res.statusCode,
          size: Buffer.byteLength(data, "utf8"),
          headers: res.headers
        });
      });
    });
    
    req.on("error", (err) => {
      clearTimeout(timeout);
      reject(err);
    });
  });
}

/**
 * Stop monitoring and generate final report
 */
function stopMonitoring() {
  if (!state.isRunning) return;
  
  state.isRunning = false;
  clearInterval(monitoringInterval);
  
  const endTime = Date.now();
  const durationMinutes = ((endTime - state.startTime) / 1000 / 60).toFixed(2);
  
  // Generate report
  const availability = state.checks > 0 
    ? (state.successfulChecks / state.checks) * 100 
    : 0;
    
  const avgResponseTime = state.successfulChecks > 0 
    ? state.totalResponseTime / state.successfulChecks 
    : 0;
  
  console.log("\n📊 Monitoring Summary:");
  console.log("-------------------------------------------");
  console.log(`⏱️  Duration: ${durationMinutes} minutes`);
  console.log(`🔢 Total checks: ${state.checks}`);
  console.log(`✅ Successful checks: ${state.successfulChecks}`);
  console.log(`❌ Failed checks: ${state.checks - state.successfulChecks}`);
  console.log(`📈 Availability: ${availability.toFixed(2)}%`);
  console.log(`⚡ Average response time: ${avgResponseTime.toFixed(2)}ms`);
  console.log(`🚨 Total alerts: ${state.alerts.length}`);
  console.log("-------------------------------------------");
  
  // Show alerts if any
  if (state.alerts.length > 0) {
    console.log("\n🚨 Alerts:");
    state.alerts.slice(-5).forEach(alert => {
      console.log(`[${alert.timestamp}] ${alert.type}: ${alert.message}`);
    });
  }
  
  // Final status
  if (availability >= currentEnv.thresholds.availability && 
      avgResponseTime <= currentEnv.thresholds.responseTime) {
    console.log("\n✅ Overall system health: GOOD");
  } else if (availability >= currentEnv.thresholds.availability * 0.9) {
    console.log("\n⚠️ Overall system health: DEGRADED");
  } else {
    console.log("\n❌ Overall system health: CRITICAL");
  }
  
  // Write summary to log
  const summary = {
    environment,
    startTime: new Date(state.startTime).toISOString(),
    endTime: new Date(endTime).toISOString(),
    duration: durationMinutes,
    checks: state.checks,
    successfulChecks: state.successfulChecks,
    availability: availability.toFixed(2),
    avgResponseTime: avgResponseTime.toFixed(2),
    alerts: state.alerts.length,
    health: availability >= currentEnv.thresholds.availability ? "GOOD" : "DEGRADED"
  };
  
  fs.appendFileSync(config.logFile, JSON.stringify(summary) + "\n", "utf8");
}

/**
 * Initialize the metrics file
 */
function initializeMetricsFile() {
  const header = {
    environment,
    startTime: new Date().toISOString(),
    host: os.hostname(),
    metricsVersion: 1
  };
  
  if (!fs.existsSync(config.metricsFile)) {
    fs.writeFileSync(config.metricsFile, JSON.stringify(header) + "\n", "utf8");
  }
}

/**
 * Save a metric to the metrics file
 */
function saveMetricToFile(metric) {
  fs.appendFileSync(config.metricsFile, JSON.stringify(metric) + "\n", "utf8");
}

/**
 * Log an alert
 */
function logAlert(alert) {
  console.log(`🚨 ALERT: ${alert.type} - ${alert.message}`);
  
  // Send notifications if enabled
  if (config.notify) {
    // This would integrate with notification services like Slack, email, etc.
    // For now, just log it
    console.log(`📧 Alert notification would be sent here for: ${alert.message}`);
  }
}

/**
 * Parse command line options
 */
function parseCommandLineOptions(args) {
  const options = {};
  
  args.forEach(arg => {
    if (arg === "--notify") {
      options.notify = true;
    } else if (arg.startsWith("--interval=")) {
      options.interval = parseInt(arg.split("=")[1], 10);
    } else if (arg.startsWith("--duration=")) {
      options.duration = parseInt(arg.split("=")[1], 10);
    }
  });
  
  return options;
}