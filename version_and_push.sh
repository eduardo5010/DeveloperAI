#!/bin/bash
cd "$(dirname "$0")"

# Lê a versão atual
current_version=$(cat version.txt)
IFS='.' read -r major minor patch <<< "$current_version"

# Obtém arquivos modificados desde o último commit
changed=$(git diff --name-only HEAD)

# Detecta tipo de mudança
version_type="patch"
if echo "$changed" | grep -qE '^Core/|^System/|^Memory/|^Logic/'; then
    version_type="major"
elif echo "$changed" | grep -qE '^Modules/|^Interface/|^Sandbox/'; then
    version_type="minor"
fi

# Calcula nova versão
case $version_type in
    major)
        major=$((major + 1)); minor=0; patch=0 ;;
    minor)
        minor=$((minor + 1)); patch=0 ;;
    patch)
        patch=$((patch + 1)) ;;
esac

new_version="$major.$minor.$patch"

# Mostra sugestão
echo "🔎 Changes detected in: $version_type-level folders"
echo "📌 Current version: $current_version"
echo "🚀 Suggested version: $new_version"

# Confirma aplicação
read -p "Apply and push version $new_version? [y/N] " confirm
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    echo "$new_version" > version.txt
    git add .
    git commit -m "Version $new_version"
    git tag -a "v$new_version" -m "Release version $new_version"
    git push origin master
    git push origin "v$new_version"
    echo "✅ Version $new_version pushed to GitHub."
else
    echo "❌ Versioning canceled."
fi
