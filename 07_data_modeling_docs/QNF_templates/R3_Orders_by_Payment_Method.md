# QNF: R3 — Orders by Payment Method (Monthly) v1.2

**QNF-ID**: R3-OrdersByPaymentMethod-Monthly
**Question**: How many **completed orders** per **payment method** each **calendar month**?
**Owner / Decision**: Operations — payment mix readiness.

**Metric (formula)**
`orders_count = COUNT(DISTINCT order_number)`
**Include** orders with `final_status ∈ {'Completed','Fulfilled'}` and **a derived final_payment_method**.
**Exclude** rows with `order_flag ∈ {'Test','Internal','Fraud'}`.

**Deriving `final_payment_method` (order-level rule)**
From `fact_payment` rows for the order:

1. Keep `payment_status='Completed'` (successful captures).
2. Choose the **method with largest captured amount**; if tie, choose **latest successful**.
3. If >1 distinct methods remain → classify order as **'SPLIT'** (keep as its own method bucket).
4. If no successful payment found → **'UNKNOWN'** (optional: exclude by policy).

**Aggregation**
COUNT DISTINCT **per payment_method per calendar month**.

**Population**
All valid customer **orders** (POS + e-com) that reached **final status** in the period.
*E-com mapping:* assign to **ONLINE_UAE / ONLINE_KSA** virtual stores.

**Time Grain & Anchor**
**Calendar month** at **store-local order timestamp** (`order_local_ts`); month boundary **00:00 local**.

**Timezone Policy**
UAE → `Asia/Dubai`; KSA → `Asia/Riyadh`. HQ roll-ups displayed in `Asia/Riyadh`.

**Filters**
Include final statuses; Exclude test/internal/fraud (as order flags).

**Breakdowns (primary)**

* **Payment Method** (Card, Cash, Wallet, BNPL, GiftCard, **SPLIT**, UNKNOWN)
* Store (Store → City → Country)
  **Drilldowns**: Channel (POS / Web / Marketplace)

**Currency / FX**
N/A (count metric).

**Related Dimensions**
`dim_payment_method`, `dim_store`, `dim_date` (role: order_date), `dim_channel`.

**SLA / Refresh**
**T+1 by 06:00 Asia/Riyadh (03:00 UTC)**; month **locks at T+2**.

**Acceptance Example**
2025-10, **Riyadh Gallery**, **VISA** → **300 orders**.
---