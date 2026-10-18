#!/bin/bash
set -euo pipefail

APP_NAME="PASTA"
APP_PATH="/Applications/${APP_NAME}.app"
URL="https://www.pastatool.com"

printf '\n=== PASTA for macOS Installer ===\n\n'

CHROME=""
for candidate in "/Applications/Google Chrome.app" "$HOME/Applications/Google Chrome.app"; do
  if [[ -d "$candidate" ]]; then
    CHROME="$candidate"
    break
  fi
done

if [[ -z "$CHROME" ]]; then
  echo "Google Chrome is required. Install Chrome, then run this installer again."
  echo "https://www.google.com/chrome/"
  read -r -p "Press Return to close..." _
  exit 1
fi

# Do not overwrite an existing app, symlink, or user data.
if [[ -e "$APP_PATH" || -L "$APP_PATH" ]]; then
  echo "An application already exists at $APP_PATH"
  echo "Nothing was overwritten. Remove or rename it yourself before reinstalling."
  read -r -p "Press Return to close..." _
  exit 1
fi

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT
STAGING="$TEMP_DIR/$APP_NAME.app"
mkdir -p "$STAGING/Contents/MacOS" "$STAGING/Contents/Resources"

cat > "$STAGING/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>PASTA</string>
<key>CFBundleIdentifier</key><string>local.pasta.chrome.launcher</string>
<key>CFBundleName</key><string>PASTA</string>
<key>CFBundleDisplayName</key><string>PASTA</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleVersion</key><string>1</string>
<key>CFBundleShortVersionString</key><string>1.0</string>
<key>LSMinimumSystemVersion</key><string>11.0</string>
</dict></plist>
PLIST

cat > "$STAGING/Contents/MacOS/PASTA" <<'LAUNCHER'
#!/bin/bash
set -euo pipefail
CHROME=""
for candidate in "/Applications/Google Chrome.app" "$HOME/Applications/Google Chrome.app"; do
  if [[ -d "$candidate" ]]; then CHROME="$candidate"; break; fi
done
if [[ -z "$CHROME" ]]; then
  osascript -e 'display alert "Google Chrome required" message "Install Google Chrome to use PASTA."'
  exit 1
fi
exec "$CHROME/Contents/MacOS/Google Chrome" --app="https://www.pastatool.com"
LAUNCHER
chmod 755 "$STAGING/Contents/MacOS/PASTA"

# Install without requiring admin credentials if Applications is writable.
if [[ -w /Applications ]]; then
  ditto "$STAGING" "$APP_PATH"
else
  echo "macOS may ask for administrator permission to install in /Applications."
  /usr/bin/osascript - "$STAGING" "$APP_PATH" <<'OSA'
on run argv
    set src to item 1 of argv
    set dst to item 2 of argv
    do shell script "/usr/bin/ditto " & quoted form of src & " " & quoted form of dst with administrator privileges
end run
OSA
fi

printf '\nInstalled: %s\n' "$APP_PATH"
echo "This is a Chrome-powered launcher, not a separately installed Chrome PWA."
echo "Chrome may show its own Dock identity while PASTA is running."
echo "Opening PASTA..."
open "$APP_PATH"
printf '\nDone.\n'
read -r -p "Press Return to close..." _
