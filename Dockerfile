# Use the NVIDIA CUDA development image for Ubuntu 24.04
FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04

# Set working directory
WORKDIR /workspace

# Install dependencies for building raylib and general tools
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    ca-certificates \
    libglfw3-dev \
    libasound2-dev \
    libpulse-dev \
    libudev-dev \
    libxrandr-dev \
    libxi-dev \
    libxxf86vm-dev \
    libgl1 \
    libglu1-mesa-dev \
    libxinerama-dev \
    libxcursor-dev \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for CUDA
ENV PATH=/usr/local/cuda/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
    
# Clone raylib repository and checkout the latest stable commit for v5.5
RUN git clone https://github.com/raysan5/raylib.git && \
    cd raylib && \
    git checkout 5.5

# Build and install raylib 5.5
RUN cd raylib && \
    mkdir build && cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install && \
    ldconfig

# Copy main.cu from host into container
COPY main.cu /workspace/main.cu

# Compile main.cu using nvcc
RUN nvcc main.cu -o /workspace/main -lraylib -lGL -lm -lpthread -ldl


