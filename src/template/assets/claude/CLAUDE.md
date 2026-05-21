# Robot Stack Memory

- Use GitHub for the code repository.
- Use MongoDB Atlas for application data.
- Use Google Cloud Run for web app hosting.
- Use Google Cloud Storage for uploaded images.
- Use Squarespace Domains for domain ownership and DNS.
- Prefer low-cost Cloud Run defaults for small websites: scale to zero, one max instance unless throughput requires more.
- Treat MongoDB URIs, session secrets, and API keys as secrets; never commit them.
- Store ordinary stack settings in `~/.robot-stack/config.json` and secrets in `~/.robot-stack/secrets.json`.
- Prefer browser-based authentication for `gh` and `gcloud`.
- Before deploying, reuse saved values from `~/.robot-stack/config.json` when available.
- When the user asks for setup help, explain each service briefly, then guide only the missing steps.
