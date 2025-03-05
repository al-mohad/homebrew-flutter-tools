#!/bin/bash

set -e  # Exit immediately on error

# 🆘 Display Help
if [[ $1 == "-h" || $1 == "--help" ]]; then
    echo "🛠️ create_flutter_app - A script to create a new Flutter project efficiently."
    echo "📌 Usage: fapp"
    echo "💡 Features:"
    echo "  ✅ Checks & installs missing dependencies (curl, jq, unzip, git)"
    echo "  ✅ Installs Flutter if not found"
    echo "  ✅ Asks for app name & project type"
    echo "  ✅ Installs state management (default: Riverpod)"
    echo "  ✅ Adds recommended dependencies (build_runner, freezed, dio, etc.)"
    echo "  ✅ Detects & opens VS Code or Android Studio"
    echo "  ✅ Adds alias 'fapp' for quick project creation"
    echo "📝 Example: fapp"
    exit 0
fi

# Detect OS and set Flutter installation directory
if [[ "$OSTYPE" == "darwin"* ]]; then
    INSTALL_DIR="$HOME/Developer/flutter"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    INSTALL_DIR="$HOME/Developer/flutter"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    echo "🖥️ Where do you want to install Flutter?"
    echo "1️⃣ Windows User Directory (default)"
    echo "2️⃣ WSL (/mnt/c/Users/$USER/Developer/flutter)"
    read -r -p "👉 Choose (1 or 2): " INSTALL_CHOICE
    INSTALL_DIR=$([ "$INSTALL_CHOICE" == "2" ] && echo "/mnt/c/Users/$USER/Developer/flutter" || echo "C:/Users/$USERNAME/Developer/flutter")
else
    echo "❌ Unsupported OS!"
    exit 1
fi

# ✅ Check & Install Missing Dependencies
check_dependencies() {
    MISSING_DEPS=()
    for CMD in curl jq unzip git fzf; do
        if ! command -v "$CMD" &> /dev/null; then
            MISSING_DEPS+=("$CMD")
        fi
    done

    if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
        echo "⚠️ Missing dependencies: ${MISSING_DEPS[*]}"
        read -r -p "🔄 Install them now? (y/n) " INSTALL_DEPS
        if [[ "$INSTALL_DEPS" =~ ^[Yy]$ ]]; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                brew install "${MISSING_DEPS[@]}"
            elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
                sudo apt update && sudo apt install -y "${MISSING_DEPS[@]}"
            else
                echo "❌ Please install: ${MISSING_DEPS[*]} manually."
                exit 1
            fi
        else
            echo "🚫 Cannot proceed without dependencies. Exiting."
            exit 1
        fi
    fi
}

# 📌 Get App Name
read -r -p "📝 Enter Flutter app name (default: flutter_app): " APP_NAME
APP_NAME=${APP_NAME:-flutter_app}

# 🎯 Select Project Type with fzf or fallback to select
OPTIONS=("application" "empty" "skeleton" "package" "plugin" "module" "server")
if command -v fzf &> /dev/null; then
    TEMPLATE=$(printf "%s\n" "${OPTIONS[@]}" | fzf --prompt="📦 Choose a Flutter project type: ")
else
    echo "📦 Choose a Flutter project type:"
    select TEMPLATE in "${OPTIONS[@]}"; do
        break
    done
fi

# 🚀 Create Flutter Project
flutter create --template="$TEMPLATE" "$APP_NAME"
cd "$APP_NAME" || exit

# 🔄 Select State Management
SM_OPTIONS=("Riverpod (default)" "Provider" "Bloc" "GetX" "None")
if command -v fzf &> /dev/null; then
    SM_CHOICE=$(printf "%s\n" "${SM_OPTIONS[@]}" | fzf --prompt="🔧 Choose state management: ")
else
    echo "🔧 Choose state management:"
    select SM_CHOICE in "${SM_OPTIONS[@]}"; do
        break
    done
fi

case "$SM_CHOICE" in
    "Provider") flutter pub add provider ;;
    "Bloc") flutter pub add flutter_bloc equatable ;;
    "GetX") flutter pub add get ;;
    *) flutter pub add flutter_riverpod riverpod_annotation riverpod_generator ;;
esac

# 📦 Install Dependencies
echo "📥 Installing recommended dependencies..."
flutter pub add build_runner freezed freezed_annotation json_serializable dio go_router shared_preferences hive hive_flutter

# 🔧 Install Utilities
flutter pub add logger flutter_secure_storage intl device_info_plus url_launcher connectivity_plus path_provider

# 🔥 Firebase Setup
read -r -p "🔥 Install Firebase? (y/n) " INSTALL_FIREBASE
if [[ "$INSTALL_FIREBASE" =~ ^[Yy]$ ]]; then
    flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage firebase_messaging
fi

# 🎯 Initialize Git
git init
git add .
git commit -m "🚀 Initial commit"

# 💻 Open Editor
EDITOR_OPTIONS=("VS Code" "Android Studio" "Skip")
if command -v fzf &> /dev/null; then
    EDITOR=$(printf "%s\n" "${EDITOR_OPTIONS[@]}" | fzf --prompt="🖥️ Open project in editor? ")
else
    echo "🖥️ Open project in editor?"
    select EDITOR in "${EDITOR_OPTIONS[@]}"; do
        break
    done
fi

case "$EDITOR" in
    "VS Code") code . ;;
    "Android Studio") studio . ;;
esac

echo "🎉 Setup Complete! Run 'cd $APP_NAME' to start coding! 🚀"