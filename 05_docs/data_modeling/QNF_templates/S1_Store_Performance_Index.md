# 🟢 QNF: S1 — Store Performance Index (Monthly)

**Business Question**
What percentage of the **monthly revenue target** did each **physical store** achieve in the given **calendar month**?

**Owner / Decision**
Retail Operations & Regional Management — performance evaluation, bonus planning, underperforming store reviews.

---

## Metric (definitions)

* **Actual_Revenue_AED**
  `Σ (order_net_native × FX_to_AED at order_local_date)`
  where orders have `final_status ∈ {'Completed','Fulfilled'}` and `order_flag ∉ {'Test','Internal','Fraud'}`.

  * **order_net_native = Σ (gross_line − vat_line)** at **order level**.
  * **Returns policy (choose one & stick to it):**

    * **S1a (sales-only, = R2a):** exclude refunds (default for Ops).
    * **S1b (net of returns, = R2b):** subtract `refund_net_native` within the same month (Finance often prefers this).

* **Target_Revenue_AED**
  `Σ(target_amount_AED)` from Finance **store targets** for that month (periodic snapshot).

* **Store_Performance_Index**
  `ROUND( Actual_Revenue_AED / NULLIF(Target_Revenue_AED, 0) * 100 , 2 )`

  > 100% = on target; >100% = exceeded; <100% = below.

---

## Population

All **physical stores** active in the period; **exclude ONLINE_UAE / ONLINE_KSA** unless explicitly in scope.

---

## Time Grain & Anchor

* **Grain:** Calendar **month per store**
* **Anchor:** **store-local order timestamp** (`order_local_ts`)
* **Boundary:** **00:00 local** on the 1st

---

## Timezone Policy

UAE → `Asia/Dubai (UTC+4)` · KSA → `Asia/Riyadh (UTC+3)`
HQ roll-ups shown in **Asia/Riyadh**.

---

## Breakdowns

* **Store → City → Country**
* Optional: **Region / District**

---

## Currency / FX Handling

* Facts in native currency (AED/SAR)
* AED consolidation via **daily FX at `order_local_date`**
* **Freeze FX** at **T+2** for the closed month

---

## Filters (In / Out)

* **Include:** final statuses `Completed/Fulfilled`
* **Exclude:** `Test/Internal/Fraud`, `Cancelled`

---

## Related Dimensions

`dim_store`, `dim_date` (role: order_date), `dim_currency`, `dim_region`

---

## SLA / Freeze

* Freshness: **T+1 by 06:00 Asia/Riyadh (03:00 UTC)**
* Month **locks at T+2** (Finance close)

---

## Acceptance Example

Store **Riyadh Gallery**, **2025-10**:
Actual_Revenue_AED = **980,000**; Target_Revenue_AED = **1,000,000** → **SPI = 98.00%**

---

