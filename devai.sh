#!/bin/bash
cd /home/eduar/Kali/Ubuntu/DeveloperAI

COMMAND=$1

case $COMMAND in
    upgrade)
        echo "🚀 Upgrading DeveloperAI..."

        echo "🔢 Applying new version..."
        ./suggest_version.sh

        echo "📦 Releasing version..."
        ./version_and_update.sh

        echo "📚 Generating documentation..."
        $0 doc

        echo "📜 Updating changelog..."
        $0 changelog

        echo "🚀 Pushing to GitHub..."
        git push origin main
        git push --tags

        echo "✅ Upgrade complete."
        ;;

    clean)
        echo "🧹 Cleaning DeveloperAI workspace..."

        # Remove binários
        rm -f Core/*.bin Core/*.exe

        # Remove pastas temporárias
        rm -rf Release
        rm -rf Tests

        # Remove arquivos .keep (opcional)
        find . -name ".keep" -type f -delete

        echo "✅ Workspace cleaned."
        ;;

    doc)
        echo "📚 Generating technical documentation..."

        doc_file="Docs/Architecture.md"
        version=$(cat version.txt)
        timestamp=$(date +"%Y-%m-%d %H:%M:%S")

        echo "# DeveloperAI – Architecture" > "$doc_file"
        echo "Version: $version" >> "$doc_file"
        echo "Generated: $timestamp" >> "$doc_file"
        echo -e "\n## Project Structure\n" >> "$doc_file"

        for dir in Core Modules System Interface Sandbox Memory Logic Data; do
            if [[ -d "$dir" ]]; then
                echo "### $dir/" >> "$doc_file"
                case $dir in
                    Core) echo "- Contains compiled binaries and core engine logic." >> "$doc_file" ;;
                    Modules) echo "- Modular components that extend DeveloperAI's capabilities." >> "$doc_file" ;;
                    System) echo "- System-level operations, configurations, and runtime control." >> "$doc_file" ;;
                    Interface) echo "- Handles user interaction, CLI commands, and external APIs." >> "$doc_file" ;;
                    Sandbox) echo "- Experimental features and isolated test environments." >> "$doc_file" ;;
                    Memory) echo "- Persistent memory and state management for long-term context." >> "$doc_file" ;;
                    Logic) echo "- Reasoning, decision-making, and AI behavior rules." >> "$doc_file" ;;
                    Data) echo "- Static datasets, training samples, and reference files." >> "$doc_file" ;;
                esac
                echo "" >> "$doc_file"
            fi
        done

        echo "✅ Documentation updated at $doc_file"
        ;;

    test)
        echo "🧪 Running DeveloperAI test suite..."
        echo "-----------------------------------"

        mkdir -p Tests
        report="Tests/report.txt"
        echo "DeveloperAI Test Report – $(date)" > "$report"
        echo "-----------------------------------" >> "$report"

        passed=0
        failed=0

        log_result() {
            echo "$1"
            echo "$1" >> "$report"
        }

        # Teste 1: binários existem
        log_result "🔍 Checking binaries..."
        for bin in Core/DeveloperAI_Linux.bin Core/DeveloperAI_Windows.exe; do
            if [[ -f "$bin" ]]; then
                log_result "✅ $bin found"
                ((passed++))
            else
                log_result "❌ $bin missing"
                ((failed++))
            fi
        done

        # Teste 2: arquivos essenciais
        log_result "🔍 Checking essential files..."
        for file in version.txt Docs/Manifesto.txt Docs/Architecture.md; do
            if [[ -f "$file" ]]; then
                log_result "✅ $file exists"
                ((passed++))
            else
                log_result "❌ $file missing"
                ((failed++))
            fi
        done

        # Teste 3: execução simulada
        log_result "🔄 Simulating Linux binary execution..."
        output=$(./Core/DeveloperAI_Linux.bin --test 2>/dev/null)
        if [[ $? -eq 0 ]]; then
            log_result "✅ Execution succeeded"
            log_result "🧠 Output: $output"
            ((passed++))

            # Validação de estrutura da resposta
            if echo "$output" | grep -q "DeveloperAI ready"; then
                log_result "✅ Output structure valid"
                ((passed++))
            else
                log_result "❌ Output structure invalid"
                ((failed++))
            fi
        else
            log_result "⚠️ Execution failed or not implemented"
            ((failed++))
        fi

        # Teste 4: estrutura de pastas
        log_result "📁 Checking folder structure..."
        for dir in Core Modules System Interface Sandbox; do
            if [[ -d "$dir" ]]; then
                log_result "✅ $dir exists"
                ((passed++))
            else
                log_result "❌ $dir missing"
                ((failed++))
            fi
        done

        # Relatório final
        log_result "-----------------------------------"
        log_result "✅ Passed: $passed"
        log_result "❌ Failed: $failed"

        if [[ $failed -eq 0 ]]; then
            log_result "🎉 All tests passed successfully!"
        else
            log_result "⚠️ Some tests failed. Review above."
        fi

        echo "📄 Report saved to $report"
        ;;


    deploy)
        echo "📦 Preparing deployment package..."

        # Cria pasta Release/ limpa
        rm -rf Release
        mkdir -p Release/bin
        mkdir -p Release/docs

        # Copia binários
        cp Core/DeveloperAI_Linux.bin Release/bin/ 2>/dev/null
        cp Core/DeveloperAI_Windows.exe Release/bin/ 2>/dev/null

        # Copia arquivos essenciais
        cp version.txt Release/
        cp -r Docs/* Release/docs/ 2>/dev/null

        echo "✅ Deployment package created in Release/"
        ;;

    changelog)
        echo "📜 Generating Changelog..."

        changelog_file="Docs/Changelog.txt"
        echo "# DeveloperAI – Changelog" > "$changelog_file"

        # Lista todas as tags ordenadas
        for tag in $(git tag --sort=creatordate); do
            # Data da tag
            tag_date=$(git log -1 --format=%ad --date=short "$tag")
            # Hash e mensagem do commit
            commit_info=$(git log -1 --pretty=format:"%h – %s" "$tag")

            echo -e "\n## $tag – $tag_date" >> "$changelog_file"
            echo "- Commit: $commit_info" >> "$changelog_file"
        done

        echo "✅ Changelog updated at $changelog_file"
        ;;

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
        git push origin main
        git push --tags
        echo "🚀 All commits and tags pushed to GitHub."
        ;;

    status)
        echo "🧠 DeveloperAI Status"
        echo "----------------------"

        # Versão atual
        if [[ -f version.txt ]]; then
            echo -n "📌 Current version: "
            cat version.txt
        else
            echo "📌 Current version: (version.txt not found)"
        fi

        # Branch ativo
        echo -n "🌿 Active branch: "
        git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "(not a git repository)"

        # Último commit
        echo "📝 Last commit:"
        git log -1 --pretty=format:"%h – %s (%cr)" 2>/dev/null || echo "(no commits yet)"

        # Pastas modificadas
        echo "📂 Modified folders since last commit:"
        git diff --name-only HEAD 2>/dev/null | grep '/' | awk -F/ '{print "- " $1}' | sort -u || echo "(no changes)"
        ;;

    help|*)
        echo "🧠 DeveloperAI CLI – Available commands:"
        echo "  devai build     → Compile binaries for Linux and Windows"
        echo "  devai version   → Suggest and apply semantic version"
        echo "  devai release   → Version + update Manifesto and Architecture"
        echo "  devai push      → Push commits and tags to GitHub"
        echo "  devai status    → Show current version, branch, changes and last commit"
        echo "  devai help      → Show this help message"
        echo "  devai changelog → Generate or update Docs/Changelog.txt based on version tags"
        echo "  devai deploy    → Package binaries and documentation into Release/ folder"
        echo "  devai test      → Run full test suite and save report to Tests/report.txt"
        echo "  devai doc       → Generate or update Docs/Architecture.md with current structure and descriptions"
        echo "  devai clean     → Remove binaries, release and test folders to clean workspace"
        echo "  devai upgrade   → Apply version, release, doc, changelog and push in one step"
        ;;

esac
