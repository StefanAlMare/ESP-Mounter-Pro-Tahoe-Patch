#!/bin/bash
set -u

TITLE="ESP Mounter Pro Tahoe Patcher 2.0"
OFFSET=41349
SEQ_OFFSET=41347
ORIGINAL_EXE_SHA="d6ff190d98ce19334b5e73dd1acf84f1e3b8097e31630080ad76923383eb274c"
PATCHED_EXE_SHA="9d592e051d0f16639042e5ed7920f9ffa3cd8372bdc65aedbd930dda43633e9f"
ORIGINAL_HELPER_SHA="359844bce1d9bffefb6b4b106b45c4029fee0869869352a83061cbbb7b198246"
LABEL="com.Micky1979.EspMounterProHelper"
HELPER_DST="/Library/PrivilegedHelperTools/com.Micky1979.EspMounterProHelper"
PLIST_DST="/Library/LaunchDaemons/com.Micky1979.EspMounterProHelper.plist"
LOG="$HOME/Desktop/ESP-Mounter-Pro-Tahoe-Patcher.log"
TMPROOT="/private/tmp/esp-mounter-pro-tahoe-patcher.$$"

show_dialog() {
  local message="$1"
  local icon="$2"
  /usr/bin/osascript - "$message" "$icon" <<'APPLESCRIPT' >/dev/null 2>&1 || true
on run argv
  set msg to item 1 of argv
  set ico to item 2 of argv
  if ico is "stop" then
    display dialog msg with title "ESP Mounter Pro Tahoe Patcher 2.0" buttons {"OK"} default button "OK" with icon stop
  else if ico is "caution" then
    display dialog msg with title "ESP Mounter Pro Tahoe Patcher 2.0" buttons {"OK"} default button "OK" with icon caution
  else
    display dialog msg with title "ESP Mounter Pro Tahoe Patcher 2.0" buttons {"OK"} default button "OK" with icon note
  end if
end run
APPLESCRIPT
}

fail() {
  echo "ERROR: $1"
  show_dialog "$1\n\nDiagnostic log: ~/Desktop/ESP-Mounter-Pro-Tahoe-Patcher.log" stop
  /bin/rm -rf "$TMPROOT" >/dev/null 2>&1 || true
  exit 1
}

: > "$LOG"
exec > >(tee -a "$LOG") 2>&1

echo "$TITLE"
echo "================================================"

PRODUCT_VERSION=$(/usr/bin/sw_vers -productVersion 2>/dev/null || echo "")
MAJOR=$(printf '%s' "$PRODUCT_VERSION" | /usr/bin/awk -F. '{print $1}')
ARCH=$(/usr/bin/uname -m 2>/dev/null || echo "unknown")
echo "macOS: $PRODUCT_VERSION"
echo "Architecture: $ARCH"

[ "$MAJOR" = "26" ] || fail "This patcher is intended only for macOS Tahoe 26. Nothing was changed."
[ "$ARCH" = "x86_64" ] || fail "This patcher is intended for Intel/Hackintosh systems (x86_64). Nothing was changed."

APP="/Applications/ESP Mounter Pro.app"
if [ ! -d "$APP" ]; then
  APP=$(/usr/bin/osascript <<'APPLESCRIPT'
try
  set f to choose file with prompt "Select your original ESP Mounter Pro.app" of type {"com.apple.application-bundle"}
  return POSIX path of f
on error number -128
  return ""
end try
APPLESCRIPT
)
  APP="${APP%/}"
fi

[ -n "$APP" ] || exit 0
[ -d "$APP" ] || fail "ESP Mounter Pro.app was not found."

BIN="$APP/Contents/MacOS/ESP Mounter Pro"
INFO="$APP/Contents/Info.plist"
EMBEDDED_HELPER="$APP/Contents/Library/LaunchServices/com.Micky1979.EspMounterProHelper"

[ -f "$BIN" ] || fail "The selected app does not contain the expected ESP Mounter Pro executable."
[ -f "$INFO" ] || fail "The selected app does not contain the expected Info.plist."
[ -f "$EMBEDDED_HELPER" ] || fail "The selected app does not contain the original privileged helper."

BUNDLE_ID=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$INFO" 2>/dev/null || true)
SHORT_VER=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$INFO" 2>/dev/null || true)
echo "Bundle ID: $BUNDLE_ID"
echo "App version: $SHORT_VER"
[ "$BUNDLE_ID" = "com.Micky1979.ESP-Mounter-Pro" ] || fail "This is not the expected ESP Mounter Pro application."
[ "$SHORT_VER" = "1.9.1" ] || fail "This patcher was validated for ESP Mounter Pro 1.9.1 only. Nothing was changed."

HELPER_SHA=$(/usr/bin/shasum -a 256 "$EMBEDDED_HELPER" | /usr/bin/awk '{print $1}')
echo "Embedded helper SHA-256: $HELPER_SHA"
[ "$HELPER_SHA" = "$ORIGINAL_HELPER_SHA" ] || fail "The embedded helper differs from the original ESP Mounter Pro 1.9.1 helper used to validate this patch. Nothing was changed."

SEQ=$(/usr/bin/od -An -tx1 -j "$SEQ_OFFSET" -N 6 "$BIN" 2>/dev/null | /usr/bin/tr -d ' \n')
EXE_SHA=$(/usr/bin/shasum -a 256 "$BIN" | /usr/bin/awk '{print $1}')
echo "Executable SHA-256: $EXE_SHA"
echo "Patch instruction: $SEQ"

PATCH_NEEDED=1
if [ "$SEQ" = "41b801000000" ] && [ "$EXE_SHA" = "$ORIGINAL_EXE_SHA" ]; then
  echo "Original executable verified."
  PATCH_NEEDED=1
elif [ "$SEQ" = "41b800000000" ] && [ "$EXE_SHA" = "$PATCHED_EXE_SHA" ]; then
  echo "Executable is already Tahoe-patched. Helper registration will still be verified/repaired."
  PATCH_NEEDED=0
else
  fail "The executable is neither the exact original 1.9.1 build nor the exact supported Tahoe-patched build. Nothing was changed."
fi

/usr/bin/killall "ESP Mounter Pro" >/dev/null 2>&1 || true

STAMP=$(/bin/date +%Y%m%d-%H%M%S)
BACKUP="$HOME/Desktop/ESP Mounter Pro - before Tahoe patch $STAMP.app"
if [ "$PATCH_NEEDED" = "1" ]; then
  echo "Creating backup: $BACKUP"
  /usr/bin/ditto "$APP" "$BACKUP" || fail "Could not create a complete backup on the Desktop. Nothing was changed."
  HELPER_SOURCE="$BACKUP/Contents/Library/LaunchServices/com.Micky1979.EspMounterProHelper"
else
  HELPER_SOURCE="$EMBEDDED_HELPER"
fi

/bin/mkdir -p "$TMPROOT" || fail "Could not create the temporary work directory."
TMPPLIST="$TMPROOT/$LABEL.plist"
ROOTSCRIPT="$TMPROOT/install-helper.sh"

cat > "$TMPPLIST" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.Micky1979.EspMounterProHelper</string>
    <key>Program</key>
    <string>/Library/PrivilegedHelperTools/com.Micky1979.EspMounterProHelper</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Library/PrivilegedHelperTools/com.Micky1979.EspMounterProHelper</string>
    </array>
    <key>MachServices</key>
    <dict>
        <key>com.Micky1979.EspMounterProHelper.mach</key>
        <true/>
    </dict>
</dict>
</plist>
PLIST

cat > "$ROOTSCRIPT" <<'ROOT'
#!/bin/bash
set -e
APP="$1"
BIN="$2"
HELPER_SOURCE="$3"
TMPPLIST="$4"
PATCH_NEEDED="$5"
OFFSET="$6"
LABEL="com.Micky1979.EspMounterProHelper"
HELPER_DST="/Library/PrivilegedHelperTools/com.Micky1979.EspMounterProHelper"
PLIST_DST="/Library/LaunchDaemons/com.Micky1979.EspMounterProHelper.plist"

if [ "$PATCH_NEEDED" = "1" ]; then
  printf '\000' | /bin/dd of="$BIN" bs=1 seek="$OFFSET" count=1 conv=notrunc >/dev/null 2>&1
fi

/usr/bin/xattr -cr "$APP" 2>/dev/null || true
/bin/chmod 755 "$BIN"
/bin/rm -rf "$APP/Contents/_CodeSignature"
/usr/bin/codesign --force --sign - --timestamp=none "$APP"

/bin/launchctl bootout system/"$LABEL" >/dev/null 2>&1 || true
/bin/launchctl bootout system "$PLIST_DST" >/dev/null 2>&1 || true
/bin/mkdir -p /Library/PrivilegedHelperTools /Library/LaunchDaemons
/bin/rm -f "$HELPER_DST" "$PLIST_DST"
/usr/bin/ditto "$HELPER_SOURCE" "$HELPER_DST"
/bin/cp "$TMPPLIST" "$PLIST_DST"
/usr/sbin/chown root:wheel "$HELPER_DST" "$PLIST_DST"
/bin/chmod 0544 "$HELPER_DST"
/bin/chmod 0644 "$PLIST_DST"
/usr/bin/xattr -cr "$HELPER_DST" "$PLIST_DST" 2>/dev/null || true
/bin/launchctl bootstrap system "$PLIST_DST"
/bin/launchctl enable system/"$LABEL" >/dev/null 2>&1 || true
/bin/launchctl kickstart -k system/"$LABEL" >/dev/null 2>&1 || true
ROOT
/bin/chmod 700 "$ROOTSCRIPT"

echo
echo "Administrator authorization is required once to patch/sign the app and install/register the original helper from your own copy."
AUTH_OUT=$(/usr/bin/osascript - "$ROOTSCRIPT" "$APP" "$BIN" "$HELPER_SOURCE" "$TMPPLIST" "$PATCH_NEEDED" "$OFFSET" <<'APPLESCRIPT' 2>&1
on run argv
  set rootScript to item 1 of argv
  set appPath to item 2 of argv
  set binPath to item 3 of argv
  set helperSource to item 4 of argv
  set tmpPlist to item 5 of argv
  set patchNeeded to item 6 of argv
  set patchOffset to item 7 of argv
  set cmd to quoted form of rootScript & " " & quoted form of appPath & " " & quoted form of binPath & " " & quoted form of helperSource & " " & quoted form of tmpPlist & " " & quoted form of patchNeeded & " " & quoted form of patchOffset
  do shell script cmd with administrator privileges
end run
APPLESCRIPT
)
AUTH_RC=$?
echo "$AUTH_OUT"
[ $AUTH_RC -eq 0 ] || fail "Administrator authorization was cancelled or the patch/helper installation failed."

/bin/rm -rf "$TMPROOT" >/dev/null 2>&1 || true

NEW_SEQ=$(/usr/bin/od -An -tx1 -j "$SEQ_OFFSET" -N 6 "$BIN" 2>/dev/null | /usr/bin/tr -d ' \n')
NEW_SHA=$(/usr/bin/shasum -a 256 "$BIN" | /usr/bin/awk '{print $1}')
echo "Patched instruction: $NEW_SEQ"
echo "Patched executable SHA-256: $NEW_SHA"
[ "$NEW_SEQ" = "41b800000000" ] || fail "Post-patch instruction verification failed."
[ "$NEW_SHA" = "$PATCHED_EXE_SHA" ] || fail "Post-patch executable hash verification failed."

/usr/bin/codesign --verify --verbose=2 "$APP" || fail "The locally signed ESP Mounter Pro app did not pass codesign verification."
[ -f "$HELPER_DST" ] || fail "The privileged helper was not installed."
[ -f "$PLIST_DST" ] || fail "The LaunchDaemon plist was not installed."

INSTALLED_HELPER_SHA=$(/usr/bin/shasum -a 256 "$HELPER_DST" | /usr/bin/awk '{print $1}')
HELPER_OWNER=$(/usr/bin/stat -f '%Su:%Sg' "$HELPER_DST" 2>/dev/null || echo unknown)
HELPER_MODE=$(/usr/bin/stat -f '%Lp' "$HELPER_DST" 2>/dev/null || echo unknown)
echo "Installed helper SHA-256: $INSTALLED_HELPER_SHA"
echo "Installed helper owner/mode: $HELPER_OWNER / $HELPER_MODE"
[ "$INSTALLED_HELPER_SHA" = "$ORIGINAL_HELPER_SHA" ] || fail "Installed helper hash verification failed."
[ "$HELPER_OWNER" = "root:wheel" ] || fail "Installed helper ownership is incorrect."
[ "$HELPER_MODE" = "544" ] || fail "Installed helper permissions are incorrect."
/bin/launchctl print system/"$LABEL" >/dev/null 2>&1 || fail "launchd did not register the helper service."

if [ "$PATCH_NEEDED" = "1" ]; then
  MSG="Done. ESP Mounter Pro 1.9.1 is patched for macOS Tahoe 26.\n\nA complete original backup was saved on your Desktop.\n\nThe patcher changed one byte in the GUI executable and re-registered the untouched original helper from your own ESP Mounter Pro copy. Normal EFI Mount/Unmount operations should no longer require the administrator password."
else
  MSG="Done. This copy was already Tahoe-patched. The untouched original helper from your own ESP Mounter Pro bundle has been verified and re-registered."
fi
show_dialog "$MSG" note
/usr/bin/open "$APP"
exit 0
