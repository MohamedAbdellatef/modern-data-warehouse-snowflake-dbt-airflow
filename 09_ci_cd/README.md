# CI/CD for GulfMart Warehouse

## GitHub Actions

Main pipeline: `.github/workflows/dbt_ci.yml`

- Triggers on `push` and `pull_request` to `main`.
- Uses `.dbt/profiles.yml` with Snowflake credentials from GitHub Actions secrets.
- Steps:
  1. Install Python + dependencies (`requirements.txt`).
  2. `dbt parse` to validate project.
  3. `dbt build --target dev --fail-fast` to run models + tests.

## Pre-commit

Config: `.pre-commit-config.yaml`

- Basic hygiene: trailing whitespace, EOF fixer, YAML/JSON checks.
- `sqlfluff` for Snowflake SQL style and linting.

Usage:

```bash
pip install pre-commit sqlfluff sqlfluff-templater-dbt
pre-commit install
pre-commit run --all-files
