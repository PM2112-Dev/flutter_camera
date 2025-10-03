#!/bin/sh

# Fail this script if any subcommand fails.
set -e

echo "════════════════════════════════════════════════════════════"
echo "📦 Post-Xcodebuild Tasks"
echo "════════════════════════════════════════════════════════════"

cd $CI_PRIMARY_REPOSITORY_PATH

# Add Flutter to PATH
export PATH="$PATH:$HOME/flutter/bin"

# Optional: Run Flutter analyze
echo "🔍 Running Flutter analyze..."
flutter analyze || echo "⚠️  Flutter analyze found issues, but continuing..."

# Optional: Run tests
# echo "🧪 Running Flutter tests..."
# flutter test

echo "════════════════════════════════════════════════════════════"
echo "✅ Post-Xcodebuild tasks complete!"
echo "════════════════════════════════════════════════════════════"

exit 0
