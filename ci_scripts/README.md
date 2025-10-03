# Xcode Cloud CI Scripts

This directory contains scripts for building the Flutter app on Xcode Cloud.

## Scripts

### ci_post_clone.sh
Runs after the repository is cloned. This script:
- Downloads and installs Flutter SDK
- Runs `flutter pub get` to fetch dependencies
- Runs `build_runner` to generate code
- Installs CocoaPods dependencies

### ci_pre_xcodebuild.sh
Runs before Xcode starts building. This script:
- Verifies Flutter installation
- Cleans build artifacts
- Updates dependencies
- Generates required code
- Configures iOS build

### ci_post_xcodebuild.sh
Runs after Xcode finishes building. This script:
- Runs Flutter analyze (optional)
- Runs Flutter tests (optional, currently commented out)

## Requirements

- Flutter version: 3.24.0 (configured in ci_post_clone.sh)
- Xcode Cloud workflow must point to the `ios` branch
- Scripts must be executable (chmod +x)

## Troubleshooting

If the build fails:
1. Check the Xcode Cloud logs for the specific error
2. Verify all scripts are executable
3. Ensure the Flutter version is available
4. Check if all dependencies are listed in pubspec.yaml

## Local Testing

To test these scripts locally:

```bash
cd ios/ci_scripts
./ci_post_clone.sh
./ci_pre_xcodebuild.sh
```

## Notes

- Scripts use `set -e` to fail fast on any error
- Flutter SDK is downloaded to `$HOME/flutter`
- All scripts output colored emojis for easy visual parsing
