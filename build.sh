#!/bin/bash

# 🛠️ Claude Code Now & Codex Now - Build & Package Script
# Usage: ./build.sh [version]
# Example: ./build.sh 1.7.0 or ./build.sh 1.0.0-beta

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$SCRIPT_DIR/dist"

# App configurations
CLAUDE_APP_NAME="Claude Code Now"
CLAUDE_APP_DIR="$SCRIPT_DIR/$CLAUDE_APP_NAME.app"
CLAUDE_INFO_PLIST="$CLAUDE_APP_DIR/Contents/Info.plist"
CLAUDE_LAUNCHER="$CLAUDE_APP_DIR/Contents/MacOS/ClaudeCodeLauncher"

CODEX_APP_NAME="Codex Now"
CODEX_APP_DIR="$SCRIPT_DIR/$CODEX_APP_NAME.app"
CODEX_INFO_PLIST="$CODEX_APP_DIR/Contents/Info.plist"
CODEX_LAUNCHER="$CODEX_APP_DIR/Contents/MacOS/CodexLauncher"

echo -e "${BLUE}🖥 Claude Code Now & Codex Now - Build Script${NC}"
echo "=============================================="

# Get version from argument or Info.plist
if [ -n "$1" ]; then
    VERSION="$1"
    echo -e "${YELLOW}📦 Using provided version: $VERSION${NC}"
else
    # Extract current version from Claude Code Now Info.plist
    VERSION=$(grep -A1 "CFBundleShortVersionString" "$CLAUDE_INFO_PLIST" | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+")
    echo -e "${YELLOW}📦 Using version from Info.plist: $VERSION${NC}"
fi

# Validate version format (supports: 1.0.0, 1.0.0-beta, 1.0.0-rc.1, etc.)
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9._-]+)?$ ]]; then
    echo -e "${RED}❌ Error: Invalid version format '$VERSION'${NC}"
    echo -e "${YELLOW}   Expected formats: X.X.X, X.X.X-beta, X.X.X-rc.1, etc.${NC}"
    exit 1
fi

# Output file names
CLAUDE_ZIP_FILE="Claude.Code.Now.v${VERSION}.macOS.zip"
CLAUDE_SHA_FILE="Claude.Code.Now.v${VERSION}.macOS.zip.sha256"
CODEX_ZIP_FILE="Codex.Now.v${VERSION}.macOS.zip"
CODEX_SHA_FILE="Codex.Now.v${VERSION}.macOS.zip.sha256"

echo ""
echo -e "${BLUE}📋 Build Configuration:${NC}"
echo "   Version:     $VERSION"
echo "   Output Dir:  dist/"
echo "   Apps:        Claude Code Now, Codex Now"
echo ""

# Create dist directory
mkdir -p "$DIST_DIR"

# Function to build an app
build_app() {
    local APP_NAME="$1"
    local APP_DIR="$2"
    local INFO_PLIST="$3"
    local LAUNCHER="$4"
    local ZIP_FILE="$5"
    local SHA_FILE="$6"
    local COLOR="$7"
    
    echo -e "${COLOR}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${COLOR}🔨 Building: $APP_NAME${NC}"
    echo -e "${COLOR}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Step 1: Verify app structure
    echo -e "${BLUE}[1/4] Verifying app structure...${NC}"
    if [ ! -d "$APP_DIR" ]; then
        echo -e "${RED}   ❌ Error: App directory not found: $APP_DIR${NC}"
        return 1
    fi
    
    if [ ! -f "$INFO_PLIST" ]; then
        echo -e "${RED}   ❌ Error: Info.plist not found: $INFO_PLIST${NC}"
        return 1
    fi
    
    if [ ! -f "$LAUNCHER" ]; then
        echo -e "${RED}   ❌ Error: Launcher script not found: $LAUNCHER${NC}"
        return 1
    fi
    echo -e "${GREEN}   ✅ App structure verified${NC}"
    
    # Step 2: Ensure launcher is executable
    echo -e "${BLUE}[2/4] Setting executable permissions...${NC}"
    chmod +x "$LAUNCHER"
    echo -e "${GREEN}   ✅ Launcher permissions set${NC}"
    
    # Step 3: Create zip package
    echo -e "${BLUE}[3/4] Creating zip package...${NC}"
    cd "$SCRIPT_DIR"
    
    # Remove old files in dist if exist
    rm -f "$DIST_DIR/$ZIP_FILE" "$DIST_DIR/$SHA_FILE" 2>/dev/null || true
    
    zip -r "$DIST_DIR/$ZIP_FILE" "$APP_NAME.app" -q
    FILE_SIZE=$(du -h "$DIST_DIR/$ZIP_FILE" | cut -f1)
    echo -e "${GREEN}   ✅ Created: dist/$ZIP_FILE ($FILE_SIZE)${NC}"
    
    # Step 4: Generate SHA256 checksum
    echo -e "${BLUE}[4/4] Generating SHA256 checksum...${NC}"
    cd "$DIST_DIR"
    shasum -a 256 "$ZIP_FILE" > "$SHA_FILE"
    SHA256=$(cat "$SHA_FILE" | cut -d' ' -f1)
    echo -e "${GREEN}   ✅ SHA256: $SHA256${NC}"
    cd "$SCRIPT_DIR"
    
    echo ""
}

# Build Claude Code Now
build_app "$CLAUDE_APP_NAME" "$CLAUDE_APP_DIR" "$CLAUDE_INFO_PLIST" "$CLAUDE_LAUNCHER" "$CLAUDE_ZIP_FILE" "$CLAUDE_SHA_FILE" "$BLUE"

# Build Codex Now
build_app "$CODEX_APP_NAME" "$CODEX_APP_DIR" "$CODEX_INFO_PLIST" "$CODEX_LAUNCHER" "$CODEX_ZIP_FILE" "$CODEX_SHA_FILE" "$CYAN"

echo "=============================================="
echo -e "${GREEN}🎉 Build Complete!${NC}"
echo ""
echo -e "${BLUE}📦 Output Files (in dist/):${NC}"
echo "   Claude Code Now:"
echo "   • dist/$CLAUDE_ZIP_FILE"
echo "   • dist/$CLAUDE_SHA_FILE"
echo ""
echo "   Codex Now:"
echo "   • dist/$CODEX_ZIP_FILE"
echo "   • dist/$CODEX_SHA_FILE"
echo ""
echo -e "${BLUE}📋 发布步骤:${NC}"
echo "   1. 提交更改: git add . && git commit -m \"Release v$VERSION\""
echo "   2. 创建标签: git tag v$VERSION"
echo "   3. 推送: git push origin main && git push origin v$VERSION"
echo ""
echo -e "${YELLOW}   或使用 gh CLI:${NC}"
echo ""
echo -e "${CYAN}   gh release create v$VERSION \\
     --title \"v$VERSION\" \\
     --notes \"Release notes here...\" \\
     \"dist/$CLAUDE_ZIP_FILE\" \\
     \"dist/$CLAUDE_SHA_FILE\" \\
     \"dist/$CODEX_ZIP_FILE\" \\
     \"dist/$CODEX_SHA_FILE\"${NC}"
echo ""
