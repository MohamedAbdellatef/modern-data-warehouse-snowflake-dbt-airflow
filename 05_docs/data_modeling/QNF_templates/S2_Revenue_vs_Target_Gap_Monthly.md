# 🟢 QNF: S2 — Revenue vs Target Gap (Monthly) 

**QNF-ID**: S2-Revenue-vs-Target-Gap-Monthly
**Business Question**
How much revenue (in AED) is each store **above or below target** for the given month? Show both **absolute variance (AED)** and **percentage variance**.

**Owner / Decision**
Finance Business Partnering & Retail Ops — monthly P&L review, corrective actions.

---

## Metric (definitions)

* **Actual_Revenue_AED**
  `Σ (order_net_native × FX_to_AED at order_local_date)` with the **same returns policy as S1** (pick **R2a** sales-only or **R2b** net-of-returns).

* **Target_Revenue_AED**
  `Σ(target_amount_AED)` from Finance targets (store-month).

* **Variance_AED**
  `Actual_Revenue_AED − Target_Revenue_AED`

* **Variance_Pct**
  `ROUND( (Variance_AED / NULLIF(Target_Revenue_AED, 0)) * 100 , 2 )`

  > Positive = above target; negative = shortfall.

---

## Population

All **physical stores** with an active target for the month; **exclude ONLINE_UAE / ONLINE_KSA** unless explicitly in scope.

---

## Time Grain & Anchor

* **Grain:** Calendar **month per store**
* **Anchor:** `order_local_ts` (store-local)
* **Boundary:** **00:00 local** on the 1st

---

## Timezone Policy

UAE → `Asia/Dubai` · KSA → `Asia/Riyadh` · HQ in **Asia/Riyadh**

---

## Breakdowns

* **Store → City → Country**
* Optional: **Region / District**; **Channel** (if you keep a blended target)

---

## Currency / FX Handling

* Facts in AED/SAR; consolidate to **AED** via **daily FX at order_local_date**
* **Freeze FX** at **T+2**

---

## Filters (In / Out)

* **Include:** `Completed/Fulfilled` orders with valid store & monetary fields
* **Exclude:** `Test/Internal/Fraud`, `Cancelled`

---

## Related Dimensions

`dim_store`, `dim_date`, `dim_currency`, `dim_region`

---

## SLA / Freeze

* Refresh: **T+1 06:00 Asia/Riyadh (03:00 UTC)**
* Month **locks at T+2** after Finance finalization

---

## Acceptance Example

Store **Dubai Mall**, **2025-10**:
Actual_Revenue_AED = **1,250,000**; Target_Revenue_AED = **1,100,000** →
**Variance_AED = +150,000 AED**, **Variance_Pct = +13.64%**

---