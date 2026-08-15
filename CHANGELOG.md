# Changelog

## 2.0.0 — 2026-08-15

- Initial public GitHub release.
- Adds strict validation for macOS Tahoe 26 on Intel/x86_64.
- Validates the exact ESP Mounter Pro 1.9.1 executable and original helper by SHA-256.
- Applies the one-byte `objectAtIndex:1 -> objectAtIndex:0` Tahoe compatibility fix.
- Creates a complete pre-patch backup on the Desktop.
- Locally ad-hoc signs the modified GUI after clearing stale extended attributes.
- Reinstalls/registers the untouched original helper from the user's own ESP Mounter Pro copy.
- Verifies helper ownership, permissions, hash and `launchd` registration.
- Supports re-running on an already-patched copy to repair helper registration.
