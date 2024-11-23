#!/bin/bash

# Ensure the DATA_DIR is provided as an argument (relative or absolute)
DATA_DIR="$1"
if [ -z "$DATA_DIR" ]; then
    echo -e "\033[0;31mError: No DATA_DIR provided. Usage: bash setup.sh <DATA_DIR>\033[0m"
    exit 1
fi

ROOT_DIR=$(pwd)

# ------------------------------------------------------------------------------------- #


