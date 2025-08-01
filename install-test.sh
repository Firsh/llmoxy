#!/bin/bash

# Test version of install script - installs to ~/llmoxy-test instead

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

INSTALL_DIR="$HOME/llmoxy-test"
REPO_URL="/home/firsh/llmoxy"  # Use local path for testing

echo -e "${BLUE}🚀 llmoxy Installation Script (TEST MODE)${NC}"
echo -e "${BLUE}===========================================${NC}"

# Remove existing test installation if it exists
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}⚠️  Existing test installation found at $INSTALL_DIR${NC}"
    echo -e "${BLUE}🗑️  Removing existing test installation...${NC}"
    rm -rf "$INSTALL_DIR"
fi

# Copy the repository (simulate git clone)
echo -e "${BLUE}📥 Copying llmoxy repository...${NC}"
cp -r "$REPO_URL" "$INSTALL_DIR"

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

echo -e "${GREEN}✅ llmoxy test installation completed!${NC}"
echo -e "${BLUE}📍 Installed to: $INSTALL_DIR${NC}"
echo ""
echo -e "${BLUE}🧪 Test commands:${NC}"
echo -e "${BLUE}  cd $INSTALL_DIR${NC}"
echo -e "${BLUE}  ./llmoxy --help${NC}"
echo -e "${BLUE}  ./llmoxy --version${NC}"
echo ""
echo -e "${BLUE}🧹 Cleanup: rm -rf $INSTALL_DIR${NC}"