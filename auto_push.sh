#!/bin/bash
cd "$(dirname "$0")"
git add .
timestamp=$(date +"%Y-%m-%d %H:%M:%S")
git commit -m "Auto version at $timestamp"
git push origin main
