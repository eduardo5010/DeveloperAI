#!/bin/bash
cd "$(dirname "$0")"

# Lê a versão atual
current_version=$(cat version.txt)

# Extrai partes da versão
IFS='.' read -r major minor patch <<< "$current_version"

# Obtém lista de arquivos modificados desde o último commit
changed=$(git diff --name-only HEAD)

# Define tipo de mudança
version_type="patch"

if echo "$changed" | grep -qE '^Core/|^System/|^Memory/|^Logic/'; then
    version_type="major"
elif echo "$changed" | grep -qE '^Modules/|^Interface/|^Sandbox/'; then
    version_type="minor"
fi

# Calcula nova versão
case $version_type in
    major)
        major=$((major + 1))
        minor=0
        patch=0
        ;;
    minor)
        minor=$((minor + 1))
        patch=0
        ;;
    patch)
        patch=$((patch + 1))
        ;;
esac

new_version="$major.$minor.$patch"

# Mostra sugestão
echo "🔎 Detected changes in: $version_type-level folders"
echo "📌 Current version: $current_version"
echo "🚀 Suggested next version: $new_version"

# Pergunta se deseja aplicar
read -p "Apply this version and tag it? [y/N] " confirm
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    echo "$new_version" > version.txt
    git add version.txt
    git commit -m "Version $new_version"
    git tag -a "v$new_version" -m "Release version $new_version"
    git push origin master
    git push origin "v$new_version"
    echo "✅ Version $new_version committed and pushed to GitHub."
else
    echo "❌ Versioning canceled."
fi
