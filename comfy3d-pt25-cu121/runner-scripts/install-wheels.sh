#!/bin/bash

set -eo pipefail

WHEELS_BASE_DIR="/wheels"

# Verify wheels directory exists and is mounted
if [ ! -d "$WHEELS_BASE_DIR" ]; then
    echo "Error: Wheels directory ($WHEELS_BASE_DIR) not found!"
    echo "Please make sure the volume is properly mounted in docker-compose.yml"
    exit 1
fi

# Get environment information
PYTHON_VERSION=$(python3 -c 'import sys; print(f"py{sys.version_info.major}{sys.version_info.minor}")')
TORCH_VERSION=$(python3 -c 'import torch; print(f"torch{torch.__version__.split("+")[0]}")')
CUDA_VERSION=$(python3 -c 'import torch; print(f"cu{torch.version.cuda.replace(".","")}")')

echo "Detected environment:"
echo "Python: $PYTHON_VERSION"
echo "PyTorch: $TORCH_VERSION"
echo "CUDA: $CUDA_VERSION"
echo ""

# Function to list available wheel configurations
list_configs() {
    echo "Available wheel configurations:"
    if ! ls -1 "$WHEELS_BASE_DIR/_Wheels_linux_"* >/dev/null 2>&1; then
        echo "No wheel configurations found in $WHEELS_BASE_DIR"
        echo "Directory contents:"
        ls -la "$WHEELS_BASE_DIR"
        return 1
    fi
    
    ls -1 "$WHEELS_BASE_DIR/_Wheels_linux_"* 2>/dev/null | while read -r dir; do
        basename "$dir" | sed 's/_Wheels_linux_//'
    done
}

# Function to install wheels from a specific configuration
install_wheels() {
    local config_dir="$1"
    if [ ! -d "$config_dir" ]; then
        echo "Error: Configuration directory not found: $config_dir"
        echo "Available directories in $WHEELS_BASE_DIR:"
        ls -la "$WHEELS_BASE_DIR"
        exit 1
    }
    
    echo "Installing wheels from: $config_dir"
    if ! find "$config_dir" -name "*.whl" -type f | grep -q .; then
        echo "Warning: No .whl files found in $config_dir"
        echo "Directory contents:"
        ls -la "$config_dir"
        exit 1
    fi
    
    find "$config_dir" -name "*.whl" -type f | while read -r wheel; do
        echo "Installing: $(basename "$wheel")"
        pip install --force-reinstall "$wheel"
    done
}

# Main script logic
if [ "$1" = "list" ]; then
    list_configs
    exit 0
fi

if [ "$1" = "auto" ]; then
    TARGET_DIR="${WHEELS_BASE_DIR}/_Wheels_linux_${PYTHON_VERSION}_${TORCH_VERSION}_${CUDA_VERSION}"
    if [ -d "$TARGET_DIR" ]; then
        install_wheels "$TARGET_DIR"
    else
        echo "Error: No matching wheels found for current environment:"
        echo "Python: $PYTHON_VERSION"
        echo "PyTorch: $TORCH_VERSION"
        echo "CUDA: $CUDA_VERSION"
        echo ""
        echo "Available configurations:"
        list_configs
    fi
    exit 0
fi

if [ -n "$1" ]; then
    TARGET_DIR="${WHEELS_BASE_DIR}/_Wheels_linux_$1"
    if [ -d "$TARGET_DIR" ]; then
        install_wheels "$TARGET_DIR"
    else
        echo "Error: Configuration not found: $1"
        echo ""
        echo "Available configurations:"
        list_configs
    fi
    exit 0
fi

echo "Usage:"
echo "  $0 list              - List available wheel configurations"
echo "  $0 auto             - Automatically detect and install matching wheels"
echo "  $0 <config-name>    - Install wheels from specific configuration"
echo ""
list_configs 