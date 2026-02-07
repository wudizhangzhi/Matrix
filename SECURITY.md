# Security Policy

## Supported Versions

We currently support the following versions of Matrix Terminal with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.1.x   | :white_check_mark: |
| 1.0.x   | :x:                |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security issue in Matrix Terminal, please follow these steps:

### 1. Do Not Publicly Disclose

Please **do not** create a public GitHub issue for security vulnerabilities. This helps protect users while we work on a fix.

### 2. Contact Us Privately

Report security vulnerabilities through one of these methods:

- **Preferred**: Use GitHub's private vulnerability reporting feature
  - Go to the [Security tab](https://github.com/wudizhangzhi/Matrix/security)
  - Click "Report a vulnerability"
  
- **Alternative**: Email the maintainer directly (find contact info on GitHub profile)

### 3. Provide Details

Please include as much information as possible:

- Type of vulnerability (e.g., credential exposure, injection, etc.)
- Steps to reproduce the issue
- Affected versions
- Potential impact
- Any suggested fixes (if you have them)

### 4. Response Timeline

We aim to respond to security reports within:

- **Initial response**: 48 hours
- **Status update**: 7 days
- **Fix timeline**: 30 days for critical issues

## Security Considerations

### Data Storage

Matrix Terminal handles sensitive information:

- **SSH passwords**: Encrypted using `flutter_secure_storage`
- **Private keys**: Encrypted in secure storage
- **TOTP secrets**: Encrypted in secure storage
- **Host configurations**: Stored in local SQLite database

### Network Security

- SSH connections use standard SSH protocol encryption
- No data is transmitted to external servers
- All connections are direct to user-specified hosts

### Permissions

The app requests these Android permissions:

- **Internet**: Required for SSH connections
- **Wake Lock**: Keeps connections alive
- **Notifications**: Optional, for connection alerts
- **Foreground Service**: Background connection support

### Best Practices for Users

1. **Use strong authentication**
   - Prefer SSH key authentication over passwords
   - Enable TOTP when available
   - Use strong, unique passwords

2. **Keep the app updated**
   - Install security updates promptly
   - Check for new releases regularly

3. **Secure your device**
   - Use device encryption
   - Set a strong device PIN/password
   - Enable biometric authentication

4. **Review host configurations**
   - Only connect to trusted servers
   - Regularly audit saved hosts
   - Remove unused configurations

5. **Be cautious with clipboard**
   - Clear sensitive data from clipboard after use
   - Be aware of clipboard history features

## Known Security Limitations

### Debug Signing (Current Version)

⚠️ **Important**: The current release APKs are signed with debug keys for development convenience. This is suitable for testing but **not recommended for production use**.

For production deployments, we recommend:
- Building from source with your own release key
- Or waiting for future releases with proper production signing

### Platform Security

The security of Matrix Terminal depends on:
- Android OS security features
- Device manufacturer security implementations
- User device configuration

We cannot guarantee security on:
- Rooted devices
- Devices with compromised security
- Devices running outdated Android versions

## Security Updates

Security fixes are released as:
- **Critical**: Immediate patch release
- **High**: Patch release within 7 days
- **Medium**: Include in next planned release
- **Low**: Include in future release

## Vulnerability Disclosure

After a fix is released, we will:
1. Credit the reporter (with permission)
2. Document the issue in CHANGELOG.md
3. Publish details in release notes
4. Update this security policy if needed

## Security Audit

If you're interested in performing a security audit of Matrix Terminal, please contact the maintainers first to coordinate efforts.

## Additional Resources

- [OWASP Mobile Security Project](https://owasp.org/www-project-mobile-security/)
- [Android Security Best Practices](https://developer.android.com/topic/security/best-practices)
- [SSH Best Practices](https://www.ssh.com/academy/ssh/security)

---

Last updated: 2026-02-07
