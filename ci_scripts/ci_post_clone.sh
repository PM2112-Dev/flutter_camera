#!/bin/sh#!/bin/sh#!/bin/sh



# Fail this script if any subcommand fails.

set -e

# Fail this script if any subcommand fails.# Fail this script if any subcommand fails.

# The default execution directory of this script is the ci_scripts directory.

cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.set -eset -e



echo "════════════════════════════════════════════════════════════"

echo "📱 Installing Flutter SDK for Xcode Cloud"

echo "════════════════════════════════════════════════════════════"# The default execution directory of this script is the ci_scripts directory.# The default execution directory of this script is the ci_scripts directory.



# Install Fluttercd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.

# Use fixed version for reproducibility

FLUTTER_VERSION="3.24.0"



# Download Flutterecho "════════════════════════════════════════════════════════════"echo "════════════════════════════════════════════════════════════"

echo "⬇️  Downloading Flutter ${FLUTTER_VERSION}..."

git clone https://github.com/flutter/flutter.git --depth 1 -b ${FLUTTER_VERSION} $HOME/flutterecho "📱 Installing Flutter SDK for Xcode Cloud"echo "📱 Installing Flutter SDK for Xcode Cloud"



# Add Flutter to PATHecho "════════════════════════════════════════════════════════════"echo "════════════════════════════════════════════════════════════"

export PATH="$PATH:$HOME/flutter/bin"



# Check Flutter version

echo "✅ Flutter installed:"# Install Flutter# Install Flutter

flutter --version

# Use fixed version for reproducibility# Use fixed version for reproducibility

# Disable analytics

echo "🔇 Disabling analytics..."FLUTTER_VERSION="3.24.0"FLUTTER_VERSION="3.24.0"

flutter config --no-analytics



# Run Flutter Doctor

echo "🏥 Running Flutter Doctor..."# Download Flutter# Download Flutter

flutter doctor

echo "⬇️  Downloading Flutter ${FLUTTER_VERSION}..."echo "⬇️  Downloading Flutter ${FLUTTER_VERSION}..."

# Get Flutter dependencies

echo "📦 Getting Flutter dependencies..."git clone https://github.com/flutter/flutter.git --depth 1 -b ${FLUTTER_VERSION} $HOME/fluttergit clone https://github.com/flutter/flutter.git --depth 1 -b ${FLUTTER_VERSION} $HOME/flutter

flutter pub get



# Generate required files

echo "🔨 Generating code with build_runner..."# Add Flutter to PATH# Add Flutter to PATH

flutter pub run build_runner build --delete-conflicting-outputs

export PATH="$PATH:$HOME/flutter/bin"export PATH="$PATH:$HOME/flutter/bin"

# Install CocoaPods dependencies

echo "📦 Installing CocoaPods dependencies..."

cd ios

pod install# Check Flutter version# Check Flutter version



echo "════════════════════════════════════════════════════════════"echo "✅ Flutter installed:"echo "✅ Flutter installed:"

echo "✅ Flutter setup complete!"

echo "════════════════════════════════════════════════════════════"flutter --versionflutter --version



exit 0


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

