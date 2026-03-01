# project-template-collab

Template for collaborative multi-developer projects using Claude Code.

Combines **PAUL** (Plan-Apply-Unify Loop) for structured execution with handoffs,
**Compound Engineering** for multi-agent reviews, and **CARL** for dynamic context management.
Includes a **DevContainer** so every dev gets an identical, isolated environment out of the box.

## Stack

| Tool | Role |
|------|------|
| [PAUL](https://github.com/christopherKahler/paul) | Structured dev methodology with mandatory closure + handoff |
| [Compound Engineering](https://github.com/EveryInc/compound-engineering-plugin) | 29 review agents, 19 skills, flywheel |
| [CARL](https://github.com/christopherKahler/carl) | Dynamic rule injection by keywords |
| [DevContainer](https://containers.dev/) | Isolated, reproducible dev environment via Docker |

---

## Quick Start (new dev)

### Prerequisites

Install these **once** on your machine:

1. **Docker Desktop** — [download](https://www.docker.com/products/docker-desktop/)
   - Make sure Docker is **running** before proceeding
2. **VSCode** — [download](https://code.visualstudio.com/)
3. **Dev Containers extension** for VSCode
   - Open VSCode → Extensions (Cmd+Shift+X / Ctrl+Shift+X)
   - Search **"Dev Containers"** → Install the one by **Microsoft**
   - Extension ID: `ms-vscode-remote.remote-containers`
   - [Marketplace link](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
4. **Claude subscription** (Pro or Max) — each dev uses their own account

### Step 1 — Clone this template

```bash
git clone https://github.com/gerardloupecyb/claude-code-project-template-collab.git
cd claude-code-project-template-collab
code .
```

### Step 2 — Open in DevContainer

When VSCode opens, you'll see a notification:
> "Folder contains a Dev Container configuration file. Reopen folder to develop in a container?"

Click **"Reopen in Container"**.

(If you miss the notification: `Cmd+Shift+P` → "Dev Containers: Reopen in Container")

First build takes a few minutes (installs Node 20, Claude Code, PAUL, CARL, zsh).
Subsequent opens are instant.

### Step 3 — Authenticate Claude Code

In the VSCode terminal inside the container:

```bash
claude --version    # verify Claude Code is installed
claude login        # authenticate with your Claude subscription
```

> **Note:** If you've already logged in on your machine, the session is shared
> via the `~/.claude` mount and you may already be authenticated.

### Step 4 — Create your project

```bash
./init-project.sh "My Project" myprojectworkflow "keyword1,keyword2" "alice,bob"
```

| Argument | Description | Example |
|----------|-------------|---------|
| 1st | Project name (display name) | `"My SaaS"` |
| 2nd | CARL domain (lowercase, no dashes) | `saasworkflow` |
| 3rd | CARL keywords (comma-separated) | `"saas,api,stripe"` |
| 4th | Dev names (comma-separated) | `"alice,bob"` or `"alice,bob,charlie"` |

This creates the full project structure in the parent directory.

### Step 5 — Open your project

```bash
code "../My Project"
```

VSCode opens the generated project → **"Reopen in Container"** again.
The project has its own `.devcontainer/` — each dev gets an identical environment.

### Step 6 — Start working

```bash
# Each dev creates their branch
git init
git add -A
git commit -m "Initial project setup"
git checkout -b phase-1-alice    # alice's branch
```

Then use the PAUL workflow:
```
/paul:plan    → plan the phase
/pre-flight   → review the plan (4 agents in parallel)
/paul:apply   → execute
/paul:unify   → close and capitalize
```

---

## What gets created

```
{Project}/
├── CLAUDE.md                          # Team rules, workflow, flywheel
├── .claude/skills/
│   ├── context-manager-team/          # Multi-dev memory management
│   ├── pre-flight/                    # 4-agent plan review before execution
│   └── team-sync/                     # Team coordination + conflict detection
├── .carl/
│   ├── manifest                       # Domain registry
│   └── {domain}                       # Project-specific rules
├── .paul/                             # PAUL framework state
│   └── phases/
├── memory/
│   ├── MEMORY-shared.md               # Team decisions, architecture
│   ├── MEMORY-alice.md                # Dev 1 session state
│   └── MEMORY-bob.md                  # Dev 2 session state
├── handoffs/                          # PAUL handoff files
├── .devcontainer/                     # Docker dev environment (identical for all devs)
├── docs/solutions/                    # Flywheel knowledge base
└── src/
```

---

## 3 Collaboration Modes

### Mode 1 — Parallel phases

Each dev works on a different phase on their own branch (`phase-{N}-{dev}`).
Independent MEMORY files, independent pre-flight, merge via PR.

```
Dev A (phase 3)                    Dev B (phase 4)
─────────────                      ─────────────
/paul:plan 03                      /paul:plan 04
/pre-flight                        /pre-flight
/paul:apply                        /paul:apply
/paul:unify                        /paul:unify
→ merge via PR                     → merge via PR
```

### Mode 2 — Same feature

Shared plan, tasks split between devs. Feature branches per dev
(`feat/{feature}-{dev}`). Compound review on the merge.

```
Dev A (tasks 1-3)                  Dev B (tasks 4-6)
─────────────                      ─────────────
/paul:plan (shared)                Reads same plan
/paul:apply (tasks 1-3)           /paul:apply (tasks 4-6)
→ merge branches                   → merge branches
/workflows:review (together)
```

### Mode 3 — Sequential handoff

Dev A works, runs `/paul:unify`, then `/paul:handoff`.
Dev B reads the handoff file and continues. **Never handoff without unify first.**

```
Dev A                              Dev B
─────                              ─────
/paul:apply
/paul:unify (MANDATORY)
/paul:handoff
→ handoffs/{date}.md               Reads handoff + MEMORY-shared
                                   Continues work
                                   /paul:unify when done
```

---

## DevContainer details

The `.devcontainer/` provides:

| Component | What's included |
|-----------|----------------|
| Base image | Node 20 (Debian Bookworm), zsh + oh-my-zsh |
| Pre-installed tools | Claude Code, PAUL, CARL, git, gh CLI, jq, fzf |
| VSCode extensions | Claude Code, GitGraph, GitLens |
| Mounts | `~/.claude` (auth) and `~/.mcp.json` (MCP configs) from host |
| Firewall | Whitelist-based (Claude API, npm, GitHub, Supermemory, Context7) |
| User | Non-root (`developer`), sudo without password |

**Authentication:** Each dev uses their own Claude subscription (Pro or Max).
Auth is handled via `claude login` — no API keys needed. The `~/.claude` directory
is mounted from the host, so if you're already logged in on your machine, it just works.

---

## Skills included

| Skill | Purpose |
|-------|---------|
| `context-manager-team` | Reads MEMORY-shared + MEMORY-{dev} at session start, manages checkpoints and handoff protocols |
| `pre-flight` | Launches 4 review agents in parallel (architecture, security, performance, spec-flow) against a plan before execution |
| `team-sync` | Shows team status, detects conflicts (2 devs on same phase), facilitates handoffs |

---

## Related

- [project-template-v2](https://github.com/gerardloupecyb/claude-code-project-template-v2) — Solo dev template (GSD + Compound + CARL)
