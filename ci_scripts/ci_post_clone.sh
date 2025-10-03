#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# The default execution directory of this script is the ci_scripts directory.
cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.

echo "════════════════════════════════════════════════════════════"
echo "📱 Installing Flutter SDK for Xcode Cloud"
echo "════════════════════════════════════════════════════════════"

# Install Flutter
# Use fixed version for reproducibility
FLUTTER_VERSION="3.35.5"

# Download Flutter
echo "⬇️  Downloading Flutter ${FLUTTER_VERSION}..."
git clone https://github.com/flutter/flutter.git --depth 1 -b ${FLUTTER_VERSION} $HOME/flutter

# Add Flutter to PATH
export PATH="$PATH:$HOME/flutter/bin"

# Check Flutter version
echo "✅ Flutter installed:"
flutter --version

# Disable analytics
echo "🔇 Disabling analytics..."
flutter config --no-analytics

# Run Flutter Doctor
echo "🏥 Running Flutter Doctor..."
flutter doctor

# Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Generate required files
echo "🔨 Generating code with build_runner..."
flutter pub run build_runner build --delete-conflicting-outputs

# Precache iOS artifacts
echo "⬇️  Downloading Flutter iOS artifacts..."
flutter precache --ios

# Install CocoaPods dependencies
echo "📦 Installing CocoaPods dependencies..."
cd ios
pod install

echo "════════════════════════════════════════════════════════════"
echo "✅ Flutter setup complete!"
echo "════════════════════════════════════════════════════════════"

exit 0
