#!/bin/sh#!/bin/sh



# Fail this script if any subcommand fails.# Fail this script if any subcommand fails.

set -eset -e



cd $CI_PRIMARY_REPOSITORY_PATHcd $CI_PRIMARY_REPOSITORY_PATH



echo "════════════════════════════════════════════════════════════"echo "════════════════════════════════════════════════════════════"

echo "🔍 Pre-Xcodebuild Checks"echo "🔍 Pre-Xcodebuild Checks"

echo "════════════════════════════════════════════════════════════"echo "════════════════════════════════════════════════════════════"



# Add Flutter to PATH# Add Flutter to PATH

export PATH="$PATH:$HOME/flutter/bin"export PATH="$PATH:$HOME/flutter/bin"



# Verify Flutter is available# Verify Flutter is available

echo "✅ Flutter version:"echo "✅ Flutter version:"

flutter --versionflutter --version



# Clean and rebuild if needed# Clean and rebuild if needed

echo "🧹 Cleaning build artifacts..."echo "🧹 Cleaning build artifacts..."

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

