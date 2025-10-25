# QNF: R5 — Refund Rate & Refund Amount (Monthly) — v1.3

**Business Question**: 
What are the **refund amount** and **refund rate** per **calendar month** by **store** and **channel**?
**Owner / Decision**: Operations & Finance — payment performance, policy tuning.

---

## Metric (definitions)

* **Refund_Amount_AED** = `Σ( refund_amount_native × FX_to_AED at refund_local_date )`
  *Where refund events are successful* (`payment_type='Refund' AND payment_status='Completed'`).
* **Captured_Amt_AED** = `Σ( captured_amount_native × FX_to_AED at capture_local_date )`
  *Where capture events are successful* (`payment_type='Capture' AND payment_status='Completed'`).
* **Refund_Rate** = `Refund_Amount_AED / Captured_Amt_AED`

> **Scope**: Cash basis (payment events), **gross amounts** returned/collected.
> (If Finance needs ex-VAT refund KPIs, define an **R5-NET** variant explicitly.)

---

## Population

* **Numerator**: **Refund** payment events (successful).
* **Denominator**: **Capture** payment events (successful).
* **Cap rule (business guardrail)**: cumulative **refunds per order ≤ cumulative captures per order** (flag if violated).
* **Include** POS + e-commerce; **Exclude** `Test`, `Internal`.
* **Chargebacks**: treat **separately** (not counted here) unless Finance requests inclusion.

---

## Time Grain & Anchor

* **Grain**: **Calendar month**.
* **Anchors**:

  * Numerator uses **refund_local_ts** (event time).
  * Denominator uses **capture_local_ts** (event time).

> This is an **in-month refund rate** (refunds and captures in the same calendar month).
> If Finance prefers **cohort rate** (refunds for orders captured in that month, regardless of when the refund occurs), define **R5b** separately.

---

## Timezone & Boundary Policy

* Bucket by **store’s local timezone** (UAE → `Asia/Dubai`, KSA → `Asia/Riyadh`).
* Period boundary = **00:00 local** on the 1st.
* HQ roll-ups displayed in **Asia/Riyadh**.

---

## Breakdowns (Primary)

* **Store** (Store → City → Country)
* **Channel** (POS / Web / Marketplace)

**Optional**: Payment Method (Card, Cash, Wallet, BNPL, GiftCard)

---

## Currency / FX

* Facts kept in native currency (AED/SAR).
* AED consolidation uses **daily FX at event date** (refund vs capture use their **own** dates).
* **Freeze FX** at **T+2** for the closed month.

---

## Filters (In / Out)

* **In**: `payment_status='Completed' AND payment_type IN ('Capture','Refund')`.
* **Out**: `order_flag IN ('Test','Internal')`; voids/pre-auth holds; chargebacks (unless defined otherwise).

---

## Related Dimensions

* `dim_store` (country, currency, timezone), `dim_channel`, `dim_payment_method`, `dim_date` (roles: **capture_date**, **refund_date**).

---

## SLA / Freeze

* Freshness **T+1 by 06:00 Asia/Riyadh (03:00 UTC)**.
* Month **locks at T+2** (values & FX frozen).

---

## Acceptance Example

Month = **2025-10**, Riyadh Gallery, Channel=POS:
Captured_Amt_AED = **10,000**; Refund_Amount_AED = **800** → **Refund_Rate = 8%**.

---

## Assumptions / Notes

* E-commerce mapped to **ONLINE_UAE / ONLINE_KSA** virtual stores.
* Multiple partial refunds per order are summed; **cap rule** enforced via DQ alert.
* Chargebacks are tracked separately (R6?) unless Finance merges them into refunds.

---

## Data Source / Implementation Notes

* **Fact**: `core.fact_payment` (one row per payment event).
* **Derivations**: compute **local timestamps** by store timezone; convert each event to AED using **event-date FX**; aggregate to month.

---