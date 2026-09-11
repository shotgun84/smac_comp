#!/bin/bash

set -e

# Install Flutter SDK
git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"

export PATH="$HOME/flutter/bin:$PATH"

# Verify Flutter installation
flutter --version

# Enable web
flutter config --enable-web

# Get dependencies
flutter pub get

# Build Flutter Web
flutter build web --release
