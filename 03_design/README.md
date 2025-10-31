# 03_design

This folder holds all data-model design artifacts **before implementation**.

## Contents
- `grain_cards/` — authoritative specs for each fact table (grain, keys, SCD, DQ)
- `star_schemas/` — conceptual → logical → physical models (+ notes)
- `s2t_mapping/` — Source-to-Target maps (RAW→STG→CORE)

## Design → Build handoff
1) Confirm **grain** of each fact (one line per grain card).
2) Finalize **bus matrix** (in `02_business/bus_matrix.md`) aligns with logical model.
3) Freeze **column names & types** for RAW→STG casts (see 05_dbt_project).