#!/bin/bash
cd "$(dirname "$0")"

COMMAND=$1

case $COMMAND in
    build)
        echo "🔧 Compiling DeveloperAI for Linux..."
        g++ main.cpp -o Core/DeveloperAI_Linux.bin
        echo "🔧 Compiling DeveloperAI for Windows..."
        x86_64-w64-mingw32-g++ main.cpp -o Core/DeveloperAI_Windows.exe
        echo "✅ Build complete."
        ;;

    version)
        ./suggest_version.sh
        ;;

    release)
        ./version_and_update.sh
        ;;

    push)
        git push origin master
        git push --tags
        echo "🚀 All commits and tags pushed to GitHub."
        ;;

    help|*)
        echo "🧠 DeveloperAI CLI – Available commands:"
        echo "  devai build     → Compile binaries for Linux and Windows"
        echo "  devai version   → Suggest and apply semantic version"
        echo "  devai release   → Version + update Manifesto and Architecture"
        echo "  devai push      → Push commits and tags to GitHub"
        echo "  devai help      → Show this help message"
        ;;
esac
