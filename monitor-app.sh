#!/bin/bash

# Monitoring Utility Script for Todo List Application
#
# This script provides easy access to monitoring functions
# 
# Usage:
#   ./monitor-app.sh [operation] [environment] [options]
#
# Operations:
#   health      - Run a quick health check
#   performance - Run a performance analysis
#   continuous  - Run continuous monitoring
#
# Environments:
#   dev   - Development environment
#   prod  - Production environment
#   local - Local environment
#
# Options:
#   --duration=N  - Duration in minutes (default: 5)
#   --interval=N  - Interval in seconds (default: 5)
#   --notify      - Send notifications for alerts

# Default values
OPERATION=""
ENVIRONMENT=""
DURATION=5
INTERVAL=5
NOTIFY=false

# Parse command line arguments
if [ $# -lt 2 ]; then
    echo "Error: Insufficient arguments provided."
    echo "Usage: ./monitor-app.sh [operation] [environment] [options]"
    echo "Example: ./monitor-app.sh health dev --duration=10 --notify"
    exit 1
fi

OPERATION=$1
ENVIRONMENT=$2

# Validate operation
if [[ "$OPERATION" != "health" && "$OPERATION" != "performance" && "$OPERATION" != "continuous" ]]; then
    echo "Error: Invalid operation. Choose health, performance, or continuous."
    exit 1
fi

# Validate environment
if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "prod" && "$ENVIRONMENT" != "local" ]]; then
    echo "Error: Invalid environment. Choose dev, prod, or local."
    exit 1
fi

# Parse additional options
shift 2
while [ "$1" != "" ]; do
    PARAM=$(echo "$1" | awk -F= '{print $1}')
    VALUE=$(echo "$1" | awk -F= '{print $2}')
    
    case $PARAM in
        --duration)
            DURATION=$VALUE
            ;;
        --interval)
            INTERVAL=$VALUE
            ;;
        --notify)
            NOTIFY=true
            ;;
        *)
            echo "Error: Unknown parameter \"$PARAM\""
            exit 1
            ;;
    esac
    shift
done

# Configuration
case $ENVIRONMENT in
    "dev")
        URL="https://todoappdevstatic.z13.web.core.windows.net/"
        ;;
    "prod")
        URL="https://todoapprodstatic.z13.web.core.windows.net/"
        ;;
    "local")
        URL="http://localhost:8080"
        ;;
esac

# Ensure Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js is required but not found. Please install Node.js and try again."
    exit 1
fi

echo "Node.js version $(node --version) found."

# Ensure npm packages are installed
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

echo "Starting $OPERATION monitoring for $ENVIRONMENT environment ($URL)..."

case $OPERATION in
    "health")
        # Run a quick health check
        echo "Running health check..."
        CMD="node continuous-monitor.js $ENVIRONMENT --duration=$DURATION"
        if [ "$NOTIFY" = true ]; then
            CMD="$CMD --notify"
        fi
        $CMD
        ;;
    "performance")
        # Run performance analysis
        echo "Running performance analysis..."
        DETAILED_PARAM=""
        if [ $DURATION -gt 5 ]; then
            DETAILED_PARAM="--detailed"
        fi
        node performance-monitor.js $URL $DETAILED_PARAM
        ;;
    "continuous")
        # Run continuous monitoring
        echo "Running continuous monitoring..."
        CMD="node continuous-monitor.js $ENVIRONMENT --interval=$INTERVAL"
        if [ $DURATION -gt 0 ]; then
            CMD="$CMD --duration=$DURATION"
        fi
        if [ "$NOTIFY" = true ]; then
            CMD="$CMD --notify"
        fi
        $CMD
        ;;
esac

# Process monitoring results
if [ $? -eq 0 ]; then
    echo -e "\nMonitoring completed successfully!"
    
    # Show available reports
    REPORTS=""
    if [ -f "metrics-$ENVIRONMENT.json" ]; then
        REPORTS="$REPORTS metrics-$ENVIRONMENT.json"
    fi
    if [ -f "monitor-$ENVIRONMENT.log" ]; then
        REPORTS="$REPORTS monitor-$ENVIRONMENT.log"
    fi
    if [ -f "performance-report.json" ]; then
        REPORTS="$REPORTS performance-report.json"
    fi
    
    if [ ! -z "$REPORTS" ]; then
        echo -e "\nAvailable reports:"
        for REPORT in $REPORTS; do
            echo " - $REPORT"
        done
    fi
else
    echo -e "\nMonitoring completed with issues. Check the output for details."
fi
