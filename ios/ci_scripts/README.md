# Xcode Cloud CI Scripts# Xcode Cloud CI Scripts



This directory contains scripts for building the Flutter app on Xcode Cloud.This directory contains scripts for building the Flutter app on Xcode Cloud.



## Scripts## Scripts



### ci_post_clone.sh### ci_post_clone.sh

Runs after the repository is cloned. This script:Runs after the repository is cloned. This script:

- Downloads and installs Flutter SDK (version 3.24.0)- Downloads and installs Flutter SDK

- Runs `flutter pub get` to fetch dependencies- Runs `flutter pub get` to fetch dependencies

- Runs `build_runner` to generate code- Runs `build_runner` to generate code

- Installs CocoaPods dependencies with `pod install`- Installs CocoaPods dependencies



### ci_pre_xcodebuild.sh### ci_pre_xcodebuild.sh

Runs before Xcode starts building. This script:Runs before Xcode starts building. This script:

- Verifies Flutter installation- Verifies Flutter installation

- Cleans build artifacts with `flutter clean`- Cleans build artifacts

- Updates dependencies- Updates dependencies

- Generates required code- Generates required code

- Configures iOS build with `flutter build ios --config-only`- Configures iOS build



### ci_post_xcodebuild.sh### ci_post_xcodebuild.sh

Runs after Xcode finishes building. This script:Runs after Xcode finishes building. This script:

- Runs `flutter analyze` to check code quality- Runs Flutter analyze (optional)

- Optionally runs tests (currently commented out)- Runs Flutter tests (optional, currently commented out)



## Setup Instructions## Requirements



1. **Make scripts executable:**- Flutter version: 3.24.0 (configured in ci_post_clone.sh)

   ```bash- Xcode Cloud workflow must point to the `ios` branch

   chmod +x ci_scripts/*.sh- Scripts must be executable (chmod +x)

   ```

## Troubleshooting

2. **Commit and push to ios branch:**

   ```bashIf the build fails:

   git checkout ios1. Check the Xcode Cloud logs for the specific error

   git add ci_scripts/2. Verify all scripts are executable

   git commit -m "Add Xcode Cloud CI scripts"3. Ensure the Flutter version is available

   git push origin ios4. Check if all dependencies are listed in pubspec.yaml

   ```

## Local Testing

3. **Configure Xcode Cloud:**

   - Go to App Store ConnectTo test these scripts locally:

   - Select your app → Xcode Cloud

   - Ensure workflow points to `ios` branch```bash

   - Environment should use latest Xcode versioncd ios/ci_scripts

./ci_post_clone.sh

## Requirements./ci_pre_xcodebuild.sh

```

- Flutter SDK version: 3.24.0

- Xcode Cloud environment with macOS## Notes

- All dependencies listed in `pubspec.yaml`

- CocoaPods installed (available by default on Xcode Cloud)- Scripts use `set -e` to fail fast on any error

- Flutter SDK is downloaded to `$HOME/flutter`

## How It Works- All scripts output colored emojis for easy visual parsing


```
1. Clone Repository
   ↓
2. Run ci_post_clone.sh
   - Install Flutter SDK
   - Get dependencies
   - Generate code
   - Install Pods
   ↓
3. Run ci_pre_xcodebuild.sh
   - Verify setup
   - Clean & regenerate
   - Configure iOS build
   ↓
4. Xcode Build Process
   - Compile Swift/Objective-C
   - Link frameworks
   - Sign app
   ↓
5. Run ci_post_xcodebuild.sh
   - Analyze code
   - Run tests (optional)
```

## Troubleshooting

### Scripts not found
- Ensure scripts are in `ci_scripts/` at repository root
- Verify scripts are committed to the `ios` branch
- Check script permissions: `ls -l ci_scripts/`

### Flutter download fails
- Check internet connectivity
- Try a different Flutter version
- Use stable channel: `stable` instead of version number

### Pod install fails
- Verify `Podfile` exists in `ios/` directory
- Check `Podfile.lock` is committed
- Ensure all pods are available

### Build takes too long
- First build: ~10-15 minutes (downloads Flutter)
- Subsequent builds: ~5-8 minutes (cached)

## Customization

### Change Flutter Version
Edit `ci_post_clone.sh`:
```bash
FLUTTER_VERSION="3.24.0"  # Change to your version
```

### Add Environment Variables
Create `.env` file or add to Xcode Cloud environment:
```
API_BASE_URL=https://api.example.com
```

### Enable Tests
Uncomment in `ci_post_xcodebuild.sh`:
```bash
flutter test
```

## Support

For issues with:
- **Flutter**: https://flutter.dev/docs
- **Xcode Cloud**: https://developer.apple.com/xcode-cloud/
- **This project**: Check repository issues

## Notes

- ✅ Scripts use `set -e` to fail fast on errors
- ✅ Flutter installed to `$HOME/flutter`
- ✅ PATH updated automatically in each script
- ✅ All output includes emojis for easy visual parsing
- ✅ Compatible with Xcode Cloud and local testing
