# Better Bar Crawl App Backend

Imported from `openapi.yaml`.

These are the super cool and fancy API docs for the backend. The main thing to understand here is the auth flow. A client logs in by making a call to /api/auth/login/ using HTTP basic authentication. This will respond with a token to be used for all protected endpoints.

Version: 0.2.0

## Servers
A separate `.env` file is generated for each server.

- http://127.0.0.1:8000 (Local Django dev server)

Environment variables are stored in the following files:
- `127_0_0_1_8000.env`

To load an environment run `posting` with the `--env` option, passing the path of the file.