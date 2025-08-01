# llmoxy - LiteLLM Proxy Manager for Claude Code

I created the llmoxy tool to bridge Claude Code's API expectations with alternative model providers, allowing users to continue coding sessions with non-Anthropic models when needed for cost optimization or extended usage scenarios. This tiny CLI utility manages a LiteLLM proxy docker service and its purpose is to provide seamless access to AI models such as **Kimi K2** inside Claude Code by connecting to providers using OpenRouter or even directly.

# Why llmoxy?

## For CC Pro Plan Users

**Extending your coding sessions:** When you have the [Pro plan](https://support.anthropic.com/en/articles/11145838-using-claude-code-with-your-pro-or-max-plan) and run out of usage in the five-hour window but have the need to absolutely continue coding, you can switch to API-based usage from a 3rd-party model from a provider of your choice via OpenRouter, made accessible llmoxy (using LiteLLM under the hood) and just continue working at a cheap cost.

**Provider-specific control:** The problem with other solutions like [claude-code-router](https://github.com/musistudio/claude-code-router) (at the time of writing) is not exposing OpenRouter's [provider routing](https://openrouter.ai/docs/features/provider-routing) options. So you could not, in short of using the accountwide setting and restricting your providers, choose what provider you wanted to use. I understand that it is the essence of OpenRouter to automatically do some magic to route your request to the "best" provider, but I wanted to choose specific providers at certain costs as this is already a fallback in itself.

**Reputable provider selection:** I wanted to pick a reputable provider and stick with it. OpenRouter's fallback mindset of ensuring that you are always connected to a router is fine and the tool doesn't restrict that kind of configuration (see how **DeepSeek R1** and **Qwen3 Coder** are set up in the config).

## For Non-Pro Users

**Trying Claude Code affordably:** If you don't yet have the pro plan but want to try Claude Code with the understanding that the model you get will not be Claude Sonnet, you can do it using llmoxy because it connects you to any model you want that is open source or otherwise available through [OpenRouter](https://openrouter.ai/) or directly from other providers like [Mooonshot.ai](https://platform.moonshot.ai/docs/guide/agent-support#get-api-key). If you have 5-10 dollars to spare to charge an account, then that's a cheap way to try it

**Light usage scenarios:** It also works if you don't code that much to justify the pro plan from Anthropic (or the higher API costs of closed source models), but like the terminal experience.

## For Budget-Conscious Users

If you already have a plan but don't want to upgrade to the expensive tiers, llmoxy helps you avoid jumping from $20 to $100+ monthly subscriptions. Instead of upgrading just because you occasionally hit limits, you can use alternative models at a fraction of the cost. Not everyone needs a hundred dollar plan every month. So, llmoxy lets you handle those occasional bursty coding sessions without overspending.

## Moxxi walks with Jean-_Claude_ Van Damme

![Sorry, I couldn't resist.](https://i.justifiedgrid.com/t0bnxl.jpg)
(Looks fake because she doesn't have her hat. So, we'll call her Moxy.)

## Features

- **Model Integration**: Direct integration with Claude Code using various AI models
- **Auto-Generated Aliases**: Dynamic shortcuts automatically created from your preferred config.yaml models
- **Easy Proxy Management**: Start, stop, restart, and monitor your LiteLLM proxy
- **Container Management**: Docker-based deployment with health monitoring
- **Auto-Start**: Aliases automatically start the proxy if it's not running
- **Status Monitoring**: Real-time proxy status and model availability

## Installation

### Quick Install (Recommended)

```bash
curl -sSL https://raw.githubusercontent.com/Firsh/llmoxy/main/install.sh | bash
```

This one-liner will:
- Clone the repository to `~/llmoxy`
- Set up permissions and generate aliases
- Add aliases to your shell config
- Create `.env` file from template

### Manual Installation

1. Clone or download the llmoxy directory into your home folder
2. Make the executable file executable:
   ```bash
   chmod +x llmoxy
   ```
3. Add this line to your `~/.bashrc` or `~/.zshrc` (or run it first while trying it out):
   ```bash
   source ~/llmoxy/aliases.sh
   ```

## Prerequisites

### Required

- Docker and Docker Compose
- Claude Code CLI installed
- curl (for health checks)

That's it! No additional dependencies required - llmoxy uses only standard Unix tools (`grep`, `sed`, `curl`) that are available on all systems.

## Configuration

The system uses the following files:

- `.env` - Environment variables (API keys)
- `config.yaml` - [LiteLLM configuration](https://docs.litellm.ai/docs/proxy/config_settings) (aliases auto-generated from this)
- `docker-compose.yml` - Docker service definition
- `aliases.sh` - Auto-generated aliases with preserved custom sections

Make sure to set at least one API key in the `.env` file:

```bash
OPENROUTER_API_KEY=your_api_key_here
MOONSHOT_API_KEY=your_api_key_here
```

### Dynamic Alias Management

The `aliases.sh` file contains auto-generated sections between markers:

```bash
# BEGIN AUTO-GENERATED ALIASES
# ... auto-generated content ...
# END AUTO-GENERATED ALIASES
```

You can add custom aliases before or after these markers - they will be preserved when aliases are regenerated. If the automatic aliases cause you any conflict, then feel free to change their name using the model_name lines in config.yaml.

## Usage

### Basic Commands

```bash
llmoxy [COMMAND] [OPTIONS]
```

### Available Commands

#### Model Commands

- `--run MODEL, -m MODEL` - Start Claude Code with specific model
- `--list-models` - List all configured models

#### Proxy Management

- `--start, -s` - Start the LiteLLM proxy service
- `--stop, -x` - Stop the LiteLLM proxy service
- `--restart, -r` - Restart the LiteLLM proxy service
- `--status, -t` - Show proxy status and available models
- `--logs, -l` - Show proxy logs
- `--generate-aliases` - Generate dynamic aliases from config.yaml
- `--help, -h` - Show help message

### Examples

#### Starting or setting up the Proxy for the first time

```bash
llmoxy --start
```

#### Running Claude Code with a Model

##### Auto-Generated Model Aliases

Model aliases are automatically generated from your `config.yaml` file and become available when you source `aliases.sh`. Each model gets its own alias with auto-start functionality.

**Aliases are generated when:**

- You start the proxy (`llmoxy --start`) and config.yaml is newer than aliases.sh
- You run `llmoxy --generate-aliases` manually
- Auto-start detects config changes when using a model alias

**Current aliases** (based on your config.yaml):

- `kimi` - Runs `llmoxy --run kimi`
- `kimi-turbo` - Runs `llmoxy --run kimi-turbo`
- `dsr1` - Runs `llmoxy --run dsr1`
- `qwen` - Runs `llmoxy --run qwen`

They were designed to mimic how you start Claude (`claude`) so they are just commands in the terminal (these auto-start proxy if needed).

**Manual command equivalents:**

```bash
llmoxy --run kimi
llmoxy --run kimi-turbo
llmoxy --run dsr1
llmoxy --run qwen
```

**Note**: Aliases automatically update when you modify `config.yaml` and start the proxy or run `llmoxy --generate-aliases`.

#### Checking Status

```bash
llmoxy --status
```

#### Viewing Logs

```bash
llmoxy --logs
```

#### Proxy Management Aliases

- `llmoxy-start` - Start the proxy
- `llmoxy-stop` - Stop the proxy
- `llmoxy-restart` - Restart the proxy
- `llmoxy-status` - Check proxy status
- `llmoxy-logs` - View proxy logs
- `llmoxy-aliases` - Regenerate aliases from config.yaml

## Technical Details

### Proxy Configuration

- **Port**: 4000 (localhost:4000)
- **Container Name**: llmoxy
- **Health Check**: Automatic monitoring with retry logic
- **Restart Policy**: unless-stopped

### Environment Variables

When running Claude Code through llmoxy, the following environment variables are automatically set:

- `ANTHROPIC_AUTH_TOKEN=sk-4`
- `ANTHROPIC_BASE_URL=http://localhost:4000`
- `ANTHROPIC_MODEL=<selected_model>`

These are encapsulated into (exported inside) the command that runs Claude Code in this alternate reality, meaning that when you exit and return to normal CC, your Anthropic access (if any) will be used. While you are running through llmoxy, you will see inside Claude Code that your model is the one that you have selected. But you won't be able to change it.

## Troubleshooting

### Proxy Won't Start

1. Check if Docker is running
2. Verify your API keys in `.env`
3. Check for port conflicts on port 4000

### Models Not Available

1. Ensure the proxy is running: `llmoxy --status`
2. Check proxy logs: `llmoxy --logs`
3. Verify your API configuration in `config.yaml`

### Claude Code Connection Issues

1. Confirm proxy health: `curl http://localhost:4000/health`
2. Check if the model exists: `llmoxy --list-models`
3. Restart the proxy: `llmoxy --restart`

### Error: Streaming fallback triggered

Honestly, I don't know why this happens. I have received this message in CC when using Kimi K2 Turbo Preview. The task still finished just fine. I have a hunch that this is some kind of per minute rate limit. If anybody knows (along with a possible solution), let me know by creating an issue or PR.

## File Structure

```
llmoxy/
├── README.md           # This file
├── llmoxy              # Main executable
├── aliases.sh          # Auto-generated aliases
├── docker-compose.yml  # Docker configuration
├── config.yaml         # LiteLLM model configuration
└── .env                # Environment variables
```

## Support

For issues and questions:

1. Check the logs: `llmoxy --logs`
2. Verify configuration files
3. Ensure all prerequisites are installed
4. Check Docker container status: `docker ps`

---

_llmoxy - Making Claude Code use alternative models_
