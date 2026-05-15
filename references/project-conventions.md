# Project Conventions

## Expected App Shape

- Frontend: React + TypeScript + Vite
- Backend: Node.js + Express + TypeScript
- Database access: MongoDB driver or Mongoose
- Uploaded assets: Google Cloud Storage

## Recommended Environment Variables

```text
MONGO_URL=
SESSION_SECRET=
GCP_PROJECT_ID=
GCS_BUCKET_NAME=
SITE_URL=
NODE_ENV=
```

## Files

- `.env`: local development only, ignored by git
- `.env.example`: safe names and placeholders, committed
- `Dockerfile`: explicit container build when needed
- `README.md`: local run and deploy notes

## Repository Defaults

- Keep app code and deploy scripts in the same repo.
- Use one service name per site.
- Use `main` as the production branch unless the user already has another convention.
- Prefer explicit scripts over remembered shell history.

## App Expectations

- App should read configuration from env vars.
- Health checks should not require database mutation.
- Image uploads should return durable public URLs or signed URLs based on the app's access model.
- Local dev should work without cloud-only assumptions wherever practical.

