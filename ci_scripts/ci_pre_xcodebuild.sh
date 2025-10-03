#!/bin/sh#!/bin/sh#!/bin/sh



# Fail this script if any subcommand fails.

set -e

# Fail this script if any subcommand fails.# Fail this script if any subcommand fails.

cd $CI_PRIMARY_REPOSITORY_PATH

set -eset -e

echo "════════════════════════════════════════════════════════════"

echo "🔍 Pre-Xcodebuild Checks"

echo "════════════════════════════════════════════════════════════"

cd $CI_PRIMARY_REPOSITORY_PATHcd $CI_PRIMARY_REPOSITORY_PATH

# Add Flutter to PATH

export PATH="$PATH:$HOME/flutter/bin"



# Verify Flutter is availableecho "════════════════════════════════════════════════════════════"echo "════════════════════════════════════════════════════════════"

echo "✅ Flutter version:"

flutter --versionecho "🔍 Pre-Xcodebuild Checks"echo "🔍 Pre-Xcodebuild Checks"



# Clean and rebuild if neededecho "════════════════════════════════════════════════════════════"echo "════════════════════════════════════════════════════════════"

echo "🧹 Cleaning build artifacts..."

flutter clean



# Ensure dependencies are up to date# Add Flutter to PATH# Add Flutter to PATH

echo "📦 Updating dependencies..."

flutter pub getexport PATH="$PATH:$HOME/flutter/bin"export PATH="$PATH:$HOME/flutter/bin"



# Generate code

echo "🔨 Generating code..."

flutter pub run build_runner build --delete-conflicting-outputs# Verify Flutter is available# Verify Flutter is available



# Verify iOS build can be performedecho "✅ Flutter version:"echo "✅ Flutter version:"

echo "✅ Verifying iOS configuration..."

flutter build ios --config-only --no-codesignflutter --versionflutter --version



echo "════════════════════════════════════════════════════════════"

echo "✅ Pre-Xcodebuild checks complete!"

echo "════════════════════════════════════════════════════════════"# Clean and rebuild if needed# Clean and rebuild if needed



exit 0echo "🧹 Cleaning build artifacts..."echo "🧹 Cleaning build artifacts..."


flutter cleanflutter clean



# Ensure dependencies are up to date# Ensure dependencies are up to date

echo "📦 Updating dependencies..."echo "📦 Updating dependencies..."

flutter pub getflutter pub get



# Generate code# Generate code

echo "🔨 Generating code..."echo "🔨 Generating code..."

flutter pub run build_runner build --delete-conflicting-outputsflutter pub run build_runner build --delete-conflicting-outputs



# Verify iOS build can be performed# Verify iOS build can be performed

echo "✅ Verifying iOS configuration..."echo "✅ Verifying iOS configuration..."

flutter build ios --config-only --no-codesignflutter build ios --config-only --no-codesign



echo "════════════════════════════════════════════════════════════"echo "════════════════════════════════════════════════════════════"

echo "✅ Pre-Xcodebuild checks complete!"echo "✅ Pre-Xcodebuild checks complete!"

echo "════════════════════════════════════════════════════════════"echo "════════════════════════════════════════════════════════════"



exit 0exit 0

