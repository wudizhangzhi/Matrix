# Release Guide

This document describes the release process for Matrix Terminal.

## Release Process

Matrix Terminal uses GitHub Releases with automated APK building via GitHub Actions.

### Prerequisites

1. Ensure all changes are committed and pushed to the main branch
2. Update version number in `pubspec.yaml`
3. Update `CHANGELOG.md` with release notes
4. All tests pass (run `flutter test`)
5. App builds successfully (run `flutter build apk --release`)

### Creating a Release

#### Step 1: Update Version

Edit `pubspec.yaml` and update the version number:

```yaml
version: X.Y.Z+BUILD_NUMBER
```

- **X.Y.Z** is the semantic version (e.g., 1.1.0)
- **BUILD_NUMBER** is the build/version code (e.g., 2)

Example: `version: 1.2.0+3`

#### Step 2: Update CHANGELOG

Add a new section to `CHANGELOG.md` documenting:
- New features
- Bug fixes
- Breaking changes
- Deprecations

Follow the [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format.

#### Step 3: Commit and Push

```bash
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: bump version to X.Y.Z"
git push origin main
```

#### Step 4: Create Git Tag

```bash
git tag -a vX.Y.Z -m "vX.Y.Z - Release Title"
git push origin vX.Y.Z
```

Example:
```bash
git tag -a v1.2.0 -m "v1.2.0 - Enhanced Features"
git push origin v1.2.0
```

#### Step 5: Create GitHub Release

1. Go to https://github.com/wudizhangzhi/Matrix/releases/new
2. Select the tag you just created (vX.Y.Z)
3. Set the release title (e.g., "v1.2.0 - Enhanced Features")
4. Copy the relevant section from CHANGELOG.md into the release description
5. Check "Set as the latest release"
6. Click "Publish release"

The GitHub Actions workflow (`.github/workflows/build-apk.yml`) will automatically:
- Build the release APK
- Upload it to the GitHub Release

#### Step 6: Verify Release

1. Wait for the GitHub Actions workflow to complete (check the Actions tab)
2. Verify the APK is attached to the release
3. Download and test the APK on a device

## Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (X.0.0): Incompatible API changes or major redesign
- **MINOR** (1.X.0): New features, backward compatible
- **PATCH** (1.1.X): Bug fixes, backward compatible

Build number (the +N part) should increment with each release:
- 1.0.0+1 (first release)
- 1.1.0+2 (second release)
- 1.2.0+3 (third release)

## Release Checklist

Before creating a release, ensure:

- [ ] Version number updated in `pubspec.yaml`
- [ ] CHANGELOG.md updated with release notes
- [ ] All new features documented
- [ ] All tests passing
- [ ] App builds successfully (`flutter build apk --release`)
- [ ] Code is linted (`flutter analyze`)
- [ ] Git tag created and pushed
- [ ] GitHub Release created
- [ ] APK automatically uploaded by CI
- [ ] Release tested on device

## Hotfix Releases

For critical bug fixes:

1. Create a hotfix branch from the release tag
2. Make the minimal necessary changes
3. Update version to X.Y.Z+1 (patch increment)
4. Update CHANGELOG.md
5. Follow the normal release process

## Build Configuration

The release APK is built with:
- **Signing**: Debug keystore (for now, see TODO in `android/app/build.gradle.kts`)
- **Minification**: Disabled by default
- **Target SDK**: Latest stable Flutter version
- **Min SDK**: Android 5.0 (API 21)

### TODO: Production Signing

For production releases, you should:

1. Generate a release keystore
2. Update `android/app/build.gradle.kts` with proper signing configuration
3. Store keystore credentials securely (GitHub Secrets)
4. Update the GitHub Actions workflow to use the release keystore

## Troubleshooting

### Build Fails on CI

- Check the Actions log for error messages
- Ensure all dependencies are compatible
- Verify Flutter version in workflow matches local

### APK Not Uploaded

- Check that the workflow has `contents: write` permission
- Verify the APK path in the workflow matches the actual build output
- Ensure the release is published (not draft)

## Release History

See [CHANGELOG.md](CHANGELOG.md) for complete release history.
