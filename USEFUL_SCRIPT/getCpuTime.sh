#!/bin/bash#!/bin/bash

# Script to extract total CPU time from OpenFOAM log file
# Usage: bash getCpuTime [-f log_file]

# Default log file path
LOGFILE="./LOG/log.simpleFoam"

# Parse command-line options
while getopts ":f:" opt; do
  case $opt in
    f)
      LOGFILE="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      echo "Usage: bash getCpuTime [-f log_file]"
      exit 1
      ;;
  esac
done

# Check if the log file exists
if [[ ! -f "$LOGFILE" ]]; then
    echo "Error: Log file '$LOGFILE' not found."
    exit 1
fi

# Extract the last 'ExecutionTime' line and retrieve the CPU time
CPU_TIME=$(grep 'ExecutionTime =' "$LOGFILE" | tail -1 | awk '{print $3}')

# Check if CPU_TIME is not empty
if [[ -z "$CPU_TIME" ]]; then
    echo "Error: Could not find 'ExecutionTime' in the log file."
    exit 1
fi

# Output the CPU time
echo "Total CPU Time: $CPU_TIME seconds"

