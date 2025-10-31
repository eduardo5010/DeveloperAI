#!/bin/bash
cd "$(dirname "$0")"

# Lê a versão atual
version=$(cat version.txt)

# Adiciona alterações
git add .
git commit -m "Version $version"

# Cria uma tag semântica
git tag -a "v$version" -m "Release version $version"

# Envia para o GitHub
git push origin main
git push origin "v$version"
