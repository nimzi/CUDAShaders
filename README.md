# CUDA_Dockerized

A small workspace that combines a Raylib-based application with CUDA code and a Docker-based build workflow. It's intended as a development/test playground for building and running a CUDA + Raylib application either natively or inside a containerized environment.

Top-level files and folders
- `main.cu` — The primary CUDA + Raylib application in this repository. It initializes a Raylib window and uses a CUDA kernel to render an animated framebuffer.
- `Dockerfile` — Docker image that installs dependencies (build tools, raylib) and compiles `main.cu` with `nvcc`. The Docker image used in the file targets NVIDIA CUDA development images (see the FROM line).
- `build.sh` — Helper script that builds the Docker image, runs a container to compile the binary, and copies the resulting binary to `./out` on the host. The script expects Docker with GPU support (nvidia runtime) and that `docker build` succeeds.


What this workspace does
- Builds a Raylib-enabled application that leverages CUDA for GPU-accelerated rendering.
- Offers a Docker-based build flow so you can compile the project without installing a CUDA toolkit on the host. The Docker image in this repository installs raylib and `nvcc` and produces a `main` binary.

Quick native build (developer machine with CUDA & raylib installed)

Prerequisites on host:
- NVIDIA GPU + drivers
- CUDA Toolkit (nvcc) installed and on PATH
- raylib development libraries and headers installed (or build raylib locally)

Build command (same as used in the Dockerfile):

```bash
nvcc main.cu -o main -lraylib -lGL -lm -lpthread -ldl
```

