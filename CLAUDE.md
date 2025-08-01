# CLAUDE.md

Claude Code guidance for working with the llmoxy repository.

## Quick Reference

**Direct Moonshot Access (Recommended):**
- `kimi` - Kimi K2 via Moonshot's /anthropic endpoint
- `kimi-turbo` - Kimi K2 Turbo Preview via Moonshot's /anthropic endpoint

**Proxy-based (Fallback):**
- `kimi-or` - Kimi K2 via OpenRouter
- `dsr1` - DeepSeek R1 via OpenRouter  
- `qwen` - Qwen3 Coder via OpenRouter

**Management:**
- `llmoxy --start/--stop/--restart` - Proxy control
- `llmoxy --status` - Health check and model listing
- `llmoxy --logs` - View container logs
- `llmoxy --generate-aliases` - Update aliases from config.yaml

## Key Files & Their Purpose

- **`llmoxy`**: Main executable (bash script)
- **`config.yaml`**: LiteLLM model configurations for proxy-based models
- **`aliases.sh`**: Shell aliases (auto-generated + manual direct access)
- **`.env`**: API keys (OPENROUTER_API_KEY, MOONSHOT_API_KEY)
- **`docker-compose.yml`**: LiteLLM proxy container definition

## Architecture Notes

**Direct Access:** `kimi`/`kimi-turbo` bypass the proxy entirely, connecting directly to `https://api.moonshot.ai/anthropic` with environment variable overrides for better caching.

**Proxy Access:** Other models route through local LiteLLM proxy (localhost:4000) which translates to OpenRouter APIs.

**Environment Variable Pattern:** llmoxy temporarily sets `ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_BASE_URL`, and `ANTHROPIC_MODEL` when launching Claude Code, then cleans up on exit.

## Development Commands

```bash
# Test proxy health
curl http://localhost:4000/health

# View available proxy models
curl http://localhost:4000/models

# Check container status
docker ps | grep llmoxy

# Follow container logs
docker compose logs -f litellm

# Regenerate aliases after config changes
llmoxy --generate-aliases && source aliases.sh
```

## Key Functions (llmoxy script)

- `get_full_model_name()` - Maps model nicknames to full paths via config.yaml parsing
- `run_claude_with_model()` - Core launcher with environment setup
- `generate_aliases()` - Auto-generates aliases.sh from config.yaml
- `proxy_start/stop/restart()` - Docker Compose management
- `should_regenerate_aliases()` - Detects when aliases need updating

## Troubleshooting

**Missing API keys:** Models will appear in listings but fail at request time if their required API key is missing from `.env`

**Proxy won't start:** Check Docker status, port 4000 availability, and API key validity

**Aliases not working:** Run `source aliases.sh` after any config changes
