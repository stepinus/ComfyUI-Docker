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
    echo "Usage: $0"
    echo "This script will help you select and run a ComfyUI configuration"
}

# Function to list available configurations
list_configs() {
    echo "Available configurations:"
    echo ""
    for d in */ ; do
        if [ -f "${d}Dockerfile" ]; then
            echo "  ${d%/}"
        fi
    done
}

# Show help if requested
if [ "$1" == "--help" ]; then
    show_help
    exit 0
fi

# List available configurations
echo -e "${BLUE}Welcome to ComfyUI Docker Setup${NC}"
echo ""
list_configs
echo ""

# Ask user to select configuration
echo -e "${YELLOW}Please enter the name of the configuration you want to use:${NC}"
read -r CONFIG

# Validate configuration
if [ ! -d "$CONFIG" ] || [ ! -f "${CONFIG}/Dockerfile" ]; then
    echo -e "${YELLOW}Error: Invalid configuration '${CONFIG}'${NC}"
    exit 1
fi

# Show available actions
echo ""
echo -e "${BLUE}Available actions:${NC}"
echo "1. Build and run"
echo "2. Build image only"
echo "3. Save image for distribution"
echo "4. Load saved image and run"
echo "5. Install wheels in running container"
echo ""
echo -e "${YELLOW}Please select an action (1-5):${NC}"
read -r ACTION

case $ACTION in
    1)
        ./setup-comfy.sh "$CONFIG"
        ;;
    2)
        ./setup-comfy.sh "$CONFIG" --build-only
        ;;
    3)
        ./setup-comfy.sh "$CONFIG" --save-image
        ;;
    4)
        ./setup-comfy.sh "$CONFIG" --load-image
        ;;
    5)
        ./setup-comfy.sh "$CONFIG" --install-wheels
        ;;
    *)
        echo -e "${YELLOW}Error: Invalid action${NC}"
        exit 1
        ;;
esac 