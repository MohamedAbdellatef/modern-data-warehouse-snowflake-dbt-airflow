# 03_design

This folder holds all data-model design artifacts **before implementation**.

## Contents
- `conceptual_model.png` – business entities, no keys.
- `logical_model.png` – star schemas (facts + dims + relationships).
- `physical_model.png` – Snowflake physical columns, datatypes, PK/FK notes.
- `physical_model_notes.md` – decisions: SCD types, surrogate keys, null rules, VAT/FX logic.

## Design → Build handoff
1) Confirm **grain** of each fact (one line per grain card).
2) Finalize **bus matrix** (in `02_business/bus_matrix.md`) aligns with logical model.
3) Freeze **column names & types** for RAW→STG casts (see 05_dbt_project).