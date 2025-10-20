# CUDA_Dockerized

A small workspace that combines a Raylib-based application with CUDA code and a Docker-based build workflow. It's intended as a development/test playground for building and running a CUDA + Raylib application either natively or inside a containerized environment.

Top-level files and folders
- `main.cu` — The primary CUDA + Raylib application in this repository. It initializes a Raylib window and uses a CUDA kernel to render an animated framebuffer.
- `Dockerfile` — Docker image that installs dependencies (build tools, raylib) and compiles `main.cu` with `nvcc`. The Docker image used in the file targets NVIDIA CUDA development images (see the FROM line).
- `build.sh` — Helper script that builds the Docker image, runs a container to compile the binary, and copies the resulting binary to `./out` on the host. The script expects Docker with GPU support (nvidia runtime) and that `docker build` succeeds.
- `my_program` — (present in the workspace) may be a local binary or folder; inspect it locally if you need to run or remove it.
- `raylib/` — a cloned/checked-out copy of the raylib source tree used by the Dockerfile when building the image.

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

Run the binary (you need a display/X session and GPU access):

```bash
./main
```

Docker-based build (recommended if you don't want CUDA on the host)

1. Build the Docker image and compile inside it using the included `build.sh` script:

```bash
chmod +x build.sh
./build.sh
```

2. The script creates an `out` directory and copies the compiled binary there. To run the binary from the container with display access, use something like:

```bash
# allow X connections from the host (optional and not secure for multi-user systems)
xhost +local:docker

docker run --rm --gpus all -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
	-v "$PWD":/workspace -w /workspace cuda-raylib-build ./main

# restore X security (optional)
xhost -local:docker
```

Notes and troubleshooting
- GPU and drivers: To actually use CUDA you need a compatible NVIDIA driver on the host and a matching CUDA runtime. In Docker, use NVIDIA Container Toolkit so the container has access to the GPU.
- CMake in Dockerfile: The Dockerfile installs `cmake` from the OS packages. If you later run into a CMake version requirement (for other projects) you can upgrade CMake via Kitware APT, pip, conda, or run the build inside a container with a newer CMake.
- Display/X: Running an app that opens a window from inside a container requires forwarding the X display or using other display mechanisms (X11, Wayland, VNC).
- `build.sh` assumes the image builds successfully and that `nvcc` compiles `main.cu`. Inspect `Dockerfile` if you need to modify libraries or raylib build options.

Suggestions I can implement for you
- Add a `Makefile` or improved `build.sh` that supports native builds and Docker builds with flags.
- Add CI (GitHub Actions) that builds the Docker image and runs compile-only checks.
- Modify the Dockerfile to pin CUDA and raylib versions or to produce a smaller runtime image.
- Remove or archive `my_program` if it's an old binary you no longer want tracked.

If you want, I can now:
- run the `build.sh` script and paste the build output here (requires Docker available in this environment), or
- produce a small `Makefile` and test native compile commands, or
- remove files you specify.

