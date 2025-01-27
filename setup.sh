#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to show help
show_help() {
    echo "ComfyUI Docker Setup Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  --download-image Download pre-built image from S3"
    echo "  --load-image    Load Docker image and run"
    echo "  --install-wheels Install pre-compiled wheels in running container"
    echo "  --help          Show this help message"
}

# Show help if no arguments
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

# Show help if requested
if [ "$1" == "--help" ]; then
    show_help
    exit 0
fi

# Forward all arguments to the setup-comfy3d.sh script
cd comfy3d-pt25
./setup-comfy3d.sh "$@" 