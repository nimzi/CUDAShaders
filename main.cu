#include <raylib.h>
#include <cuda_runtime.h>
#include <cmath>
#include <iostream>

const int WIDTH = 800;
const int HEIGHT = 600;

// CUDA kernel: generates a simple animated color pattern
__global__ void shaderKernel(Color* pixels, int width, int height, float time) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    if (x >= width || y >= height) return;

    int idx = y * width + x;

    // Simple animation: color waves
    pixels[idx].r = (unsigned char)((sinf(x * 0.05f + time) + 1) * 127.5f);
    pixels[idx].g = (unsigned char)((sinf(y * 0.05f + time) + 1) * 127.5f);
    pixels[idx].b = (unsigned char)((sinf((x + y) * 0.03f + time) + 1) * 127.5f);
    pixels[idx].a = 255;
}

int main() {
    // Initialize Raylib window
    InitWindow(WIDTH, HEIGHT, "CUDA Shader Animation with Raylib");
    SetTargetFPS(60);

    // Allocate host memory for framebuffer
    Color* h_pixels;
    cudaMallocHost(&h_pixels, WIDTH * HEIGHT * sizeof(Color));

    // Allocate device memory
    Color* d_pixels;
    cudaMalloc(&d_pixels, WIDTH * HEIGHT * sizeof(Color));

    // Create a Raylib texture
    Image image = GenImageColor(WIDTH, HEIGHT, BLACK);
    Texture2D texture = LoadTextureFromImage(image);
    UnloadImage(image);

    dim3 threads(16, 16);
    dim3 blocks((WIDTH + threads.x - 1) / threads.x, (HEIGHT + threads.y - 1) / threads.y);

    while (!WindowShouldClose()) {
        float t = GetTime();

        // Launch CUDA kernel
        shaderKernel<<<blocks, threads>>>(d_pixels, WIDTH, HEIGHT, t);
        cudaDeviceSynchronize();

        // Copy GPU framebuffer to host
        cudaMemcpy(h_pixels, d_pixels, WIDTH * HEIGHT * sizeof(Color), cudaMemcpyDeviceToHost);

        // Update Raylib texture
        UpdateTexture(texture, h_pixels);

        // Draw the texture
        BeginDrawing();
        ClearBackground(BLACK);
        DrawTexture(texture, 0, 0, WHITE);
        EndDrawing();
    }

    // Cleanup
    UnloadTexture(texture);
    cudaFree(d_pixels);
    cudaFreeHost(h_pixels);
    CloseWindow();

    return 0;
}
