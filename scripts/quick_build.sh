#!/bin/bash

# Quick build script (APK only, for testing)
# Usage: ./quick_build.sh

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Quick Build Script (Testing)${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

echo -e "${GREEN}Working directory: $(pwd)${NC}"
echo ""

# Check Flutter environment
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Error: Flutter not found. Please install Flutter and configure PATH.${NC}"
    exit 1
fi

echo -e "${YELLOW}[1/3] Cleaning project...${NC}"
flutter clean

echo -e "${YELLOW}[2/3] Getting dependencies...${NC}"
flutter pub get

echo -e "${YELLOW}[3/3] Building APK...${NC}"
flutter build apk --release

if [ $? -ne 0 ]; then
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Build completed!${NC}"
echo -e "${GREEN}APK location: build/app/outputs/flutter-apk/app-release.apk${NC}"

# Copy to root directory for easy access
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    cp "build/app/outputs/flutter-apk/app-release.apk" "lksms-debug.apk"
    echo -e "${GREEN}Copied to: lksms-debug.apk${NC}"
else
    echo -e "${RED}Error: APK file not found${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}Quick build completed successfully!${NC}"
