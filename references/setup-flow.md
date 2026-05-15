# Setup Flow

## 1. Explain The Stack

Give the user one sentence per service:

- GitHub holds the code.
- MongoDB is Robot Future's default app database, but an existing database such as PostgreSQL can stay in place.
- Cloud Run hosts the app.
- Cloud Storage hosts images.
- Squarespace owns the domain and DNS.

## 2. Check The Machine

Run:

```powershell
.\scripts\bootstrap.ps1 -CheckOnly
```

Look for:

- `git`
- `gh`
- `gcloud`
- `node`
- `npm`

If a tool is missing, install only the missing tool. On Windows, prefer `winget` when available.

## 3. Authenticate CLIs

### GitHub

Run:

```powershell
gh auth status
```

If unauthenticated:

```powershell
gh auth login --web
```

Pause until the user completes browser auth.

### Google Cloud

Run:

```powershell
gcloud auth list
```

If unauthenticated:

```powershell
gcloud init
gcloud auth application-default login
```

Pause during browser auth.

## 4. Collect Reusable Values

Ask for only values that are missing:

- Google Cloud project ID
- default region
- Cloud Run service name
- image bucket name
- GitHub owner/repo
- database connection string or existing database configuration
- default domain

Use:

```powershell
.\scripts\save-config.ps1
```

Save to:

```text
~/.robot-future-stack/config.json
~/.robot-future-stack/secrets.json
```

## 5. Create Cloud Resources

For a new stack:

```powershell
gcloud config set project <project-id>
gcloud services enable run.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com storage.googleapis.com
gcloud storage buckets create gs://<bucket-name> --location=<region>
```

If the app serves public images directly, configure public access deliberately after explaining the tradeoff.

## 6. Create Or Connect The Database

- If the project already has a working database, keep it unless the user wants to migrate.
- If the user wants the Robot Future default and has no Atlas account, direct them to create one and a free/low-cost cluster.
- Ask them to create an application database user.
- Ask them to copy the driver connection string.
- Remind them to URL-encode special characters in usernames/passwords if needed.
- Save the final URI locally; do not paste it into chat transcripts more than necessary.

## 7. Prepare The Repo

- If no repo exists, initialize git and create one with `gh repo create`.
- If a repo exists, reuse it.
- Ensure `.gitignore` excludes `.env`, `.env.*`, and any local credential files.

## 8. Prepare DNS

- If Squarespace manages the domain, leave registration there.
- Add or update the DNS records required by the chosen hosting target.
- Remind the user DNS can take up to 24-48 hours to settle.

## 9. Deploy

Before deploy, inspect whether the project already has a valid container build. If it needs a Dockerfile, read `deployment.md` and create the smallest Dockerfile that fits the existing runtime. Use the Robot Future Node Dockerfile only when it matches the app.

Run:

```powershell
.\scripts\deploy-cloud-run.ps1
```

Then verify:

- service URL
- expected env vars
- homepage HTTP response
- image upload path if applicable
