#!/bin/sh#!/bin/sh#!/bin/sh



# Fail this script if any subcommand fails.

set -e

# Fail this script if any subcommand fails.# Fail this script if any subcommand fails.

echo "════════════════════════════════════════════════════════════"

echo "📦 Post-Xcodebuild Tasks"set -eset -e

echo "════════════════════════════════════════════════════════════"



cd $CI_PRIMARY_REPOSITORY_PATH

echo "════════════════════════════════════════════════════════════"echo "════════════════════════════════════════════════════════════"

# Add Flutter to PATH

export PATH="$PATH:$HOME/flutter/bin"echo "📦 Post-Xcodebuild Tasks"echo "📦 Post-Xcodebuild Tasks"



# Optional: Run Flutter analyzeecho "════════════════════════════════════════════════════════════"echo "════════════════════════════════════════════════════════════"

echo "🔍 Running Flutter analyze..."

flutter analyze || echo "⚠️  Flutter analyze found issues, but continuing..."



# Optional: Run testscd $CI_PRIMARY_REPOSITORY_PATHcd $CI_PRIMARY_REPOSITORY_PATH

# echo "🧪 Running Flutter tests..."

# flutter test



echo "════════════════════════════════════════════════════════════"# Add Flutter to PATH# Add Flutter to PATH

echo "✅ Post-Xcodebuild tasks complete!"

echo "════════════════════════════════════════════════════════════"export PATH="$PATH:$HOME/flutter/bin"export PATH="$PATH:$HOME/flutter/bin"



exit 0


# Optional: Run Flutter analyze# Optional: Run Flutter analyze

echo "🔍 Running Flutter analyze..."echo "🔍 Running Flutter analyze..."

flutter analyze || echo "⚠️  Flutter analyze found issues, but continuing..."flutter analyze || echo "⚠️  Flutter analyze found issues, but continuing..."



# Optional: Run tests# Optional: Run tests

# echo "🧪 Running Flutter tests..."# echo "🧪 Running Flutter tests..."

# flutter test# flutter test



echo "════════════════════════════════════════════════════════════"echo "════════════════════════════════════════════════════════════"

echo "✅ Post-Xcodebuild tasks complete!"echo "✅ Post-Xcodebuild tasks complete!"

echo "════════════════════════════════════════════════════════════"echo "════════════════════════════════════════════════════════════"



exit 0exit 0

