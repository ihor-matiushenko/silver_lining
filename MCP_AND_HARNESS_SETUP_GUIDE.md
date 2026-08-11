# 🔌 MCP Servers & Agentic Harness Configuration Guide

This guide explains how to set up **Model Context Protocol (MCP)** servers for GitHub and Figma, and how our **Agentic Harness** uses custom subagents to automate development tasks.

---

## 🛰️ 1. What is MCP (Model Context Protocol)?

MCP is an open standard that allows AI assistants (like Antigravity) to communicate directly with your external developer tools:
- **GitHub MCP**: Auto-creates branches, commits code, opens PRs, and tracks issues.
- **Figma MCP**: Inspects design frames, reads design tokens (colors/typography), and generates Flutter UI code automatically.

---

## 🐙 2. GitHub MCP Server Configuration

### Prerequisites
1. Create a GitHub Personal Access Token (Classic or Fine-Grained) with `repo` scope at [GitHub Token Settings](https://github.com/settings/tokens).
2. Copy your token (e.g. `ghp_xxxxxxxxxxxxxxxxxxxx`).

### Configuration
Add the following block to your MCP configuration file (`.agents/mcp_config.json` or `~/.gemini/config/mcp_config.json`):

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-github"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR_GITHUB_TOKEN_HERE"
      }
    }
  }
}
```

---

## 🎨 3. Figma MCP Server Configuration

### Prerequisites
1. Generate a Figma Personal Access Token in **Figma Settings $\rightarrow$ Personal Access Tokens**.
2. Copy your token (e.g. `figd_xxxxxxxxxxxxxxxxxxxx`).

### Configuration
Add the Figma server to your MCP configuration file:

```json
{
  "mcpServers": {
    "figma": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-figma"
      ],
      "env": {
        "FIGMA_PERSONAL_ACCESS_TOKEN": "YOUR_FIGMA_TOKEN_HERE"
      }
    }
  }
}
```

---

## 🤖 4. Custom Agentic Harness & Subagents

We equip our development workspace with 3 specialized subagent roles:

| Subagent Name | Role & Responsibility | Primary Tools Used |
|---|---|---|
| `safety-auditor` | Evaluates prompt safety, runs red-teaming test suites against guardrails, and asserts zero unsafe responses. | Pytest, Safety JSON Red-Team Suite |
| `mobile-ui-builder` | Constructs Flutter widgets, themes, BLoC state management, and animations matching design specs. | Flutter CLI, Dart Analyzer |
| `backend-engineer` | Implements FastAPI routes, Pydantic models, LLM service wrappers, and database models. | Python, FastAPI, Docker |

---

## 🎯 Next Steps

1. To configure GitHub MCP, generate a GitHub token and we can add it to your project's `.agents/mcp_config.json`.
2. To configure Figma MCP, generate a Figma token whenever you're ready to bridge Figma files.
3. Otherwise, we can initialize our **Python + FastAPI Backend Codebase** inside `/Users/ihormatiushenko/Workspace/silver_lining/backend` right now!
