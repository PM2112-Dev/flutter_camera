#!/bin/sh

# Fail this script if any subcommand fails.
set -e

cd $CI_PRIMARY_REPOSITORY_PATH

echo "════════════════════════════════════════════════════════════"
echo "🔍 Pre-Xcodebuild Checks"
echo "════════════════════════════════════════════════════════════"

# Add Flutter to PATH
export PATH="$PATH:$HOME/flutter/bin"

# Verify Flutter is available
echo "✅ Flutter version:"
flutter --version

# Clean and rebuild if needed
echo "🧹 Cleaning build artifacts..."
flutter clean

# Ensure dependencies are up to date
echo "📦 Updating dependencies..."
flutter pub get

# Generate code
echo "🔨 Generating code..."
flutter pub run build_runner build --delete-conflicting-outputs

# Verify iOS build can be performed
echo "✅ Verifying iOS configuration..."
flutter build ios --config-only --no-codesign

echo "════════════════════════════════════════════════════════════"
echo "✅ Pre-Xcodebuild checks complete!"
echo "════════════════════════════════════════════════════════════"

exit 0
