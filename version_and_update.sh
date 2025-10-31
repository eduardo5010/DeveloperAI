#!/bin/bash
cd "$(dirname "$0")"

# Lê versão atual
current_version=$(cat version.txt)
IFS='.' read -r major minor patch <<< "$current_version"

# Detecta mudanças
changed=$(git diff --name-only HEAD)
version_type="patch"
if echo "$changed" | grep -qE '^Core/|^System/|^Memory/|^Logic/'; then
    version_type="major"
elif echo "$changed" | grep -qE '^Modules/|^Interface/|^Sandbox/'; then
    version_type="minor"
fi

# Calcula nova versão
case $version_type in
    major) major=$((major + 1)); minor=0; patch=0 ;;
    minor) minor=$((minor + 1)); patch=0 ;;
    patch) patch=$((patch + 1)) ;;
esac
new_version="$major.$minor.$patch"

# Mostra sugestão
echo "🔎 Changes detected in: $version_type-level folders"
echo "📌 Current version: $current_version"
echo "🚀 Suggested version: $new_version"
read -p "Apply and push version $new_version? [y/N] " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "❌ Versioning canceled."
    exit 0
fi

# Atualiza version.txt
echo "$new_version" > version.txt

# Atualiza Architecture.md
timestamp=$(date +"%Y-%m-%d %H:%M:%S")
echo -e "\n## Version $new_version – $timestamp\n" >> Docs/Architecture.md
echo "### Modified folders:" >> Docs/Architecture.md
echo "$changed" | grep '/' | awk -F/ '{print "- " $1}' | sort -u >> Docs/Architecture.md

# Atualiza Manifesto.txt
echo -e "\nVersion $new_version – $timestamp" >> Docs/Manifesto.txt
echo "Change type: $version_type" >> Docs/Manifesto.txt
echo "Purpose: Automated evolution based on folder changes." >> Docs/Manifesto.txt

# Commit, tag e push
git add .
git commit -m "Version $new_version"
git tag -a "v$new_version" -m "Release version $new_version"
git push origin main
git push origin "v$new_version"

echo "✅ Version $new_version pushed and documentation updated."
