#!/bin/bash
set -e

# 1. Install Flutter if not present
if [ ! -d "_flutter" ]; then
  echo "Cloning Flutter SDK..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable _flutter
else
  echo "Flutter SDK already exists, skipping clone."
fi

# 2. Add Flutter to PATH
export PATH="$PWD/_flutter/bin:$PATH"

# 3. Configure git safe directory
git config --global --add safe.directory "$PWD/_flutter" || true

# 4. Build Flutter Web Release
echo "Building Flutter Web Release..."
flutter build web --release --base-href /
