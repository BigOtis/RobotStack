# Robot Future Stack Setup

A reusable Codex skill and Claude Code companion pack for bootstrapping small websites with the stack used by Robot Future:

- GitHub for source control
- MongoDB Atlas for app data by default
- Google Cloud Run for web hosting
- Google Cloud Storage for image hosting
- Squarespace Domains for domain ownership and DNS

This is not only for Robot Future projects. It is a general-purpose website setup based on the Robot Future stack, aimed at capable builders who can work on an app but do not want to learn every cloud product in depth before they can ship. MongoDB is the reference default, not a requirement; if your app already uses PostgreSQL or another healthy architecture, the workflow should adapt to that instead of forcing a rewrite.

## What It Does

- Checks whether `git`, `gh`, `gcloud`, `node`, and `npm` are installed
- Walks the user through one-time account and CLI setup
- Pauses only when human input is actually needed, such as browser auth or secret entry
- Stores reusable local stack settings for later deploys
- Encodes cheap Cloud Run defaults for low-traffic sites
- Includes the Robot Future Dockerfile as a known-good example and explains when to adapt it
- Reconciles Cloud Run env vars, Secret Manager bindings, readiness, and live health checks during deploy
- Provides a repeatable deploy helper so later updates are routine

## Package Layout

```text
.
|-- SKILL.md
|-- agents/
|-- assets/
|   |-- .env.example
|   `-- claude/
|       |-- CLAUDE.md
|       `-- commands/robot-future-stack-setup.md
|-- references/
`-- scripts/
```

## Codex Usage

Install or copy this folder into your Codex skills directory, then invoke:

```text
$robot-future-stack-setup
```

The main skill file is [SKILL.md](./SKILL.md).

## Claude Code Usage

Claude Code does not consume Codex `SKILL.md` packages directly. To emulate the same workflow:

1. Copy `assets/claude/CLAUDE.md` into your repo root, or import it from your existing project `CLAUDE.md`.
2. Copy `assets/claude/commands/robot-future-stack-setup.md` into `.claude/commands/`.
3. Run:

```text
/robot-future-stack-setup
```

## Helper Scripts

Check local prerequisites:

```powershell
.\scripts\bootstrap.ps1 -CheckOnly
```

Save reusable settings:

```powershell
.\scripts\save-config.ps1
```

Deploy a site:

```powershell
.\scripts\deploy-cloud-run.ps1 -ProjectId <project-id> -ServiceName <service-name> -Region <region>
```

When `deploy/cloud-run.json` exists, the deploy helper also:

- syncs Secret Manager values from locally encrypted secrets
- binds those secrets into Cloud Run
- applies non-secret env vars
- waits for the Cloud Run service to become ready
- checks the configured health path

## Local State

The workflow stores reusable local settings under:

```text
~/.robot-future-stack/config.json
~/.robot-future-stack/secrets.json
```

Do not commit project secrets. Use `.env` locally and keep safe placeholders in `.env.example`.

For deployed services, use a checked-in `deploy/cloud-run.json` manifest for non-secret env vars, secret bindings, and the health path. A sample lives at `assets/cloud-run.example.json`.

## Intended User

This is for "vibe coder" through mid-level developers:

- comfortable editing code
- comfortable following prompts
- not interested in becoming a cloud specialist just to launch a small site

## Notes

- The defaults are opinionated, not universal.
- Cloud Run is configured for low-cost hobby-site behavior first.
- The deployment workflow is opinionated, but the application architecture should bend around working projects rather than replacing them.
