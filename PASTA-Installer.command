#!/bin/bash
set -euo pipefail

URL="https://www.pastatool.com"
DEST="/Applications/PASTA.app"
CHROME_APPS="$HOME/Applications/Chrome Apps.localized"

printf '\n=== PASTA Mac Installer v2 ===\n\n'

if [[ ! -d '/Applications/Google Chrome.app' && ! -d "$HOME/Applications/Google Chrome.app" ]]; then
  echo 'Google Chrome is required. Install it before continuing.'
  exit 1
fi

if [[ -e "$DEST" || -L "$DEST" ]]; then
  echo "An app already exists at $DEST; nothing changed."
  exit 0
fi

find_pasta() {
  local app
  for app in "$CHROME_APPS"/PASTA*.app; do
    [[ -d "$app/Contents" ]] || continue
    # Only accept Chrome's registered PASTA web app, not an arbitrary similarly named app.
    local bundle_id
    bundle_id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Contents/Info.plist" 2>/dev/null || true)
    if [[ "$bundle_id" == com.google.Chrome.app.* ]]; then
      printf '%s\n' "$app"
      return 0
    fi
  done
  return 1
}

APP="$(find_pasta || true)"
if [[ -z "$APP" ]]; then
  echo 'PASTA must first be installed as a Chrome web app.'
  echo 'In Chrome, open the three-dot menu > Cast, save and share > Install page as app.'
  open -a 'Google Chrome' "$URL"
  read -r -p 'After installing the Chrome web app, press Return to continue...' _
  APP="$(find_pasta || true)"
fi

if [[ -z "$APP" ]]; then
  echo 'PASTA Chrome web app not found. No changes made.'
  exit 1
fi

NEW_APP="$CHROME_APPS/PASTA.app"
if [[ "$APP" != "$NEW_APP" ]]; then
  if [[ -e "$NEW_APP" || -L "$NEW_APP" ]]; then
    echo "Cannot rename: $NEW_APP already exists."
    exit 1
  fi
  mv "$APP" "$NEW_APP"
fi

# Preserve the Chrome app's existing bundle ID and signing metadata.
# Renaming a Chrome-generated app may be undone by Chrome updates.
if [[ -w /Applications ]]; then
  ln -s "$NEW_APP" "$DEST"
else
  sudo ln -s "$NEW_APP" "$DEST"
fi

printf '\nInstalled shortcut: %s\n' "$DEST"
open "$DEST"
echo 'Done. Chrome may still display the website-provided long title.'
