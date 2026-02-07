# Release Template

Use this template when creating a new GitHub Release.

## Release Title Format

```
vX.Y.Z - Brief Description
```

Example: `v1.2.0 - Enhanced Features and Bug Fixes`

## Release Description Template

```markdown
## What's New in vX.Y.Z

[Brief overview of the release - 1-2 sentences]

### ✨ New Features

- Feature 1 description
- Feature 2 description
- Feature 3 description

### 🐛 Bug Fixes

- Fix 1 description
- Fix 2 description

### 🔧 Improvements

- Improvement 1 description
- Improvement 2 description

### 📝 Documentation

- Documentation update 1
- Documentation update 2

### ⚠️ Breaking Changes (if any)

- Breaking change 1 description
- Migration instructions

## 📥 Download

Download the APK below and install on your Android device (Android 5.0+).

## 🔍 Checksums

The APK checksums will be added automatically by the GitHub Actions workflow.

## 📖 Full Changelog

See [CHANGELOG.md](https://github.com/wudizhangzhi/Matrix/blob/main/CHANGELOG.md) for complete details.

## 🙏 Contributors

Thanks to all contributors who made this release possible!

---

**Note:** This is an automated build. If you encounter any issues, please report them on the [Issues](https://github.com/wudizhangzhi/Matrix/issues) page.
```

## Tips

1. **Keep it concise**: Users want to know what changed, not every implementation detail
2. **Use emojis**: They make the release notes more readable and engaging
3. **Highlight breaking changes**: Make them very visible if present
4. **Link to issues/PRs**: Reference relevant issues with #123 syntax
5. **Include screenshots**: For UI changes, include before/after screenshots
6. **Credit contributors**: Mention contributors with @username
7. **Test the download**: Always verify the APK downloads and installs correctly

## Example: v1.1.0 Release

```markdown
## What's New in v1.1.0

This release brings powerful customization options and productivity enhancements to Matrix Terminal!

### ✨ New Features

#### Toolbar Presets & Customization
- **Configurable toolbar profiles** with preset support (General, tmux, vim)
- **Custom toolbar creation** - Build your own perfect key layout
- **Drag-to-reorder** interface for easy customization
- **Per-host profiles** - Different toolbars for different servers

#### Clipboard Image Paste
- **Paste images as base64** directly from Android clipboard
- **Smart size warnings** to prevent terminal flooding
- **Preview thumbnail** before pasting

#### Android Notifications
- **Connection state alerts** - Know when connections drop
- **Command completion detection** - Get notified when long commands finish
- **Custom pattern triggers** - Create your own notification rules

### 🐛 Bug Fixes

- Fixed curly braces lint warnings in settings screen

### 📖 Documentation

- Added comprehensive CHANGELOG.md
- Created release process guide
- Updated README with detailed feature list

## 📥 Download

Download the APK below and install on your Android device (Android 5.0+).

## 📖 Full Changelog

See [CHANGELOG.md](https://github.com/wudizhangzhi/Matrix/blob/main/CHANGELOG.md) for complete details.
```
