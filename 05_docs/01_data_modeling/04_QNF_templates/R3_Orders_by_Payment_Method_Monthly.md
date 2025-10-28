# QNF: R3 — Orders by Payment Method (Monthly)

**Business Question**  
How many **completed orders** were paid by each **payment method** in a given **calendar month**?

**Owner / Decision**  
Operations & Finance — payment mix readiness, acquirer negotiations, cash management.

---

## Metric (Definitions)

- **orders_count** = `COUNT(DISTINCT order_number)`  
  where `final_status ∈ {'Completed','Fulfilled'}` and `order_flag ∉ {'Test','Internal','Fraud'}`.

- **final_payment_method (order-level rule)**, derived from `fact_payment` rows:
  1) Keep `event_type='Capture' AND payment_status='Completed'`.  
  2) Choose the **method with largest captured amount**; if tie, choose the **latest successful** capture.  
  3) If >1 distinct methods remain → classify as **'SPLIT'**.  
  4) If no successful capture found → **'UNKNOWN'** (optionally exclude per policy).

> Report buckets: `CARD`, `CASH`, `WALLET`, `BNPL`, `GIFTCARD`, `SPLIT`, `UNKNOWN` (align to your `dim_payment_method`).

---

## Time Grain & Anchor
- **Grain:** Calendar **month**  
- **Anchor timestamp:** **store-local order timestamp** (`order_local_ts`)  
- **Boundary:** Month starts **00:00 local** on the 1st

---

## Timezone Policy
- UAE → `Asia/Dubai (UTC+4)`  
- KSA → `Asia/Riyadh (UTC+3)`  
HQ roll-ups shown in **Asia/Riyadh**.

---

## Filters (In / Out)
- **Include:** `final_status ∈ {'Completed','Fulfilled'}` with a derived `final_payment_method`.  
- **Exclude:** `order_flag ∈ {'Test','Internal','Fraud'}`, `status='Cancelled'`.

---

## Breakdowns (Primary)
- **Payment Method** (per rule above)  
- **Store → City → Country**  
**Drilldowns:** Channel (POS / WEB / MARKETPLACE)

---

## Currency / FX
N/A — count metric.

---

## Related Dimensions
`dim_payment_method`, `dim_store`, `dim_channel`, `dim_date` (role: order_date).

---

## SLA / Freeze
- Freshness **T+1 by 06:00 Asia/Riyadh (03:00 UTC)**  
- Month **locks at T+2** (after Finance close)

---

## Acceptance Example
**2025-10**, **Riyadh Gallery**, **CARD** → **300 orders**.

---