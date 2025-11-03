# CI/CD

Workflows:
- **ci_pr.yml** — Runs on Pull Requests. Lints SQL, `dbt deps/seed/build`, uploads artifacts (docs, run_results, DQ report).
- **release_prod.yml** — Manual promotion to PROD target.
- **docs_pages.yml** — Publishes `dbt docs` to GitHub Pages.

Secrets required:
- `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_USER`, `SNOWFLAKE_PASSWORD`.

Local profiles template: `profiles.yml.example`.  
Lint rules: `sqlfluff.cfg`. Pre-commit hook: `pre-commit-config.yaml`.
