#!/bin/bash

# Build Script for BatAxeKernel
# Author: Auto-generated
# Description: Script to build BatAxeKernel from specified branch

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
KERNEL_REPO="git@github.com:papaL3xa/BatAxeKernel.git"
BUILD_DIR="BatAxeKernel"
LOG_FILE="build.log"
CURRENT_DIR=$(pwd)

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to setup build environment
setup_environment() {
    print_status "Setting up build environment..."
    
    # Check for essential tools
    local missing_tools=()
    
    for tool in git make gcc g++; do
        if ! command_exists "$tool"; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing essential tools: ${missing_tools[*]}"
        print_error "Please install them before continuing."
        exit 1
    fi
    
    # Check for kernel build dependencies (common ones)
    if command_exists "apt"; then
        print_status "Detected APT package manager"
        sudo apt update
        sudo apt install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev
    elif command_exists "yum"; then
        print_status "Detected YUM package manager"
        sudo yum groupinstall -y "Development Tools"
        sudo yum install -y ncurses-devel bison flex openssl-devel elfutils-libelf-devel
    elif command_exists "dnf"; then
        print_status "Detected DNF package manager"
        sudo dnf groupinstall -y "Development Tools"
        sudo dnf install -y ncurses-devel bison flex openssl-devel elfutils-libelf-devel
    elif command_exists "pacman"; then
        print_status "Detected Pacman package manager"
        sudo pacman -Syu --noconfirm
        sudo pacman -S --noconfirm base-devel ncurses
    else
        print_warning "Unknown package manager. Please ensure build-essential/equivalent is installed."
    fi
}

# Function to clone or update repository
setup_repository() {
    local branch="${1:-main}"
    
    if [ -d "$BUILD_DIR" ]; then
        print_status "Repository exists, updating..."
        cd "$BUILD_DIR"
        
        # Stash any local changes
        git stash > /dev/null 2>&1
        
        # Fetch and reset to remote branch
        git fetch origin
        git checkout "$branch"
        git reset --hard "origin/$branch"
        
        print_success "Repository updated to branch: $branch"
    else
        print_status "Cloning repository..."
        git clone "$KERNEL_REPO" "$BUILD_DIR"
        cd "$BUILD_DIR"
        git checkout "$branch"
        print_success "Repository cloned and checked out branch: $branch"
    fi
}

# Function to build kernel
build_kernel() {
    print_status "Starting kernel build process..."
    
    # Check for configuration file
    if [ ! -f ".config" ]; then
        print_warning "No .config found, using default config"
        if [ -f "arch/x86/configs" ] || [ -d "arch/x86/configs" ]; then
            # For x86 architecture
            make defconfig
        elif [ -f "arch/arm64/configs" ] || [ -d "arch/arm64/configs" ]; then
            # For ARM64 architecture
            make defconfig
        else
            print_error "No default config found. Please create a .config file."
            exit 1
        fi
    fi
    
    # Get number of CPU cores for parallel build
    local num_cores=$(nproc)
    print_status "Building with $num_cores parallel jobs..."
    
    # Start build process
    print_status "Compiling kernel..."
    if make -j"$num_cores" 2>&1 | tee "../${LOG_FILE}"; then
        print_success "Kernel compiled successfully!"
    else
        print_error "Kernel compilation failed!"
        print_error "Check ${LOG_FILE} for details."
        exit 1
    fi
    
    # Install modules if needed
    print_status "Installing kernel modules..."
    if sudo make modules_install 2>&1 | tee -a "../${LOG_FILE}"; then
        print_success "Modules installed successfully!"
    else
        print_error "Module installation failed!"
        exit 1
    fi
    
    # Install kernel if needed
    print_status "Installing kernel..."
    if sudo make install 2>&1 | tee -a "../${LOG_FILE}"; then
        print_success "Kernel installed successfully!"
    else
        print_error "Kernel installation failed!"
        exit 1
    fi
}

# Function to cleanup
cleanup() {
    print_status "Cleaning up..."
    cd "$CURRENT_DIR"
    
    if [ -d "$BUILD_DIR" ]; then
        print_status "Running make clean..."
        cd "$BUILD_DIR"
        make clean
        cd "$CURRENT_DIR"
    fi
    
    print_success "Cleanup completed!"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -b, --branch BRANCH    Specify branch to build (default: main)"
    echo "  -c, --clean            Clean before building"
    echo "  -n, --no-install       Build only, don't install"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                      # Build main branch"
    echo "  $0 -b development       # Build development branch"
    echo "  $0 -c -b main          # Clean and build main branch"
}

# Main function
main() {
    local branch="main"
    local clean_build=false
    local skip_install=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -b|--branch)
                branch="$2"
                shift 2
                ;;
            -c|--clean)
                clean_build=true
                shift
                ;;
            -n|--no-install)
                skip_install=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    print_status "Starting BatAxeKernel build process..."
    print_status "Target branch: $branch"
    
    # Setup environment
    setup_environment
    
    # Setup repository
    setup_repository "$branch"
    
    # Clean if requested
    if [ "$clean_build" = true ]; then
        print_status "Performing clean build..."
        make clean
    fi
    
    # Build kernel
    build_kernel
    
    # Skip installation if requested
    if [ "$skip_install" = true ]; then
        print_warning "Skipping installation as requested"
    fi
    
    print_success "Build process completed!"
    print_status "Log file: ${LOG_FILE}"
    print_status "Build directory: ${BUILD_DIR}"
    
    # Return to original directory
    cd "$CURRENT_DIR"
}

# Trap Ctrl+C
trap 'print_error "Build interrupted by user!"; exit 1' INT

# Run main function with all arguments
main "$@"