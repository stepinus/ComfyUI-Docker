#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Constants
CONFIG_DIR="comfy3d-pt25"
DOCKERFILE="Dockerfile.ubuntu"  # Default to Ubuntu version
IMAGE_NAME="yanwk/comfyui-boot:${CONFIG_DIR}-ubuntu"
SAVE_FILE="${CONFIG_DIR}-image.tar"
CONTAINER_NAME="${CONFIG_DIR}"

# Function to show help
show_help() {
    echo "Usage: $0 [--opensuse] [OPTIONS]"
    echo "Options:"
    echo "  --opensuse      Use OpenSUSE-based image (default: Ubuntu)"
    echo "  --build-only    Build Docker image without running container"
    echo "  --save-image    Build and save Docker image to ${SAVE_FILE}"
    echo "  --load-image    Load Docker image from ${SAVE_FILE} and run"
    echo "  --install-wheels Install pre-compiled wheels in running container"
    echo "  --help          Show this help message"
    echo "  (no options)    Build image from scratch and run"
}

# Function to check if container is running
is_container_running() {
    docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"
}

# Parse OpenSUSE flag first
USE_OPENSUSE=false
for arg in "$@"; do
    if [[ "$arg" == "--opensuse" ]]; then
        USE_OPENSUSE=true
        DOCKERFILE="Dockerfile"
        IMAGE_NAME="yanwk/comfyui-boot:${CONFIG_DIR}"
        break
    fi
done

# Remove --opensuse from arguments if present
args=()
for arg in "$@"; do
    if [[ "$arg" != "--opensuse" ]]; then
        args+=("$arg")
    fi
done
set -- "${args[@]}"

# Parse remaining command line arguments
case "$1" in
    --build-only)
        echo -e "${BLUE}Building Docker image ($(basename $DOCKERFILE))...${NC}"
        cd "${CONFIG_DIR}" && docker build -t ${IMAGE_NAME} -f ${DOCKERFILE} .
        echo -e "${GREEN}Build completed! Image is ready but not running.${NC}"
        echo -e "${YELLOW}To save the image, run: $0 $([ "$USE_OPENSUSE" == "true" ] && echo '--opensuse') --save-image${NC}"
        exit 0
        ;;
    --save-image)
        echo -e "${BLUE}Building Docker image for distribution...${NC}"
        cd "${CONFIG_DIR}" && docker build -t ${IMAGE_NAME} -f ${DOCKERFILE} .
        echo -e "${GREEN}Saving Docker image to ${SAVE_FILE}...${NC}"
        docker save ${IMAGE_NAME} > ${SAVE_FILE}
        echo -e "${GREEN}Image saved successfully!${NC}"
        echo -e "${YELLOW}You can now distribute ${SAVE_FILE} to clients${NC}"
        echo -e "${YELLOW}File size: $(du -h ${SAVE_FILE} | cut -f1)${NC}"
        exit 0
        ;;
    --load-image)
        if [ ! -f "${SAVE_FILE}" ]; then
            echo -e "${YELLOW}Error: ${SAVE_FILE} not found!${NC}"
            exit 1
        fi
        echo -e "${BLUE}Loading Docker image from ${SAVE_FILE}...${NC}"
        docker load < ${SAVE_FILE}
        ;;
    --install-wheels)
        if ! is_container_running; then
            echo -e "${YELLOW}Error: Container ${CONTAINER_NAME} is not running!${NC}"
            echo -e "${YELLOW}Please start the container first with: $0 $([ "$USE_OPENSUSE" == "true" ] && echo '--opensuse') --load-image${NC}"
            exit 1
        fi
        echo -e "${BLUE}Installing pre-compiled wheels in container...${NC}"
        echo -e "${YELLOW}This process will take about 10 minutes...${NC}"
        docker exec -it ${CONTAINER_NAME} bash -c '
            cd /root && \
            if [ ! -f .build-complete ]; then
                bash /runner-scripts/build-deps.sh && \
                touch .build-complete
            else
                echo "Wheels already installed (found .build-complete)"
            fi'
        echo -e "${GREEN}Wheels installation completed!${NC}"
        exit 0
        ;;
    --help)
        show_help
        exit 0
        ;;
    "")
        echo -e "${BLUE}Building Docker image from scratch...${NC}"
        cd "${CONFIG_DIR}" && docker build -t ${IMAGE_NAME} -f ${DOCKERFILE} .
        ;;
    *)
        echo -e "${YELLOW}Unknown option: $1${NC}"
        show_help
        exit 1
        ;;
esac

# Create storage directory
echo -e "${GREEN}Creating storage directory...${NC}"
mkdir -p "${CONFIG_DIR}/storage"

# Create and start the container
echo -e "${GREEN}Starting the container...${NC}"
cd "${CONFIG_DIR}" && docker run -d --name ${CONTAINER_NAME} \
  --gpus all \
  -p 8188:8188 \
  -v "$(pwd)"/storage:/root \
  -e CLI_ARGS="" \
  ${IMAGE_NAME}

echo -e "${GREEN}Setup completed!${NC}"
echo -e "${BLUE}ComfyUI will be available at: http://localhost:8188${NC}"
echo -e "${YELLOW}To install pre-compiled wheels, run: $0 $([ "$USE_OPENSUSE" == "true" ] && echo '--opensuse') --install-wheels${NC}"
echo -e "${BLUE}Note: The first start may take several minutes while dependencies are being installed.${NC}" 