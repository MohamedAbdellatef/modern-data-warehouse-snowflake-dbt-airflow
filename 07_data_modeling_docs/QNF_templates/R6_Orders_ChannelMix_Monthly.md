# QNF: R6 — Channel Mix (% Online vs In-Store) — Monthly

**QNF-ID**: R6-Orders-ChannelMix-Monthly
**Question**: What **percentage of completed orders** are **Online** vs **In-Store** in a given **calendar month**?

**Owner / Decision**: Operations & Ecommerce — channel strategy, staffing, promotions.

---

## Metric (definitions)

* **orders_total = COUNT(DISTINCT order_number)**
  where `final_status ∈ {'Completed','Fulfilled'}` and `order_flag ∉ {'Test','Internal','Fraud'}`.

* **order_channel_group (order-level)**
  Map from `order_channel` →

  * `IN_STORE` if `channel='POS'`
  * `ONLINE` if `channel ∈ {'Web','App','Marketplace'}`
  * `UNKNOWN` (rare; DQ alert)
    *(If only line-level channel exists: derive `order_channel` as the channel of the **largest net line amount**; if tie → `MULTI` bucket; see DQ.)*

* **orders_instore = COUNT(DISTINCT order_number WHERE order_channel_group='IN_STORE')**

* **orders_online = COUNT(DISTINCT order_number WHERE order_channel_group='ONLINE')**

* **percent_instore = ROUND( orders_instore / NULLIF(orders_total,0) * 100 , 2 )**

* **percent_online  = ROUND( orders_online  / NULLIF(orders_total,0) * 100 , 2 )**

> Percentages are reported so **percent_instore + percent_online ≈ 100%** (excluding `UNKNOWN`/`MULTI` if present; report their share separately as quality context).

---

## Population

All **customer orders** (POS + e-commerce) that reached a **final status** in the period.
E-commerce orders are assigned to **ONLINE_UAE / ONLINE_KSA** virtual stores (country from store).

---

## Time Grain & Anchor

* **Grain**: Calendar **month**
* **Anchor timestamp**: **store-local order timestamp** (`order_local_ts`)
* **Boundary**: Month starts **00:00 local** on the 1st

---

## Timezone & Boundary Policy

* UAE → `Asia/Dubai (UTC+4)`
* KSA → `Asia/Riyadh (UTC+3)`
  HQ roll-ups displayed in **Asia/Riyadh**.

---

## Breakdowns (Primary)

* **Country** (UAE, KSA)
* **Store** (Store → City → Country) *(note: online uses ONLINE_UAE/KSA virtual stores)*

**Drilldowns (Secondary)**

* **Channel** (POS / Web / App / Marketplace)
* **Month**

---

## Currency / FX

N/A — volume/percent metric.

---

## Filters (In / Out)

* **Include**: `final_status ∈ {'Completed','Fulfilled'}`
* **Exclude**: `order_flag ∈ {'Test','Internal','Fraud'}`, `status='Cancelled'`

---

## Related Dimensions

* `dim_channel` (with mapping to `order_channel_group`)
* `dim_store` (country, currency, timezone)
* `dim_date` (role: order_date)

---

## SLA / Freeze

* Freshness: **T+1 by 06:00 Asia/Riyadh (03:00 UTC)**
* Month **locks at T+2** after finance close

---

## Acceptance Example

**2025-10 (UAE)**: total completed orders = 50,000; online = 32,500; in-store = 17,500 →
**percent_online = 65.00%**, **percent_instore = 35.00%**.

---