# Claude Comm Plugins

Communication and collaboration tools for Claude Code multi-agent workflows.

## Overview

This repository contains a collection of Claude Code plugins designed to enhance multi-agent communication and collaboration across repositories. Each plugin is independently installable and addresses specific aspects of cross-agent workflows.

## Installation

### Add marketplace

```bash
claude plugin marketplace add https://github.com/j4c0bs/claude-comm-plugins.git
```

### Install individual plugin

**CLI:**

```bash
claude plugin install intercom@claude-comm-plugins
```

**In claude code:**

```bash
/plugin
```


### Verify Installation

```bash
# In claude code
/plugin
```

## Available Plugins

### 🔌 [Intercom](./plugins/intercom/)

**Category**: Productivity
**Version**: 1.0.0

Enable Claude Code agents in separate repositories to communicate via CLI invocation. Bypasses the `--add-dir` limitation by invoking Claude Code directly in target repositories.

**Features**:
- Cross-repository agent communication
- Automatic session state management
- Cost-efficient multi-turn conversations (92% savings via prompt caching)
- Flexible storage: temporary or project-local
- Autonomous skill activation + manual `/intercom` command

**Installation**:
```bash
claude plugin install intercom@claude-comm-plugins
```

[Full Documentation →](./plugins/intercom/README.md)

---

### 🎤 [Voice Updates](./plugins/voice-updates/)

**Category**: Productivity
**Version**: 1.0.0
**Platform**: macOS

Provide voice updates during tasks using macOS `say` command for proactive communication. Enables voice notifications for progress, findings, and attention requests without blocking execution.

**Features**:
- Proactive voice updates during work
- Intelligent voice selection (respects preferences + context)
- Notable moments only (not routine operations)
- Non-blocking background execution
- Natural language messages designed for speech
- Context-aware voice selection (progress/emphasis/attention)

**Installation**:
```bash
claude plugin install voice-updates@claude-comm-plugins
```

[Full Documentation →](./plugins/voice-updates/README.md)

---

## Repository Structure

```
claude-comm-plugins/
├── .claude-plugin/
│   └── marketplace.json         # Marketplace configuration
├── plugins/
│   ├── intercom/                # Intercom plugin
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── skills/
│   │   ├── commands/
│   │   └── README.md
│   └── voice-updates/           # Voice Updates plugin
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── skills/
│       └── README.md
├── README.md                    # This file
└── .gitignore
```

### Plugin Requirements

Each plugin must:
- Follow Claude Code plugin conventions
- Include `.claude-plugin/plugin.json` manifest
- Provide comprehensive documentation in README.md
- Use kebab-case naming
- Include clear usage examples

## Support

- **Issues**: [Report bugs or request features](https://github.com/j4c0bs/claude-comm-plugins/issues)
- **Documentation**: See individual plugin READMEs
- **Questions**: Open a discussion in the repository

## License

MIT

## Acknowledgments

Built for the Claude Code community. Special thanks to the Anthropic team for creating Claude Code and the plugin system.

---

**Repository Version**: 1.0.0
**Owner**: Jeremy Jacobs
**Last Updated**: 2025-11-30
