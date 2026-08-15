# Technical notes

## Root cause

ESP Mounter Pro 1.9.1 contains legacy version-detection logic dating from the OS X 10.x era. It splits the OS product version and uses the second component as the value used for a modern/legacy path decision.

On Tahoe 26.6.1 this yields `6`, which falls on the legacy path even though Tahoe is a much newer operating system.

The legacy path can return `N/A` for an unmounted EFI mount point. A later validity check does not reject that string, allowing the UI to treat an unmounted EFI partition as if it were already mounted. This is why the application can show **Unmount / Open** immediately on Tahoe.

## Binary patch

Validated executable offset:

```text
0xA185 / 41349 decimal
```

Instruction bytes before:

```text
41 B8 01 00 00 00
```

Instruction bytes after:

```text
41 B8 00 00 00 00
```

This changes the version-array index from `1` to `0`, causing Tahoe 26.x to be represented by major version `26` for the existing branch decision.

## Privileged helper

The compatibility patch does not modify the helper binary. The patcher verifies that the helper embedded in the user's own ESP Mounter Pro application exactly matches the validated original SHA-256, then installs/registers that same helper under:

```text
/Library/PrivilegedHelperTools/com.Micky1979.EspMounterProHelper
```

with the corresponding LaunchDaemon:

```text
/Library/LaunchDaemons/com.Micky1979.EspMounterProHelper.plist
```

The helper is expected to be `root:wheel`, mode `0544`.

## Signing

Changing a byte invalidates the original GUI code signature. The patcher therefore clears stale extended attributes, removes the previous `_CodeSignature` directory and performs a local ad-hoc signature using macOS `codesign`.

This is not Developer ID signing or notarization and does not represent endorsement by the original author.
