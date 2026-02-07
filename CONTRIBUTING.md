# Contributing to Matrix Terminal

Thank you for your interest in contributing to Matrix Terminal! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for all contributors.

## How Can I Contribute?

### Reporting Bugs

Before creating a bug report, please check existing issues to avoid duplicates.

**When submitting a bug report, include:**
- A clear and descriptive title
- Steps to reproduce the issue
- Expected behavior vs. actual behavior
- Screenshots (if applicable)
- Device information (Android version, device model)
- App version
- Relevant logs or error messages

### Suggesting Features

Feature suggestions are welcome! Please provide:
- A clear and descriptive title
- Detailed description of the proposed feature
- Use cases and benefits
- Mockups or examples (if applicable)

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following the coding guidelines below
3. **Test your changes** thoroughly
4. **Update documentation** if needed
5. **Submit a pull request** with a clear description

## Development Setup

### Prerequisites

- Flutter SDK 3.10.0+
- Dart SDK
- Android Studio or VS Code
- Android SDK with API 21+
- Java 17

### Getting Started

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/Matrix.git
cd Matrix

# Install dependencies
flutter pub get

# Generate code for Drift database
flutter pub run build_runner build

# Run the app
flutter run
```

### Project Structure

```
lib/
├── app/          # App initialization, routing, theme
├── features/     # Feature modules (host, terminal, settings)
├── core/         # Core services (SSH, storage, background)
└── main.dart     # Entry point
```

## Coding Guidelines

### Dart Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Run `flutter analyze` before committing
- Use `flutter format .` to format code

### Code Organization

- **One class per file** (with exceptions for small helper classes)
- **Use meaningful names** for variables, functions, and classes
- **Add comments** for complex logic or non-obvious code
- **Keep functions small** and focused on a single task

### State Management

- Use **Riverpod** for state management
- Follow the existing provider patterns in the codebase
- Keep business logic separate from UI

### Database Changes

When modifying the database schema:

1. Update the table definitions in `lib/core/storage/database.dart`
2. Increment the schema version
3. Add migration logic if needed
4. Run `flutter pub run build_runner build --delete-conflicting-outputs`
5. Test migration from the previous version

### Testing

- Write tests for new features
- Ensure existing tests pass: `flutter test`
- Test on real Android devices when possible
- Test with different Android versions (API 21+)

### UI/UX Guidelines

- Follow Material Design principles
- Maintain consistency with existing UI
- Support both light and dark themes
- Ensure accessibility (contrast, touch targets)
- Test with different screen sizes

## Git Workflow

### Branch Naming

- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation updates
- `refactor/description` - Code refactoring

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(terminal): add toolbar customization
fix(ssh): resolve connection timeout issue
docs(readme): update installation instructions
```

## Pull Request Process

1. **Update documentation** - README, CHANGELOG, etc.
2. **Run tests** - Ensure all tests pass
3. **Check for lint errors** - `flutter analyze`
4. **Build the APK** - `flutter build apk --release`
5. **Fill out the PR template** completely
6. **Request review** from maintainers

### PR Review Criteria

- Code quality and style
- Test coverage
- Documentation completeness
- Performance impact
- Backward compatibility
- Security implications

## Release Process

Only maintainers can create releases. See [docs/RELEASE.md](docs/RELEASE.md) for the release process.

## Need Help?

- 📖 Check the [documentation](docs/)
- 💬 Open a [discussion](https://github.com/wudizhangzhi/Matrix/discussions)
- 🐛 Report [issues](https://github.com/wudizhangzhi/Matrix/issues)

## License

By contributing to Matrix Terminal, you agree that your contributions will be licensed under the project's license.

## Recognition

All contributors will be recognized in the project. Thank you for helping make Matrix Terminal better! 🎉
