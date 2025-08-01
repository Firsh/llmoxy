#!/bin/bash

# llmoxy Installation Script
# Usage: curl -sSL https://raw.githubusercontent.com/Firsh/llmoxy/main/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

INSTALL_DIR="$HOME/llmoxy"
REPO_URL="https://github.com/Firsh/llmoxy.git"

echo -e "${BLUE}🚀 llmoxy Installation Script${NC}"
echo -e "${BLUE}================================${NC}"

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git is required but not installed. Please install git first.${NC}"
    exit 1
fi

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker is not installed. llmoxy requires Docker to run the LiteLLM proxy.${NC}"
    echo -e "${BLUE}💡 Please install Docker: https://docs.docker.com/get-docker/${NC}"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if docker compose is available
if ! command -v docker &> /dev/null || ! docker compose version &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker Compose is required for llmoxy to work properly.${NC}"
fi

# Remove existing installation if it exists
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}⚠️  Existing llmoxy installation found at $INSTALL_DIR${NC}"
    read -p "Remove and reinstall? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}🗑️  Removing existing installation...${NC}"
        rm -rf "$INSTALL_DIR"
    else
        echo -e "${RED}❌ Installation cancelled.${NC}"
        exit 1
    fi
fi

# Clone the repository
echo -e "${BLUE}📥 Cloning llmoxy repository...${NC}"
git clone "$REPO_URL" "$INSTALL_DIR"

# Make the main script executable
echo -e "${BLUE}🔧 Setting up permissions...${NC}"
chmod +x "$INSTALL_DIR/llmoxy"

# Create .env file from template if it doesn't exist
if [ ! -f "$INSTALL_DIR/.env" ]; then
    echo -e "${BLUE}📝 Creating .env file from template...${NC}"
    cp "$INSTALL_DIR/.env.example" "$INSTALL_DIR/.env"
    echo -e "${YELLOW}⚠️  Remember to add your API keys to $INSTALL_DIR/.env${NC}"
fi

# Generate initial aliases
echo -e "${BLUE}🔗 Generating command aliases...${NC}"
cd "$INSTALL_DIR"
./llmoxy --generate-aliases

# Detect shell and add to appropriate rc file
SHELL_RC=""
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
else
    # Try to detect from SHELL environment variable
    case "$SHELL" in
        */zsh) SHELL_RC="$HOME/.zshrc" ;;
        */bash) SHELL_RC="$HOME/.bashrc" ;;
        *) SHELL_RC="$HOME/.bashrc" ;;  # Default fallback
    esac
fi

# Add source line to shell rc file
ALIASES_LINE="source $INSTALL_DIR/aliases.sh"
if [ -f "$SHELL_RC" ] && ! grep -q "$ALIASES_LINE" "$SHELL_RC"; then
    echo -e "${BLUE}🔗 Adding llmoxy aliases to $SHELL_RC...${NC}"
    echo "" >> "$SHELL_RC"
    echo "# llmoxy aliases" >> "$SHELL_RC"
    echo "$ALIASES_LINE" >> "$SHELL_RC"
    echo -e "${GREEN}✅ Added to $SHELL_RC${NC}"
else
    echo -e "${YELLOW}⚠️  Could not automatically add to shell config.${NC}"
    echo -e "${BLUE}💡 Please add this line to your shell config file:${NC}"
    echo -e "${BLUE}   $ALIASES_LINE${NC}"
fi

echo -e "${GREEN}✅ llmoxy installation completed!${NC}"
echo -e "${BLUE}📍 Installed to: $INSTALL_DIR${NC}"
echo ""
echo -e "${BLUE}🎯 Next steps:${NC}"
echo -e "${BLUE}1. Add your API keys to: $INSTALL_DIR/.env${NC}"
echo -e "${BLUE}2. Restart your terminal or run: source $SHELL_RC${NC}"
echo -e "${BLUE}3. Start the proxy: llmoxy --start${NC}"
echo -e "${BLUE}4. Try a model: kimi${NC}"
echo ""
echo -e "${BLUE}💡 Run 'llmoxy --help' for all available commands${NC}"