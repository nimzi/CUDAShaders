#!/bin/bash
set -e  # exit on any error

# Name of the Docker image
IMAGE_NAME="cuda-raylib-build"

# Host output directory
OUTPUT_DIR="$(pwd)/out"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

echo "==> Building Docker image..."
docker build -t $IMAGE_NAME .

echo "==> Running container to build main.cu..."
# Run the container to compile the program
# The container does not auto-run the program

docker run --rm --gpus all \
    -v "$OUTPUT_DIR":/workspace/out \
    --user $(id -u):$(id -g) \
    $IMAGE_NAME \
    bash -c "cp /workspace/main /workspace/out/"

echo "==> Build finished. Binary copied to $OUTPUT_DIR"
