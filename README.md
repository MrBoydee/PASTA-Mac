# PASTA macOS launcher installer

A simple macOS installer for a Chrome-powered window running [PASTA](https://www.pastatool.com).

## Requirements

- macOS 11 or later
- Google Chrome installed in `/Applications` or `~/Applications`

## Install

1. Download `PASTA-Installer.command`.
2. Open Terminal, navigate to the downloaded file, and run:

   ```bash
   chmod +x PASTA-Installer.command
   ./PASTA-Installer.command
   ```

   macOS may require you to approve opening a downloaded script in Privacy & Security. Inspect the script before running it.
3. The installer creates `/Applications/PASTA.app` and opens it.

## Limitations

This creates a macOS application launcher that starts Google Chrome with `--app=https://www.pastatool.com`. It **does not** install a Chrome PWA or register a separate Chrome web-app identity. Its Dock icon and running application identity may be Chrome's, and login/session state is managed by Chrome. Chrome must remain installed.

The installer will not overwrite an existing `/Applications/PASTA.app`.

## Security

This script does not copy Chrome profiles, Plex tokens, or credentials. It uses administrator permission only when necessary to copy the launcher into `/Applications`. Review any downloaded shell script before running it.

## Uninstall

Remove `/Applications/PASTA.app`. Your Chrome browser data is not affected.

This is an unofficial launcher, not affiliated with PASTA, Plex, or Google.
