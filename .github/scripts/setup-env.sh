#!/bin/bash

# Setup environment script for GitHub Actions

set -e

echo "🔧 Setting up kernel build environment..."

# Install dependencies based on OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "📦 Installing Linux dependencies..."
    sudo apt-get update
    sudo apt-get install -y \
        build-essential \
        libncurses-dev \
        bison \
        flex \
        libssl-dev \
        libelf-dev \
        bc \
        git \
        wget \
        curl
    
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "📦 Installing macOS dependencies..."
    brew update
    brew install \
        binutils \
        ncurses \
        bison \
        flex \
        openssl \
        elfutils
    
else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
fi

echo "✅ Environment setup completed!"