# 02 — Business Context

This folder captures the **why** behind the warehouse: core processes, KPIs, and the mapping from questions → facts/dimensions.

## Contents
- `business_processes/` — narrative for each process
- `qnf/` — QNF cards (Questions & Facts) grouped by themes
- `bus_matrix.md` — Star Bus Matrix (subject areas × conformed dimensions)

## How to read this folder
1) Start with `business_processes/` to understand the flows.
2) Open `qnf/` to see each analytic question as a concise spec.
3) Use `bus_matrix.md` to see conformed dimensions shared across facts.

## KPI Glossary (short)
- **Net Revenue (ex-VAT):** `gross_amount - vat_amount`
- **AOV:** `revenue_ex_vat / orders`
- **Active Customer:** ≥1 order in the period
- **Repeat Purchase Rate:** `repeat_customers / customers`
- **Store Performance Index:** composite of revenue, margin, traffic