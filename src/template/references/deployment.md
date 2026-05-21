# Deployment

## Container Strategy

Robot Future deploys to Cloud Run with a conventional application `Dockerfile`, not a container that bundles the Google Cloud CLI.

Use the local `gcloud` CLI on the developer machine or CI runner to deploy the app container. Do not install `gcloud` inside the application image unless the running application itself has a real runtime need for it.

## Robot Future Dockerfile Example

Robot Future currently uses this working example:

```dockerfile
FROM node:18-slim

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build
RUN rm -f dist/vite.config.js
RUN npm prune --omit=dev

ENV PORT=8080
ENV NODE_ENV=production

EXPOSE 8080
CMD ["node", "dist/server/index.js"]
```

This is a sample that is known to work with Cloud Run for the Robot Future app. Use it to explain what a valid Cloud Run-oriented Dockerfile looks like, not as a template that every project must copy.

## When To Use A Similar Pattern

Use this pattern when the app is:

- Node-based
- built before runtime
- started with a production server entrypoint
- compatible with Cloud Run's `PORT` contract

## Adaptation Rules

- Preserve the user's framework and build chain when practical.
- If they use PostgreSQL instead of MongoDB, keep PostgreSQL and change env vars/configuration rather than redesigning persistence.
- If they use Python, Go, Next.js, Remix, Rails, or another runtime, generate the smallest correct Dockerfile for that runtime instead of converting the app to Node.
- Keep Cloud Run requirements stable across stacks:
  - listen on `PORT`
  - bind to `0.0.0.0`
  - produce one runnable container
  - inject secrets through env vars or secret management, not image contents

## Cloud Run Deployment

Prefer:

```powershell
.\scripts\deploy-cloud-run.ps1
```

That script handles the Cloud Run deployment path. The `Dockerfile` describes how to build the app image; the host-side `gcloud` CLI performs the deployment.

## Deployment Manifest

Before deploy, create or update `deploy/cloud-run.json` in the target app:

```json
{
  "envVars": {
    "NODE_ENV": "production",
    "SITE_URL": "https://example.com",
    "GCP_PROJECT_ID": "example-project",
    "GCS_BUCKET_NAME": "example-images"
  },
  "secrets": [
    {
      "envVar": "MONGO_URL",
      "secretName": "example-site-mongo-url",
      "localSecretKey": "mongoUrl",
      "version": "latest"
    }
  ],
  "healthPath": "/"
}
```

Rules:

- Put non-sensitive config in `envVars`.
- Put secret values in Secret Manager and bind them through `secrets`.
- Reuse the app's real variable names. For a PostgreSQL app, `DATABASE_URL` may replace `MONGO_URL`.
- Keep `healthPath` pointed at a route that proves the service is serving traffic without mutating data.

## Full Deployment Checklist

1. Inspect the app for required runtime env vars.
2. Classify each value as normal config or secret.
3. Ensure non-secret env vars appear in `deploy/cloud-run.json`.
4. Ensure secret bindings appear in `deploy/cloud-run.json`.
5. Ensure the underlying Secret Manager secrets exist before deploy.
6. Deploy the service.
7. Verify the service reaches `Ready=True`.
8. Fetch the service URL and check the health path.
9. If deploy fails, inspect Cloud Run logs and verify the container listens on `PORT` and `0.0.0.0`.

`scripts/deploy-cloud-run.ps1` handles these steps from the manifest. By default it grants the runtime service account access to each referenced secret before deploying.
