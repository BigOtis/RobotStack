# Claude Bridge

Claude Code does not use Codex `SKILL.md` folders directly.

To emulate the same workflow:

1. Copy `assets/claude/CLAUDE.md` into the target repo root, or import it from the repo root `CLAUDE.md`.
2. Copy `assets/claude/commands/robot-future-stack-setup.md` into `.claude/commands/`.
3. Invoke the command in Claude Code with:

```text
/robot-future-stack-setup
```

Use `CLAUDE.md` for durable project memory and the custom slash command for the repeatable setup flow.

