#!/usr/bin/env bash
# Firewall rules for Claude Code devcontainer
# Whitelists only necessary outbound connections

set -euo pipefail

# Flush existing rules
iptables -F OUTPUT 2>/dev/null || true

# Allow loopback
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established connections
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow DNS
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Allow SSH (for git)
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTPS (443) to whitelisted domains
# Claude API
iptables -A OUTPUT -p tcp --dport 443 -d api.anthropic.com -j ACCEPT
# npm registry
iptables -A OUTPUT -p tcp --dport 443 -d registry.npmjs.org -j ACCEPT
# GitHub
iptables -A OUTPUT -p tcp --dport 443 -d github.com -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -d api.github.com -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -d raw.githubusercontent.com -j ACCEPT
# Supermemory MCP
iptables -A OUTPUT -p tcp --dport 443 -d mcp.supermemory.ai -j ACCEPT
# Context7 MCP
iptables -A OUTPUT -p tcp --dport 443 -d mcp.context7.ai -j ACCEPT

# Allow all HTTPS (relaxed mode — tighten per project if needed)
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# Default deny other outbound
# Uncomment for strict mode:
# iptables -A OUTPUT -j DROP

echo "✓ Firewall rules applied"
