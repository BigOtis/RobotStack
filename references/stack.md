# Stack

## Target Architecture

- GitHub: source repository, remote collaboration, and deploy source of truth
- MongoDB Atlas: primary document database for site data
- Node.js + Express + React + Vite: default web app shape
- Google Cloud Run: containerized app hosting
- Google Cloud Storage: uploaded image hosting
- Squarespace Domains: registrar and DNS control plane

## Why These Choices

- Keep the database flexible while the product is changing quickly.
- Keep compute serverless so idle hobby sites do not pay for idle servers.
- Keep binary assets out of the database.
- Keep domains separate from runtime hosting.
- Keep code in the place where AI coding agents already work well.

## Default Resource Model

- One Google Cloud project per site or closely related group of sites
- One Cloud Run service per web app
- One Cloud Storage bucket per app or shared brand image bucket
- One MongoDB Atlas project/cluster for app data
- One GitHub repository per app

## Security Posture

- Use browser-based CLI authentication where possible.
- Store secrets in local env files or managed cloud secret stores, never in git.
- Use least-privilege IAM for buckets and services.
- Treat public image buckets as intentionally public, not accidentally public.

