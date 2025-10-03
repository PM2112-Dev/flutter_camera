#!/bin/sh#!/bin/sh



# Fail this script if any subcommand fails.# Fail this script if any subcommand fails.

set -eset -e



# The default execution directory of this script is the ci_scripts directory.# The default execution directory of this script is the ci_scripts directory.

cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.



echo "════════════════════════════════════════════════════════════"echo "════════════════════════════════════════════════════════════"

echo "📱 Installing Flutter SDK for Xcode Cloud"echo "📱 Installing Flutter SDK for Xcode Cloud"

echo "════════════════════════════════════════════════════════════"echo "════════════════════════════════════════════════════════════"



# Install Flutter# Install Flutter

# Use fixed version for reproducibility# Use fixed version for reproducibility

FLUTTER_VERSION="3.24.0"FLUTTER_VERSION="3.24.0"



# Download Flutter# Download Flutter

echo "⬇️  Downloading Flutter ${FLUTTER_VERSION}..."echo "⬇️  Downloading Flutter ${FLUTTER_VERSION}..."

git clone https://github.com/flutter/flutter.git --depth 1 -b ${FLUTTER_VERSION} $HOME/fluttergit clone https://github.com/flutter/flutter.git --depth 1 -b ${FLUTTER_VERSION} $HOME/flutter



# Add Flutter to PATH# Add Flutter to PATH

export PATH="$PATH:$HOME/flutter/bin"export PATH="$PATH:$HOME/flutter/bin"



# Check Flutter version# Check Flutter version

echo "✅ Flutter installed:"echo "✅ Flutter installed:"

flutter --versionflutter --version



# Disable analytics# Disable analytics

echo "🔇 Disabling analytics..."echo "🔇 Disabling analytics..."

flutter config --no-analyticsflutter config --no-analytics



# Run Flutter Doctor# Run Flutter Doctor

echo "🏥 Running Flutter Doctor..."echo "🏥 Running Flutter Doctor..."

flutter doctorflutter doctor



# Get Flutter dependencies# Get Flutter dependencies

echo "📦 Getting Flutter dependencies..."echo "📦 Getting Flutter dependencies..."

flutter pub getflutter pub get



# Generate required files# Generate required files

echo "🔨 Generating code with build_runner..."echo "🔨 Generating code with build_runner..."

flutter pub run build_runner build --delete-conflicting-outputsflutter pub run build_runner build --delete-conflicting-outputs



# Install CocoaPods dependencies# Install CocoaPods dependencies

echo "📦 Installing CocoaPods dependencies..."echo "📦 Installing CocoaPods dependencies..."

cd ioscd ios

pod installpod install



echo "════════════════════════════════════════════════════════════"echo "════════════════════════════════════════════════════════════"

echo "✅ Flutter setup complete!"echo "✅ Flutter setup complete!"

echo "════════════════════════════════════════════════════════════"echo "════════════════════════════════════════════════════════════"



exit 0exit 0

