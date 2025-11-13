# BatAxeKernel Build Script

Script otomatis untuk build kernel dari repository BatAxeKernel.

## Fitur

- Clone/update repository otomatis
- Support multiple branch
- Build parallel dengan optimal core usage
- Logging lengkap
- Error handling yang baik
- Support multiple package managers
- Colorized output

## Requirements

- Git
- Build-essential / Development Tools
- Kernel build dependencies

## Penggunaan

```bash
# Berikan permission execute
chmod +x build.sh

# Build branch default (main)
./build.sh

# Build branch tertentu
./build.sh -b development

# Clean build
./build.sh -c -b main

# Build tanpa install
./build.sh -n

# Lihat help
./build.sh -h