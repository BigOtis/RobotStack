# Deployment

## Container Strategy

Robot Future deploys to Cloud Run with a conventional application `Dockerfile`, not a container that bundles the Google Cloud CLI.

Use the local `gcloud` CLI on the developer machine or CI runner to deploy the app container. Do not install `gcloud` inside the application image unless the running application itself has a real runtime need for it.

## Robot Future Dockerfile Pattern

Robot Future currently uses this shape:

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

## When To Use This Pattern

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
