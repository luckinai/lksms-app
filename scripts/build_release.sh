#!/bin/bash

# Android Production Build Script for Linux/macOS
# Usage: ./build_release.sh [version]

# Default version
VERSION=${1:-"1.0.0"}

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Linux/macOS Build Script${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

echo -e "${GREEN}Working directory: $(pwd)${NC}"
echo -e "${GREEN}Version: $VERSION${NC}"
echo ""

# Check Flutter
echo -e "${YELLOW}Step 1: Checking Flutter...${NC}"
flutter --version
echo ""

# Check required files
echo -e "${YELLOW}Step 2: Checking required files...${NC}"
if [ -f "pubspec.yaml" ]; then
    echo -e "${GREEN}[OK] pubspec.yaml found${NC}"
else
    echo -e "${RED}[WARNING] pubspec.yaml not found${NC}"
fi

if [ -f "android/key.properties" ]; then
    echo -e "${GREEN}[OK] android/key.properties found${NC}"
else
    echo -e "${RED}[WARNING] android/key.properties not found${NC}"
fi

if [ -f "android/app/lksms-release-key.jks" ]; then
    echo -e "${GREEN}[OK] keystore file found${NC}"
else
    echo -e "${RED}[WARNING] keystore file not found${NC}"
fi
echo ""

# Clean project (commented out for faster builds)
# echo -e "${YELLOW}Step 3: Cleaning project...${NC}"
# flutter clean
# echo -e "${GREEN}Clean completed.${NC}"
# echo ""

# Get dependencies (commented out for faster builds)
# echo -e "${YELLOW}Step 4: Getting dependencies...${NC}"
# flutter pub get
# echo -e "${GREEN}Dependencies completed.${NC}"
# echo ""

# Build APK
echo -e "${YELLOW}Step 3: Building APK...${NC}"
echo -e "${CYAN}This may take several minutes, please wait...${NC}"
flutter build apk --release --build-name="$VERSION"
echo -e "${GREEN}Build completed.${NC}"
echo ""

# Check result
echo -e "${YELLOW}Step 4: Checking build result...${NC}"
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [ -f "$APK_PATH" ]; then
    echo -e "${GREEN}[SUCCESS] APK created successfully!${NC}"
    echo -e "${GREEN}Location: $APK_PATH${NC}"
    
    # Get file size
    FILE_SIZE=$(stat -c%s "$APK_PATH" 2>/dev/null || stat -f%z "$APK_PATH" 2>/dev/null)
    FILE_SIZE_MB=$(echo "scale=2; $FILE_SIZE / 1024 / 1024" | bc)
    echo -e "${GREEN}Size: $FILE_SIZE bytes ($FILE_SIZE_MB MB)${NC}"
    
    # Copy to root directory
    cp "$APK_PATH" "lksms-release.apk"
    echo -e "${GREEN}Copied to: lksms-release.apk${NC}"
    
    # Create release directory and copy with version name
    RELEASE_DIR="build/release"
    if [ ! -d "$RELEASE_DIR" ]; then
        mkdir -p "$RELEASE_DIR"
    fi
    
    VERSIONED_APK="$RELEASE_DIR/lksms-v$VERSION-release.apk"
    cp "$APK_PATH" "$VERSIONED_APK"
    echo -e "${GREEN}Versioned copy: $VERSIONED_APK${NC}"
    
else
    echo -e "${RED}[ERROR] APK not found!${NC}"
    echo -e "${RED}Expected location: $APK_PATH${NC}"
fi
echo ""

# Check for AAB (App Bundle)
AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
if [ -f "$AAB_PATH" ]; then
    echo -e "${GREEN}[INFO] AAB also found: $AAB_PATH${NC}"
    VERSIONED_AAB="$RELEASE_DIR/lksms-v$VERSION-release.aab"
    cp "$AAB_PATH" "$VERSIONED_AAB"
    echo -e "${GREEN}Versioned AAB copy: $VERSIONED_AAB${NC}"
fi
echo ""

# Create build info
echo -e "${YELLOW}Creating build information...${NC}"
BUILD_INFO="$RELEASE_DIR/build-info-v$VERSION.txt"
cat > "$BUILD_INFO" << EOF
LKSMS Build Information
=======================
Version: $VERSION
Build date: $(date)
Build time: $(date +%T)

Flutter version:
$(flutter --version)

Build artifacts:
$([ -f "$RELEASE_DIR/lksms-v$VERSION-release.apk" ] && echo "- lksms-v$VERSION-release.apk")
$([ -f "$RELEASE_DIR/lksms-v$VERSION-release.aab" ] && echo "- lksms-v$VERSION-release.aab")

APK signature info:
$(keytool -printcert -jarfile "$VERSIONED_APK" 2>/dev/null || echo "Could not read signature info")
EOF

echo -e "${GREEN}Build info saved to: $BUILD_INFO${NC}"
echo ""

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Build Summary${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}Version: $VERSION${NC}"
if [ -f "lksms-release.apk" ]; then
    echo -e "${GREEN}Status: SUCCESS - APK ready for testing${NC}"
    echo -e "${GREEN}Quick access: lksms-release.apk${NC}"
else
    echo -e "${RED}Status: FAILED - APK not created${NC}"
fi
echo ""

echo -e "${CYAN}Next steps:${NC}"
echo -e "${WHITE}1. Test the APK on your Android device${NC}"
echo -e "${WHITE}2. For Google Play Store, also build AAB: flutter build appbundle --release${NC}"
echo -e "${WHITE}3. Check the release directory: $RELEASE_DIR${NC}"
echo ""

# Optional: Open release directory (Linux with GUI)
if command -v xdg-open &> /dev/null && [ -n "$DISPLAY" ]; then
    read -p "Open release directory? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        xdg-open "$RELEASE_DIR"
    fi
elif command -v open &> /dev/null; then
    # macOS
    read -p "Open release directory? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open "$RELEASE_DIR"
    fi
fi

echo -e "${GREEN}Build script completed.${NC}"
