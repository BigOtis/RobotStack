---
name: robot-future-stack-setup
description: "Bootstrap and maintain the Robot Future-style website stack, a general-purpose setup based on how Robot Future is built rather than a stack limited to Robot Future itself: MongoDB Atlas, Node/Express + React/Vite, Google Cloud Run, Google Cloud Storage image hosting, Squarespace-managed domains, and GitHub repos. Use when Codex needs to guide a vibe-coder through one-time machine/account setup, collect missing credentials interactively, save reusable local config, create any new site using this stack, or deploy/update an existing site with minimal cloud knowledge."
---

# Robot Future Stack Setup

Use this skill to turn a reasonably technical user into a repeatable one-command deploy workflow for small websites.

## Core Workflow

1. Read `references/stack.md` for the target architecture and `references/setup-flow.md` for the operator flow.
2. Inspect the machine before changing it:
   - Run `scripts/bootstrap.ps1 -CheckOnly`.
   - Reuse existing installs and auth when present.
3. If required tools or credentials are missing, guide the user through the exact missing step only:
   - `gcloud` browser auth
   - `gh` browser auth
   - MongoDB Atlas cluster/user/connection string creation
   - Squarespace DNS setup
4. Save reusable values with `scripts/save-config.ps1`.
5. For project work, create or update the app using `references/project-conventions.md`.
6. For deploys, prefer `scripts/deploy-cloud-run.ps1` over reconstructing commands manually.
7. Before finishing, verify:
   - `gh auth status`
   - `gcloud auth list`
   - project config exists in `~/.robot-future-stack/config.json`
   - encrypted secrets exist in `~/.robot-future-stack/secrets.json` when needed
   - target service URL responds after deploy

## Operating Rules

- Assume the user understands code concepts but not cloud product details.
- Explain what each service is for in one sentence, then keep moving.
- Pause only when the user must complete browser auth, paste a secret, choose a project/domain, or approve a billing-impacting choice.
- Never ask the user to paste Google or GitHub access tokens if browser/device auth is available.
- Treat MongoDB URIs, session secrets, service-account JSON, and API keys as secrets.
- Do not commit secret-bearing files. Use local env files and user-profile config.
- Prefer cheap defaults for hobby websites:
  - Cloud Run scales to zero
  - low CPU/memory
  - one max instance unless the user needs more throughput
  - public images in Cloud Storage only when the site requires direct public access
- If the user wants a different provider or architecture, say this skill is opinionated and adapt only after confirming the deviation.

## One-Time Setup

Follow `references/setup-flow.md`.

Useful commands:

```powershell
.\scripts\bootstrap.ps1 -CheckOnly
.\scripts\bootstrap.ps1
.\scripts\save-config.ps1
```

## New Project Or Existing Project

- For a new site, use `references/project-conventions.md` as the build target.
- For an existing site, map its current repo/env vars/service names onto the same config model instead of forcing a rewrite.
- If the repo is not on GitHub yet, use `gh repo create` after confirming public/private visibility.

## Deploy Or Update

Use:

```powershell
.\scripts\deploy-cloud-run.ps1 -ProjectId <project-id> -ServiceName <service-name> -Region <region>
```

If config already exists, the script can infer omitted values.

## Claude Compatibility

Codex skills are not Claude Code skills. To emulate the same behavior in Claude Code, copy:

- `assets/claude/CLAUDE.md`
- `assets/claude/commands/robot-future-stack-setup.md`

See `references/claude-bridge.md` for placement and expectations.

## Reference Map

- `references/stack.md`: what the stack is and why each piece exists
- `references/setup-flow.md`: the full guided onboarding sequence
- `references/project-conventions.md`: env vars, folders, and app expectations
- `references/cloud-run-cheap.md`: low-cost Cloud Run defaults
- `references/claude-bridge.md`: how to mirror the workflow in Claude Code
