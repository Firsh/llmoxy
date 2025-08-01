#!/bin/bash
# Convenience aliases for llmoxy
# Add this to your ~/.bashrc or ~/.zshrc: source ~/llmoxy/aliases.sh

# Get the directory where this script is located
LLMOXY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Add llmoxy to PATH if not already there
if [[ ":$PATH:" != *":$LLMOXY_DIR:"* ]]; then
    export PATH="$LLMOXY_DIR:$PATH"
fi

# Proxy management shortcuts
alias llmoxy-start='llmoxy --start'
alias llmoxy-stop='llmoxy --stop'
alias llmoxy-status='llmoxy --status'
alias llmoxy-logs='llmoxy --logs'
alias llmoxy-restart='llmoxy --restart'
alias llmoxy-aliases='llmoxy --generate-aliases'

# Direct Moonshot Anthropic endpoint aliases (bypass LiteLLM)
alias kimi='(cd "$LLMOXY_DIR" && source .env 2>/dev/null; ANTHROPIC_AUTH_TOKEN="$MOONSHOT_API_KEY" ANTHROPIC_BASE_URL="https://api.moonshot.ai/anthropic" ANTHROPIC_MODEL="kimi-k2-0711-preview" claude)'

alias kimi-turbo='(cd "$LLMOXY_DIR" && source .env 2>/dev/null; ANTHROPIC_AUTH_TOKEN="$MOONSHOT_API_KEY" ANTHROPIC_BASE_URL="https://api.moonshot.ai/anthropic" ANTHROPIC_MODEL="kimi-k2-turbo-preview" claude)'

# BEGIN AUTO-GENERATED ALIASES
# Dynamic model aliases are automatically updated from config.yaml
alias kimi-or='llmoxy --run kimi-or'
alias dsr1='llmoxy --run dsr1'
alias qwen='llmoxy --run qwen'
# END AUTO-GENERATED ALIASES


