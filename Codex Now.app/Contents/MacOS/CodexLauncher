#!/bin/bash

# 🖥 Codex Now - Launch OpenAI Codex CLI instantly without confirmation
# Get the path parameter if provided
TARGET_DIR="$1"

# Set complete PATH including common Node.js and CLI tool paths
# First, try to source common shell configurations to get the proper PATH
if [ -f "$HOME/.zshrc" ]; then
    source "$HOME/.zshrc" 2>/dev/null || true
elif [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc" 2>/dev/null || true
elif [ -f "$HOME/.bash_profile" ]; then
    source "$HOME/.bash_profile" 2>/dev/null || true
fi

# Detect and add nvm Node.js path dynamically
NVM_NODE_PATH=""
if [ -d "$HOME/.nvm" ]; then
    # Try to load nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 2>/dev/null || true
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" 2>/dev/null || true

    # Try to get current/default Node.js version
    if command -v nvm >/dev/null 2>&1; then
        # Get current node version or default version
        CURRENT_NODE_VERSION=$(nvm current 2>/dev/null | grep -v 'none' | head -1 || nvm alias default 2>/dev/null | grep -v 'default -> N/A' | head -1 || "")
        if [ -n "$CURRENT_NODE_VERSION" ] && [ "$CURRENT_NODE_VERSION" != "none" ] && [ "$CURRENT_NODE_VERSION" != "system" ]; then
            NVM_NODE_PATH="$HOME/.nvm/versions/node/$CURRENT_NODE_VERSION/bin"
        else
            # Fallback: find the latest installed version
            LATEST_NODE_VERSION=$(ls "$HOME/.nvm/versions/node/" 2>/dev/null | sort -V | tail -1 || echo "")
            if [ -n "$LATEST_NODE_VERSION" ]; then
                NVM_NODE_PATH="$HOME/.nvm/versions/node/$LATEST_NODE_VERSION/bin"
            fi
        fi
    else
        # Fallback: find the latest installed version without nvm command
        LATEST_NODE_VERSION=$(ls "$HOME/.nvm/versions/node/" 2>/dev/null | sort -V | tail -1 || echo "")
        if [ -n "$LATEST_NODE_VERSION" ]; then
            NVM_NODE_PATH="$HOME/.nvm/versions/node/$LATEST_NODE_VERSION/bin"
        fi
    fi
fi

# Add common paths that might not be in the shell config
if [ -n "$NVM_NODE_PATH" ]; then
    export PATH="$NVM_NODE_PATH:$HOME/.npm-global/bin:$HOME/.npm/bin:$HOME/Library/pnpm:$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin:/opt/homebrew/bin:/usr/local/share/npm/bin:$PATH"
else
    export PATH="$HOME/.npm-global/bin:$HOME/.npm/bin:$HOME/Library/pnpm:$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin:/opt/homebrew/bin:/usr/local/share/npm/bin:$PATH"
fi

# Configuration files
LAST_DIR_FILE="$HOME/.codex-now-last-dir"
TERMINAL_CONFIG_FILE="$HOME/.codex-now-terminal"

# If no parameter provided, try to get current Finder path
if [ -z "$TARGET_DIR" ]; then
    # Use AppleScript to get current Finder path
    TARGET_DIR=$(osascript -e '
        tell application "Finder"
            try
                set currentPath to POSIX path of (target of front window as alias)
            on error
                set currentPath to ""
            end try
        end tell
    ')
fi

# If still no Finder path, try to use last saved directory
if [ -z "$TARGET_DIR" ] && [ -f "$LAST_DIR_FILE" ]; then
    TARGET_DIR=$(cat "$LAST_DIR_FILE")
fi

# If still no path, use user home directory
if [ -z "$TARGET_DIR" ]; then
    TARGET_DIR="$HOME"
fi

# Check if directory exists
if [ ! -d "$TARGET_DIR" ]; then
    osascript -e "display alert \"Error\" message \"Directory '$TARGET_DIR' does not exist\""
    exit 1
fi

# Check if Codex CLI is installed
# Enhanced path detection with multiple fallback strategies
CODEX_PATH=""

# Function to check if a path contains codex and is executable
check_codex_path() {
    if [ -f "$1" ] && [ -x "$1" ]; then
        CODEX_PATH="$1"
        return 0
    fi
    return 1
}

# Function to find all node versions in nvm
find_nvm_codex() {
    if [ -d "$HOME/.nvm/versions/node" ]; then
        # Find the latest node version's bin directory
        LATEST_NODE=$(ls -t "$HOME/.nvm/versions/node/" 2>/dev/null | head -1)
        if [ -n "$LATEST_NODE" ]; then
            check_codex_path "$HOME/.nvm/versions/node/$LATEST_NODE/bin/codex" && return 0
        fi
        # Also check all versions in case latest doesn't have it
        for node_version in "$HOME/.nvm/versions/node/"*; do
            if [ -d "$node_version" ]; then
                check_codex_path "$node_version/bin/codex" && return 0
            fi
        done
    fi
    return 1
}

# Function to dynamically detect package manager bin directories
detect_package_manager_bins() {
    # Try npm global prefix
    if command -v npm >/dev/null 2>&1; then
        NPM_PREFIX=$(npm config get prefix 2>/dev/null)
        if [ -n "$NPM_PREFIX" ] && [ -d "$NPM_PREFIX/bin" ]; then
            check_codex_path "$NPM_PREFIX/bin/codex" && return 0
        fi
    fi

    # Try yarn global bin
    if command -v yarn >/dev/null 2>&1; then
        YARN_BIN=$(yarn global bin 2>/dev/null)
        if [ -n "$YARN_BIN" ] && [ -d "$YARN_BIN" ]; then
            check_codex_path "$YARN_BIN/codex" && return 0
        fi
    fi

    # Try pnpm bin
    if command -v pnpm >/dev/null 2>&1; then
        PNPM_BIN=$(pnpm bin -g 2>/dev/null)
        if [ -n "$PNPM_BIN" ] && [ -d "$PNPM_BIN" ]; then
            check_codex_path "$PNPM_BIN/codex" && return 0
        fi
    fi

    return 1
}

# Priority 1: Check if codex is already in PATH
if command -v codex >/dev/null 2>&1; then
    CODEX_PATH=$(command -v codex)
fi

# Priority 2: If not found in PATH, try dynamic package manager detection
if [ -z "$CODEX_PATH" ]; then
    detect_package_manager_bins
fi

# Priority 3: Check nvm installations
if [ -z "$CODEX_PATH" ]; then
    find_nvm_codex
fi

# Priority 4: Check all known static paths (ordered by likelihood)
if [ -z "$CODEX_PATH" ]; then
    # Common user-local installations
    for path in "$HOME/.local/bin/codex" "$HOME/.npm-global/bin/codex" "$HOME/.npm/bin/codex" "$HOME/Library/pnpm/codex" "$HOME/.yarn/bin/codex" "/usr/local/bin/codex" "/opt/homebrew/bin/codex" "/usr/bin/codex" "$HOME/.cargo/bin/codex"
    do
        check_codex_path "$path" && break
    done
fi

# If still not found, provide helpful error message
if [ -z "$CODEX_PATH" ]; then
    # Generate diagnostic information
    DIAGNOSTIC="Codex CLI Not Found

Searched in the following locations:
• Current PATH
• npm global bin directory
• yarn global bin directory
• pnpm global bin directory
• All nvm Node.js versions
• ~/.local/bin
• ~/.npm-global/bin
• ~/.npm/bin
• ~/.yarn/bin
• ~/Library/pnpm
• /usr/local/bin
• /opt/homebrew/bin
• /usr/bin

How to fix:
1. Install Codex CLI:
   npm install -g @openai/codex

2. Or check if it's installed:
   command -v codex

3. Or verify npm global prefix:
   npm config get prefix"

    osascript -e "display alert \"Codex CLI Not Found\" message \"$DIAGNOSTIC\""
    exit 1
fi

echo "✅ Found Codex at: $CODEX_PATH"

# Save current directory for next use
echo "$TARGET_DIR" > "$LAST_DIR_FILE"

# Read user terminal preference
PREFERRED_TERMINAL=""
if [ -f "$TERMINAL_CONFIG_FILE" ]; then
    PREFERRED_TERMINAL=$(cat "$TERMINAL_CONFIG_FILE" 2>/dev/null | tr -d '\n\r')
fi

# Detect available terminal apps
detect_terminal_app() {
    case "$1" in
        "iTerm2"|"iterm2"|"iTerm"|"iterm")
            if [ -d "/Applications/iTerm.app" ]; then
                echo "iTerm"
            elif [ -d "/Applications/iTerm 2.app" ]; then
                echo "iTerm 2"
            else
                echo ""
            fi
            ;;
        "Terminal"|"terminal")
            echo "Terminal"
            ;;
        "Warp"|"warp")
            if [ -d "/Applications/Warp.app" ]; then
                echo "Warp"
            else
                echo ""
            fi
            ;;
        "Alacritty"|"alacritty")
            if [ -d "/Applications/Alacritty.app" ]; then
                echo "Alacritty"
            else
                echo ""
            fi
            ;;
        *)
            echo ""
            ;;
    esac
}

# Launch terminal function
launch_terminal() {
    local terminal_app="$1"
    case "$terminal_app" in
        "iTerm"|"iTerm 2")
            osascript <<EOF
tell application "$terminal_app"
    activate
    create window with default profile
    tell current session of current window
        write text "cd " & quoted form of "$TARGET_DIR" & " && codex --yolo"
    end tell
end tell
EOF
            ;;
        "Warp")
            osascript <<EOF
tell application "Warp"
    activate
    tell application "System Events"
        keystroke "t" using {command down}
        delay 0.2
        keystroke "cd " & quoted form of "$TARGET_DIR" & " && codex --yolo"
        keystroke return
    end tell
end tell
EOF
            ;;
        "Alacritty")
            # Alacritty needs to be launched via command line
            open -a Alacritty --args --working-directory "$TARGET_DIR" -e bash -c "codex --yolo; exec bash"
            ;;
        *)
            # Default to Terminal
            osascript <<EOF
tell application "Terminal"
    activate
    do script "cd " & quoted form of "$TARGET_DIR" & " && codex --yolo"
end tell
EOF
            ;;
    esac
}

# Decide which terminal app to use
TERMINAL_TO_USE=""

# Function to count available terminals
count_available_terminals() {
    local count=0
    for app in "iTerm2" "Warp" "Alacritty" "Terminal"; do
        if [ -n "$(detect_terminal_app "$app")" ]; then
            count=$((count + 1))
        fi
    done
    echo $count
}

# Function to show first-time setup dialog
show_first_time_terminal_selection() {
    local available_terminals=()
    local terminal_list=""

    # Build list of available terminals
    for app in "iTerm2" "Warp" "Alacritty" "Terminal"; do
        local detected=$(detect_terminal_app "$app")
        if [ -n "$detected" ]; then
            available_terminals+=("$detected")
            if [ -z "$terminal_list" ]; then
                terminal_list="$detected"
            else
                terminal_list="$terminal_list, $detected"
            fi
        fi
    done

    # If only one terminal available, use it silently
    if [ ${#available_terminals[@]} -eq 1 ]; then
        echo "${available_terminals[0]}" > "$TERMINAL_CONFIG_FILE"
        return 0
    fi

    # Show dialog for user to choose
    # Build AppleScript list from bash array
    local as_list="{"
    local first=true
    for term in "${available_terminals[@]}"; do
        if [ "$first" = true ]; then
            as_list="$as_list\"$term\""
            first=false
        else
            as_list="$as_list, \"$term\""
        fi
    done
    as_list="$as_list}"

    local choice=$(osascript -e "tell application \"System Events\"
        set terminal_list to $as_list
        set user_choice to choose from list terminal_list with prompt \"Codex Now detected multiple terminal applications on your system.

Which terminal would you like to use?\" with title \"Codex Now - Terminal Selection\" default items {\"iTerm\"}
        return user_choice
    end tell" 2>/dev/null)

    if [ -n "$choice" ] && [ $? -eq 0 ]; then
        echo "$choice" > "$TERMINAL_CONFIG_FILE"
        echo "✅ Selected terminal: $choice"
        return 0
    else
        # User cancelled, use default priority (iTerm2 first)
        echo "ℹ️  Selection cancelled, using default terminal"
        return 1
    fi
}

# 1. Check if first-time setup is needed (no config file and multiple terminals)
if [ ! -f "$TERMINAL_CONFIG_FILE" ]; then
    AVAILABLE_COUNT=$(count_available_terminals)
    if [ "$AVAILABLE_COUNT" -ge 2 ]; then
        # First time with multiple terminals - show selection dialog
        show_first_time_terminal_selection
        # Re-read the config file that was just created
        if [ -f "$TERMINAL_CONFIG_FILE" ]; then
            PREFERRED_TERMINAL=$(cat "$TERMINAL_CONFIG_FILE" 2>/dev/null | tr -d '\n\r')
        fi
    fi
fi

# 2. Prefer user configured terminal
if [ -n "$PREFERRED_TERMINAL" ]; then
    DETECTED_TERMINAL=$(detect_terminal_app "$PREFERRED_TERMINAL")
    if [ -n "$DETECTED_TERMINAL" ]; then
        TERMINAL_TO_USE="$DETECTED_TERMINAL"
    fi
fi

# 3. If user configured terminal is not available, use default priority
if [ -z "$TERMINAL_TO_USE" ]; then
    # Priority: iTerm2 > Warp > Terminal
    for app in "iTerm2" "Warp" "Terminal"; do
        DETECTED_TERMINAL=$(detect_terminal_app "$app")
        if [ -n "$DETECTED_TERMINAL" ]; then
            TERMINAL_TO_USE="$DETECTED_TERMINAL"
            break
        fi
    done
fi

# Launch terminal
launch_terminal "$TERMINAL_TO_USE"
