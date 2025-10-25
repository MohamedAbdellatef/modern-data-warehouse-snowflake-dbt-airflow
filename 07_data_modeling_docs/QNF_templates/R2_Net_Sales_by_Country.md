## QNF: R2 — Net Revenue Ex-VAT by Country

**Business Question**
What is the total **net revenue excluding VAT** generated in each country (UAE vs KSA) per calendar month?

**Business Need / Decision**
Finance & executives need a VAT-neutral view to compare UAE (5%) vs KSA (15%), drive P&L and FX-consolidated reporting, and support VAT audits.

**Owner / Department**
Finance — Regional Controlling & Accounting.

**Metric Definition (Formula)**
**Primary metric (R2a: Gross Revenue ex-VAT):**
`net_revenue_ex_vat = SUM(net_amount)` where `net_amount = gross_amount − vat_amount` **at line level**.
Include orders with `final_status ∈ {'Completed','Fulfilled'}`; exclude `order_flag ∈ {'Test','Internal','Fraud'}` and `status='Cancelled'`.

> If `vat_amount` is null on a line, recompute via **vat_policy** (country, product/category, effective_date).


**Aggregation Logic**
Group by **country** and **calendar month**; sum **source-currency** net, and provide an **AED-consolidated** view.

**Counting Unit / Population**
All **valid order lines** from POS & e-commerce that reached **final status** within the period.
**E-commerce mapping:** assign to **ONLINE_UAE / ONLINE_KSA** virtual stores (country derives from store).

**Time Grain & Anchor**
**Calendar month** using **store-local order timestamp** (`order_local_ts`). Month boundary = **00:00 local** on the 1st.

**Timezone & Boundary Policy**

* UAE → `Asia/Dubai (UTC+4)`
* KSA → `Asia/Riyadh (UTC+3)`
  HQ consolidations shown at **Asia/Riyadh**.

**Filters (In / Out)**

* **Include:** final status lines with non-null `gross_amount` and `currency_code`.
* **Exclude:** test/internal/fraud; cancelled; negative or obviously erroneous amounts (flag for DQ).

**Breakdowns (Primary)**

* **Country** (UAE, KSA)
* Store (Store → City → Country)
* Currency (AED / SAR)
* Channel (POS / Web / Marketplace)

**Currency / FX Handling**

* Store and report **native currency** (AED/SAR).
* **AED consolidation**: convert line-level `net_amount` using **FX rate at `order_local_date`** (preferred) *or* **month-average** — pick one and keep consistent.
* **Freeze FX** at **T+2** for the closed month.

**Related Dimensions**
`dim_store` (country, currency, timezone), `dim_date` (role: order_date), `dim_currency`, `dim_channel`.

**SLA / Refresh Policy**
Freshness **T+1 by 06:00 Asia/Riyadh (03:00 UTC)**.
Month **locks at T+2**; FX table for the month is frozen at close.

**Acceptance Example**
October 2025 totals (illustrative):

* UAE: **AED 1,050,000 gross → AED 1,000,000 net ex-VAT**
* KSA: **SAR 1,150,000 gross → SAR 1,000,000 net ex-VAT**
  AED-consolidated total (using policy rate) ≈ **AED 1.98M**.

**Assumptions / Notes**

* Line-level VAT includes discounts/price rules before tax (per vat_policy).
* Returns handled separately in R2b if required by Finance.
* Cross-border edge cases (ship-to vs store location) are out-of-scope for R2a unless specified.

---