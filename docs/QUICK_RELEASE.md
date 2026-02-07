# Quick Release Guide

This is a quick reference for creating releases. For detailed instructions, see [RELEASE.md](RELEASE.md).

## Pre-Release Checklist

- [ ] All features complete and tested
- [ ] All tests passing: `flutter test`
- [ ] Code analysis clean: `flutter analyze`
- [ ] APK builds successfully: `flutter build apk --release`
- [ ] Version updated in `pubspec.yaml`
- [ ] `CHANGELOG.md` updated with new version
- [ ] All changes committed to main branch

## Quick Steps

### 1. Update Version

```yaml
# pubspec.yaml
version: X.Y.Z+N
```

### 2. Update Changelog

```markdown
# CHANGELOG.md
## [X.Y.Z] - YYYY-MM-DD

### Added
- Feature descriptions

### Fixed
- Bug fix descriptions
```

### 3. Commit and Tag

```bash
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: bump version to X.Y.Z"
git push origin main

git tag -a vX.Y.Z -m "vX.Y.Z - Release Title"
git push origin vX.Y.Z
```

### 4. Create GitHub Release

1. Go to: https://github.com/wudizhangzhi/Matrix/releases/new
2. Select tag: vX.Y.Z
3. Title: vX.Y.Z - Release Title
4. Copy description from CHANGELOG.md (or use [RELEASE_TEMPLATE.md](RELEASE_TEMPLATE.md))
5. Check "Set as the latest release"
6. Click "Publish release"

### 5. Verify

- [ ] GitHub Actions workflow completes successfully
- [ ] APK is attached to the release
- [ ] Download and test APK on device

## Version Format

```
MAJOR.MINOR.PATCH+BUILD
  │     │      │     │
  │     │      │     └─ Build number (incremental)
  │     │      └─────── Bug fixes
  │     └────────────── New features
  └──────────────────── Breaking changes
```

Example: `1.2.3+5`
- Version: 1.2.3
- Build: 5

## Common Scenarios

### Bug Fix Release (Patch)
```
Current: 1.1.0+2
New:     1.1.1+3
```

### Feature Release (Minor)
```
Current: 1.1.0+2
New:     1.2.0+3
```

### Breaking Changes (Major)
```
Current: 1.1.0+2
New:     2.0.0+3
```

## Troubleshooting

### Build fails in GitHub Actions
- Check Actions tab for logs
- Verify Flutter dependencies are compatible
- Test build locally first

### APK not uploaded
- Verify workflow has `contents: write` permission
- Check APK path matches actual output
- Ensure release is published, not draft

## Quick Commands

```bash
# Check current version
grep "version:" pubspec.yaml

# View recent tags
git tag -l | tail -5

# Test build locally
flutter clean && flutter build apk --release

# Check APK size
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

## Resources

- [Full Release Guide](RELEASE.md)
- [Release Template](RELEASE_TEMPLATE.md)
- [Changelog](../CHANGELOG.md)
- [GitHub Releases](https://github.com/wudizhangzhi/Matrix/releases)
