# ESP Mounter Pro Tahoe Patch

Unofficial compatibility patch for **ESP Mounter Pro 1.9.1 by Micky1979** on **macOS Tahoe 26 (Intel / Hackintosh)**.

I have always liked ESP Mounter Pro for mounting EFI partitions: it is small, fast, and once its privileged helper is installed, EFI partitions can be mounted and unmounted without entering the administrator password every time. When Tahoe broke its disk-state detection, I wanted to keep using it.

Out of respect for the original author, this repository **does not include or redistribute ESP Mounter Pro, its privileged helper, icons, or resources**. It contains only an independent compatibility patcher that modifies the user's own original copy locally.

> ESP Mounter Pro © Micky1979. All rights reserved. This project is unofficial and is not affiliated with or endorsed by the original author.

## What breaks on Tahoe

ESP Mounter Pro was written for the OS X 10.x version-numbering scheme. Its internal version parser reads the second component of the OS version (`objectAtIndex:1`).

That works with an old version such as:

```text
10.13.x -> 13
```

But on Tahoe:

```text
26.6.1 -> 6
```

The application therefore selects its legacy mount-point path. The visible symptom is that EFI partitions which are actually unmounted may immediately appear as **Unmount / Open** instead of **Mount**.

## The fix

For the validated ESP Mounter Pro 1.9.1 executable, the Tahoe fix is one byte:

```text
File offset: 0xA185 (41349 decimal)
Original:    41 B8 01 00 00 00
Patched:     41 B8 00 00 00 00
```

In practical terms:

```text
objectAtIndex:1 -> objectAtIndex:0
```

Tahoe `26.6.1` is then interpreted using its major version (`26`), so ESP Mounter Pro follows its modern disk/mount-point code path.

The patch does **not** alter ESP mounting logic or the original privileged helper binary.

## Tested result

Confirmed on **macOS Tahoe 26.6.1 (25G76)** on Intel/Hackintosh hardware.

Tested with EFI partitions on:

- internal disks
- USB devices
- external disks

After patching, the normal workflow is restored:

```text
Mount -> Open -> Unmount
```

The original privileged helper is registered during patching, so normal Mount/Unmount operations do not request the administrator password each time.

## Requirements

- Intel / x86_64 Mac or Hackintosh
- macOS Tahoe 26
- your own original copy of **ESP Mounter Pro 1.9.1**

Original ESP Mounter Pro distribution page:

https://www.insanelymac.com/forum/files/file/566-esp-mounter-pro/

## Download

**[Download ESP Mounter Pro Tahoe Patcher 2.0](downloads/ESP-Mounter-Pro-Tahoe-Patcher-2.0-PUBLIC.zip)**

SHA-256:

```text
64a018997c571532d77debcb3c552d9ebd70b0fa46841059b3214431ffbf7f82
```

The repository contains only our compatibility patcher. ESP Mounter Pro itself is intentionally not included.

## How to use

1. Obtain your own original ESP Mounter Pro 1.9.1.
2. Put `ESP Mounter Pro.app` in `/Applications` (recommended).
3. Open **ESP Mounter Pro Tahoe Patcher.app**.
4. Enter the administrator password once when macOS asks.
5. The patcher validates the app, creates a complete backup on the Desktop, applies the one-byte compatibility fix, locally signs the modified GUI, and registers the untouched original helper from your own copy.
6. ESP Mounter Pro opens automatically when the checks complete.

If Gatekeeper blocks the patcher because it is not Developer ID signed/notarized, use **Finder -> right-click -> Open** once.

## Safety checks

The patcher is deliberately strict. It supports only the exact ESP Mounter Pro 1.9.1 build used to validate this fix.

```text
Original executable SHA-256:
d6ff190d98ce19334b5e73dd1acf84f1e3b8097e31630080ad76923383eb274c

Tahoe-patched executable SHA-256:
9d592e051d0f16639042e5ed7920f9ffa3cd8372bdc65aedbd930dda43633e9f

Original helper SHA-256:
359844bce1d9bffefb6b4b106b45c4029fee0869869352a83061cbbb7b198246
```

If the selected application does not match the expected bundle, version, instruction bytes and hashes, the patcher stops without applying the modification.

A full backup is created on the Desktop before the original executable is changed.

## What the patcher does

The source is intentionally plain shell script and can be reviewed in [`src/tahoe-patcher.sh`](src/tahoe-patcher.sh).

At a high level it:

1. verifies Tahoe 26 and x86_64;
2. verifies ESP Mounter Pro 1.9.1 and the original helper;
3. backs up the original app;
4. changes the single byte at `0xA185`;
5. removes stale extended attributes and ad-hoc signs the modified GUI with Apple's `codesign`;
6. installs/registers the **unmodified helper taken from the user's own app** as `root:wheel` with mode `0544`;
7. verifies the resulting executable hash, app signature, helper hash and `launchd` service;
8. opens ESP Mounter Pro.

## Build the patcher yourself

The repository contains the complete shell source and app bundle template. On macOS:

```bash
./build.sh
```

This produces a release ZIP under `dist/` containing only the compatibility patcher and documentation.

## Restore

Before modifying an original app the patcher saves a copy on the Desktop named similar to:

```text
ESP Mounter Pro - before Tahoe patch YYYYMMDD-HHMMSS.app
```

Quit ESP Mounter Pro and copy that backup back to `/Applications` if you want to restore the unmodified application.

## License

The code in **this compatibility patcher** is released under the MIT License; see [`LICENSE`](LICENSE).

That license applies only to this project's original patcher code. It does **not** apply to ESP Mounter Pro or any file belonging to Micky1979.

## Credits

- **Micky1979** — author of ESP Mounter Pro
- **Mirone** — original ESP Mounter Pro icon credit as listed by the author
- Tahoe compatibility investigation and patch: **Alexandru Dedu / StefanAlMare**
