# Flutter Installation Guide for M1 Mac
## Complete Setup Instructions

### Prerequisites Check
Before we start, verify you have:
- macOS 11 (Big Sur) or later
- At least 2.8 GB of disk space
- Git installed

---

## PART 1: Install Flutter SDK

### Step 1: Download Flutter for Apple Silicon
Open your **Mac Terminal** and run these commands:

```bash
# Navigate to your home directory
cd ~

# Download Flutter (stable channel, Apple Silicon)
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.27.1-stable.zip

# Unzip Flutter
unzip flutter_macos_arm64_3.27.1-stable.zip

# Move to a permanent location (optional but recommended)
sudo mv flutter /opt/flutter

# Clean up the zip file
rm flutter_macos_arm64_3.27.1-stable.zip
```

### Step 2: Add Flutter to PATH

```bash
# Open your shell configuration file
# If using zsh (default on macOS): ~/.zshrc
# If using bash: ~/.bash_profile

nano ~/.zshrc
```

Add this line at the end of the file:
```bash
export PATH="$PATH:/opt/flutter/bin"
```

Save and exit (Ctrl+X, then Y, then Enter)

Then reload your shell:
```bash
source ~/.zshrc
```

### Step 3: Verify Flutter Installation

```bash
flutter --version
```

You should see something like:
```
Flutter 3.27.1 • channel stable
Framework • revision abc123...
Engine • revision xyz789...
Tools • Dart 3.6.0
```

---

## PART 2: Install Required Dependencies

### Step 4: Install Xcode Command Line Tools (for iOS development)

```bash
# Install Xcode Command Line Tools
xcode-select --install
```

A popup will appear - click "Install" and wait for it to complete.

### Step 5: Install CocoaPods (for iOS dependencies)

```bash
# Install CocoaPods using Ruby gems
sudo gem install cocoapods
```

### Step 6: Install Chrome (for Web development)

If you don't have Chrome installed:
```bash
# Using Homebrew (if you have it)
brew install --cask google-chrome

# Or download from: https://www.google.com/chrome/
```

---

## PART 3: Run Flutter Doctor

### Step 7: Check Flutter Setup

```bash
flutter doctor -v
```

This will check your environment and show what's missing. You should see:

```
[✓] Flutter (Channel stable, 3.27.1, on macOS 14.x)
[✓] Chrome - develop for the web
[!] Xcode - develop for iOS and macOS
    ✗ Xcode installation is incomplete
[!] Android toolchain - develop for Android devices
    ✗ Unable to locate Android SDK
```

**Don't worry about Android SDK for now** - we'll handle that later if needed.

### Step 8: Accept Xcode License (if prompted)

```bash
sudo xcodebuild -license accept
```

### Step 9: Install iOS Simulator (Optional but recommended)

```bash
# Open Xcode (if installed, otherwise install from App Store)
open -a Simulator
```

---

## PART 4: Install VSCode Extensions

### Step 10: Install Flutter & Dart Extensions in VSCode

1. Open VSCode
2. Press `Cmd+Shift+X` to open Extensions
3. Search for and install these extensions:
   - **Flutter** (by Dart Code)
   - **Dart** (by Dart Code)

Or run this in your terminal:
```bash
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code
```

### Step 11: Verify VSCode Flutter Setup

1. In VSCode, press `Cmd+Shift+P`
2. Type "Flutter: Run Flutter Doctor"
3. Check the output

---

## PART 5: Final Verification

### Step 12: Test Flutter Setup

```bash
# Run Flutter doctor again
flutter doctor

# Expected output should show:
# [✓] Flutter
# [✓] Chrome
# [✓] Xcode (or [!] with minor warnings)
# [✓] VS Code
```

### Common Warnings You Can Ignore (For Now):
- ⚠️ Android Studio not installed (we're using VSCode)
- ⚠️ Android SDK not found (we'll add this later if you want Android development)
- ⚠️ Some Xcode tools (unless you want iOS Simulator immediately)

---

## NEXT STEP

Once you see `[✓] Flutter` when running `flutter doctor`, you're ready!

Come back here and I'll create your Flutter project!

---

## Troubleshooting

**Problem: "flutter: command not found"**
```bash
# Check if Flutter is in the right location
ls /opt/flutter/bin/flutter

# If yes, PATH wasn't updated. Reload your shell:
source ~/.zshrc
```

**Problem: "Certificate verify failed" when downloading**
```bash
# Add this before the curl command:
export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
```

**Problem: Permission denied**
```bash
# If you can't write to /opt, use your home directory instead:
mv flutter ~/flutter
# Then update PATH to: export PATH="$PATH:$HOME/flutter/bin"
```

---

## Quick Reference

**Check Flutter version:**
```bash
flutter --version
```

**Update Flutter:**
```bash
flutter upgrade
```

**Check what's missing:**
```bash
flutter doctor
```

**List all devices:**
```bash
flutter devices
```
