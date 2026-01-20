#!/bin/bash
set -e

# Base directory
BASE_DIR="/workspaces/gophp"
PHP_SRC_DIR="$BASE_DIR/php-src"
WATCHER_SRC_DIR="$BASE_DIR/watcher"

# Install system dependencies
echo "Installing system dependencies..."
sudo apt-get update
sudo apt-get install -y \
    autoconf \
    dpkg-dev \
    file \
    g++ \
    gcc \
    libc-dev \
    make \
    pkg-config \
    re2c \
    libargon2-dev \
    libbrotli-dev \
    libcurl4-openssl-dev \
    libonig-dev \
    libreadline-dev \
    libsodium-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    zlib1g-dev \
    bison \
    libnss3-tools \
    git \
    clang \
    cmake \
    llvm \
    gdb \
    valgrind \
    libtool-bin

# Build PHP
if [ ! -d "$PHP_SRC_DIR" ]; then
    echo "Cloning PHP source..."
    git clone --depth 1 --branch PHP-8.4 https://github.com/php/php-src.git "$PHP_SRC_DIR"
fi

if [ ! -f "/usr/local/bin/php" ]; then
    echo "Building PHP..."
    cd "$PHP_SRC_DIR"
    ./buildconf --force
    
    # Configure with debug enabled and embed SAPI
    EXTENSION_DIR=/usr/local/lib/php/extensions/no-debug-zts-20230831 ./configure \
        --enable-embed \
        --enable-zts \
        --disable-zend-signals \
        --enable-zend-max-execution-timers \
        --enable-debug \
        --with-config-file-path=/etc/frankenphp/php.ini \
        --with-config-file-scan-dir=/etc/frankenphp/php.d \
        --with-openssl \
        --with-zlib \
        --with-curl \
        --without-pear
        
    make -j"$(nproc)"
    sudo make install
    sudo ldconfig
    
    # Setup php.ini
    sudo mkdir -p /etc/frankenphp/php.d
    sudo cp php.ini-development /etc/frankenphp/php.ini
    echo "zend_extension=opcache.so" | sudo tee -a /etc/frankenphp/php.ini
    echo "opcache.enable=1" | sudo tee -a /etc/frankenphp/php.ini
else
    echo "PHP already installed (check specific configure options if you face issues)."
fi

# Build libwatcher
if [ ! -d "$WATCHER_SRC_DIR" ]; then
    echo "Cloning watcher..."
    git clone https://github.com/e-dant/watcher.git "$WATCHER_SRC_DIR"
fi

if [ ! -f "/usr/local/lib/libwatcher-c.so" ]; then
    echo "Building watcher..."
    cd "$WATCHER_SRC_DIR"
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
    cmake --build build/
    sudo cmake --install build
    sudo cp build/libwatcher-c.so /usr/local/lib/libwatcher-c.so
    sudo ldconfig
else
    echo "libwatcher already installed."
fi

echo "All dependencies installed!"
