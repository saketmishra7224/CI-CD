#!/usr/bin/env node

/**
 * Performance monitoring script for Todo List application
 * 
 * This script runs basic performance checks on the deployed application
 * and generates a report. It can be integrated into the CI/CD pipeline
 * or run manually.
 * 
 * Usage:
 *   node performance-monitor.js [url] [options]
 * 
 * Examples:
 *   node performance-monitor.js https://todoappdevstatic.z13.web.core.windows.net/
 *   node performance-monitor.js https://todoapprodstatic.z13.web.core.windows.net/ --detailed
 */

const https = require('https');
const http = require('http');
const { performance } = require('perf_hooks');
const fs = require('fs');
const path = require('path');

// Parse command line arguments
const args = process.argv.slice(2);
const url = args[0] || 'http://localhost:8080';
const isDetailedReport = args.includes('--detailed');
const isCI = args.includes('--ci');

// Configuration
const config = {
  numRequests: 5,
  timeoutMs: 10000,
  outputFile: path.join(process.cwd(), 'performance-report.json'),
  thresholds: {
    responseTime: 1000, // ms
    fileSize: 500 * 1024, // 500 KB
  }
};

console.log(`\n🔍 Starting performance check for ${url}\n`);

async function runPerformanceTest() {
  const results = {
    url,
    timestamp: new Date().toISOString(),
    summary: {},
    details: [],
    issues: [],
    passedChecks: []
  };

  try {
    // Basic load time check
    const loadTimes = [];
    const responseSizes = [];
    
    for (let i = 0; i < config.numRequests; i++) {
      const start = performance.now();
      const result = await makeRequest(url);
      const end = performance.now();
      
      const responseTime = end - start;
      loadTimes.push(responseTime);
      responseSizes.push(result.size);
      
      if (isDetailedReport) {
        results.details.push({
          requestNumber: i + 1,
          responseTime,
          size: result.size,
          statusCode: result.statusCode,
          headers: result.headers
        });
      }
      
      process.stdout.write('.');
    }
    
    console.log('\n');
    
    // Calculate statistics
    const avgLoadTime = loadTimes.reduce((a, b) => a + b, 0) / loadTimes.length;
    const minLoadTime = Math.min(...loadTimes);
    const maxLoadTime = Math.max(...loadTimes);
    const avgSize = responseSizes.reduce((a, b) => a + b, 0) / responseSizes.length;
    
    results.summary = {
      averageResponseTime: avgLoadTime.toFixed(2),
      minResponseTime: minLoadTime.toFixed(2),
      maxResponseTime: maxLoadTime.toFixed(2),
      averageSize: formatSize(avgSize),
      numRequests: config.numRequests
    };
    
    // Check against thresholds
    if (avgLoadTime > config.thresholds.responseTime) {
      results.issues.push(`Average response time (${avgLoadTime.toFixed(2)} ms) exceeds threshold (${config.thresholds.responseTime} ms)`);
    } else {
      results.passedChecks.push(`Response time check passed (${avgLoadTime.toFixed(2)} ms)`);
    }
    
    if (avgSize > config.thresholds.fileSize) {
      results.issues.push(`Average page size (${formatSize(avgSize)}) exceeds threshold (${formatSize(config.thresholds.fileSize)})`);
    } else {
      results.passedChecks.push(`Page size check passed (${formatSize(avgSize)})`);
    }
    
    // Print report
    console.log('📊 Performance Report');
    console.log('-------------------');
    console.log(`URL: ${url}`);
    console.log(`Average Response Time: ${avgLoadTime.toFixed(2)} ms`);
    console.log(`Min/Max Response Time: ${minLoadTime.toFixed(2)} ms / ${maxLoadTime.toFixed(2)} ms`);
    console.log(`Average Page Size: ${formatSize(avgSize)}`);
    console.log(`Number of Requests: ${config.numRequests}`);
    
    if (results.issues.length > 0) {
      console.log('\n⚠️ Issues Detected:');
      results.issues.forEach(issue => console.log(` - ${issue}`));
    }
    
    if (results.passedChecks.length > 0) {
      console.log('\n✅ Passed Checks:');
      results.passedChecks.forEach(check => console.log(` - ${check}`));
    }
    
    // Save report
    fs.writeFileSync(config.outputFile, JSON.stringify(results, null, 2));
    console.log(`\n📝 Report saved to ${config.outputFile}`);
    
    // Return exit code for CI environments
    if (isCI && results.issues.length > 0) {
      process.exit(1);
    }
    
  } catch (error) {
    console.error(`\n❌ Error running performance test: ${error.message}`);
    if (isCI) {
      process.exit(1);
    }
  }
}

function makeRequest(url) {
  return new Promise((resolve, reject) => {
    const client = url.startsWith('https') ? https : http;
    const timeout = setTimeout(() => {
      req.abort();
      reject(new Error(`Request timed out after ${config.timeoutMs}ms`));
    }, config.timeoutMs);
    
    const req = client.get(url, (res) => {
      clearTimeout(timeout);
      
      if (res.statusCode < 200 || res.statusCode >= 300) {
        return reject(new Error(`HTTP Error ${res.statusCode}: ${res.statusMessage}`));
      }
      
      let data = '';
      res.on('data', chunk => {
        data += chunk;
      });
      
      res.on('end', () => {
        resolve({
          statusCode: res.statusCode,
          size: Buffer.byteLength(data, 'utf8'),
          headers: res.headers
        });
      });
    });
    
    req.on('error', (err) => {
      clearTimeout(timeout);
      reject(err);
    });
  });
}

function formatSize(bytes) {
  if (bytes < 1024) return `${bytes.toFixed(2)} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(2)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(2)} MB`;
}

runPerformanceTest();
