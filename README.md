# project-template-collab

Template for collaborative multi-developer projects using Claude Code.

Combines **PAUL** (Plan-Apply-Unify Loop) for structured execution with handoffs,
**Compound Engineering** for multi-agent reviews, and **CARL** for dynamic context management.

## Stack

| Tool | Role |
|------|------|
| [PAUL](https://github.com/christopherKahler/paul) | Structured dev methodology with mandatory closure + handoff |
| [Compound Engineering](https://github.com/EveryInc/compound-engineering-plugin) | 29 review agents, 19 skills, flywheel |
| [CARL](https://github.com/christopherKahler/carl) | Dynamic rule injection by keywords |
| DevContainer | Isolated, reproducible dev environment |

## Usage

```bash
./init-project.sh "My Project" myprojectworkflow "keyword1,keyword2" "alice,bob"
```

Arguments:
1. Project name
2. CARL domain name (lowercase, no dashes)
3. CARL keywords (comma-separated)
4. Dev names (comma-separated)

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
├── .devcontainer/                     # Docker dev environment
├── docs/solutions/                    # Flywheel knowledge base
└── src/
```

## 3 Collaboration Modes

### Mode 1 — Parallel phases
Each dev works on a different phase on their own branch (`phase-{N}-{dev}`).
Independent MEMORY files, independent pre-flight, merge via PR.

### Mode 2 — Same feature
Shared plan, tasks split between devs. Feature branches per dev
(`feat/{feature}-{dev}`). Compound review on the merge.

### Mode 3 — Sequential handoff
Dev A works, runs `/paul:unify`, then `/paul:handoff`.
Dev B reads the handoff file and continues. Never handoff without unify first.

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- [PAUL framework](https://github.com/christopherKahler/paul)
- [Compound Engineering plugin](https://github.com/EveryInc/compound-engineering-plugin)
- [CARL](https://github.com/christopherKahler/carl)
- Docker (optional, for devcontainer)

## Related

- [project-template-v2](https://github.com/gerardloupecyb/claude-code-project-template-v2) — Solo dev template (GSD + Compound + CARL)
