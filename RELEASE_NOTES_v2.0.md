# ESP Mounter Pro Tahoe Patcher 2.0

First public release of the unofficial Tahoe 26 compatibility patch for ESP Mounter Pro 1.9.1.

## Highlights

- Fixes incorrect EFI mount-state detection on macOS Tahoe 26.
- Changes only one byte in the validated ESP Mounter Pro GUI executable.
- Does not modify the original privileged helper binary.
- Strict SHA-256 and byte-pattern validation before changes are applied.
- Automatic full backup before patching.
- Local ad-hoc signing of the modified GUI.
- Registration/verification of the untouched helper from the user's own original app.
- Tested on Tahoe 26.6.1 (25G76) with internal, USB and external EFI partitions.

## Important

ESP Mounter Pro itself is **not included** in this release. Users must obtain their own original ESP Mounter Pro 1.9.1 copy.

ESP Mounter Pro © Micky1979. All rights reserved.
