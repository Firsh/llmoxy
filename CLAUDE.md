# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

llmoxy is a CLI utility that manages LiteLLM proxy services for Claude Code integration. It provides a Docker-based proxy server that routes AI model requests through OpenRouter, enabling access to various AI models (currently MoonshotAI Kimi models) via a local proxy.

The tool bridges Claude Code's API expectations with alternative model providers, allowing users to continue coding sessions with non-Anthropic models when needed for cost optimization or extended usage scenarios.

## Architecture

The system operates as a transparent proxy layer between Claude Code and alternative model providers:

- **llmoxy CLI script**: Main executable that manages Docker services and launches Claude Code with proper environment variables
- **Docker Compose setup**: Runs LiteLLM proxy in a container named "llmoxy" on port 4000
- **LiteLLM configuration**: Routes requests to OpenRouter API with model-specific configurations
- **Aliases system**: Provides convenient shortcuts for common operations

### Key Architectural Decisions

1. **Environment Variable Interception**: llmoxy temporarily overrides Claude Code's authentication environment variables to redirect API calls to the local proxy
2. **Model Name Mapping**: User-friendly nicknames (kimi, dsr1) map to full provider paths (openrouter/moonshotai/kimi-k2) 
3. **Auto-Generated Aliases**: Dynamic alias generation from config.yaml ensures consistency and reduces maintenance
4. **Robust Shell Parsing**: Uses only standard Unix tools (grep/sed) for reliable configuration parsing

## Essential Commands

### Proxy Management

```bash
llmoxy --start       # Start the LiteLLM proxy service
llmoxy --stop        # Stop the proxy service
llmoxy --restart     # Restart the proxy service
llmoxy --status      # Show proxy status and available models
llmoxy --logs        # View proxy logs
```

### Model Access

```bash
llmoxy --run kimi       # Launch Claude Code with Kimi K2 model  
llmoxy --run kimi-turbo # Launch Claude Code with Kimi K2 Turbo Preview
llmoxy --run dsr1       # Launch Claude Code with DeepSeek R1
llmoxy --run qwen       # Launch Claude Code with Qwen3 Coder
kimi                    # Alias for llmoxy --run kimi
kimi-turbo              # Alias for llmoxy --run kimi-turbo  
dsr1                    # Alias for llmoxy --run dsr1
qwen                    # Alias for llmoxy --run qwen
```

### Development and Debugging

```bash
curl http://localhost:4000/health           # Check proxy health
curl http://localhost:4000/models           # List available models
docker ps                                   # Check container status
docker compose logs -f litellm              # Follow container logs
```

## Configuration Files

- **config.yaml**: LiteLLM model configuration with OpenRouter endpoints and provider routing
- **docker-compose.yml**: Container definition with health checks and volume mounts  
- **.env**: Contains OPENROUTER_API_KEY and MOONSHOT_API_KEY (required for model access)
- **aliases.sh**: Auto-generated shell aliases and PATH configuration
- **.env.example**: Template for environment variables

## Key Integration Points

When llmoxy launches Claude Code, it automatically sets:

- `ANTHROPIC_AUTH_TOKEN=sk-4` (dummy token for local proxy)
- `ANTHROPIC_BASE_URL=http://localhost:4000` (points to local LiteLLM proxy)
- `ANTHROPIC_MODEL=<selected_model>` (kimi, kimi-turbo, dsr1, or qwen)

The LiteLLM proxy translates Claude API calls to OpenRouter format and handles authentication with the real API key. Environment variables are cleaned up after Claude Code exits, restoring normal Anthropic access.

## Development Workflow

1. Ensure Docker is running
2. Set up environment: `cp .env.example .env` and add your API keys
3. Start proxy: `llmoxy --start` 
4. Verify status: `llmoxy --status`
5. Launch Claude Code with desired model: `kimi`, `kimi-turbo`, `dsr1`, or `qwen`
6. Stop proxy when done: `llmoxy --stop`

### Partial API Key Setup

**You can run llmoxy with only one API key** - the system will gracefully handle missing keys:

- **With only OPENROUTER_API_KEY**: `kimi`, `dsr1`, and `qwen` will work; `kimi-turbo` will fail at request time
- **With only MOONSHOT_API_KEY**: `kimi-turbo` will work; other models will fail at request time
- **llmoxy commands always work** regardless of missing keys (status, logs, model listing)

### Adding New Models

1. Edit `config.yaml` to add new model configurations
2. Run `llmoxy --generate-aliases` to update aliases
3. Source the updated aliases: `source aliases.sh`

## Model Configuration

Models are defined in config.yaml with:

- OpenRouter endpoint mapping or direct provider access
- Function calling support enabled
- Environment variable API key references
- Provider routing preferences (specific providers, fallback orders)

Current models:

- **kimi**: openrouter/moonshotai/kimi-k2 (via Fireworks provider)
- **kimi-turbo**: moonshot/kimi-k2-turbo-preview (direct from Moonshot)
- **dsr1**: openrouter/deepseek/deepseek-r1-0528 (via Lambda/Novita/GMICloud)
- **qwen**: openrouter/qwen/qwen3-coder (via DeepInfra/GMICloud)

## Code Structure and Key Functions

### Main Script Functions (llmoxy)

- **`get_full_model_name()`**: Maps nicknames to full model paths from config.yaml
- **`generate_aliases()`**: Auto-generates aliases.sh from config.yaml model definitions
- **`run_claude_with_model()`**: Core function that starts proxy if needed, verifies model, sets environment variables, and launches Claude Code
- **`proxy_start/stop/restart()`**: Docker Compose management functions
- **`proxy_status()`**: Health checks and model listing with fallbacks
- **`should_regenerate_aliases()`**: Determines when aliases.sh needs updating

### Configuration Parsing

The script uses reliable shell parsing with standard Unix tools:
1. **YAML parsing**: Uses `grep` and `sed` for extracting model configurations from config.yaml
2. **JSON parsing**: Uses `grep` and `sed` for parsing API responses from the proxy

Model display format shows both nickname and full path: `kimi (openrouter/moonshotai/kimi-k2)`

No external dependencies (jq/yq) required - works on any Unix-like system out of the box.

### Environment Variable Lifecycle

1. Export temporary variables before launching Claude Code
2. Variables scope limited to the `claude` process
3. Automatic cleanup via `unset` after Claude Code exits
4. Normal Anthropic access restored when returning to regular usage

## Troubleshooting Commands

```bash
llmoxy --status                             # Check if proxy is running
llmoxy --logs                              # View proxy logs
docker ps                                  # Check container status
curl http://localhost:4000/health          # Test proxy health endpoint
```

### Common Issues

**"No auth credentials found" Error:**
- Occurs when trying to use a model whose API key is missing from `.env`
- Check which API key is needed for your model (see Model Configuration section)
- Verify the key is set in `.env` and restart the proxy

**Models appear in listing but fail when used:**
- This is expected behavior when API keys are missing
- The proxy starts successfully but individual requests fail at runtime
- Add the required API key to `.env` and restart: `llmoxy --restart`
