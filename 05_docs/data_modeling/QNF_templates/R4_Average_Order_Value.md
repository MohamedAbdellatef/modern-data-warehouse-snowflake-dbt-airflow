# QNF: R4 — AOV (Average Order Value) — Monthly (v1.3)

**QNF-ID**: R4-AOV-Monthly-Net-ExVAT

**Question**
What is the **Average Order Value (ex-VAT)** per **calendar month** by **store / city / country**, shown in **native currency** (AED or SAR) and **AED-consolidated**?

**Owner / Decision**
Operations & Finance — pricing, promotions, staffing.

**Metric (definitions)**

* **Order_Net (ex-VAT, order level)** = `ROUND( Σ line_net_amount , 2 )`, where `line_net_amount = gross_line − vat_line`.
* **AOV_native** = `Σ Order_Net (native currency) / COUNT(DISTINCT order_number)` within the group.
* **AOV_AED** = `Σ (Order_Net × FX_to_AED at order_local_date) / COUNT(DISTINCT order_number)`.

**Population**
Orders with `final_status ∈ {'Completed','Fulfilled'}`; exclude `order_flag ∈ {'Test','Internal','Fraud'}`.

**Time grain & anchor**
**Calendar month** using **store-local order timestamp** (`order_local_ts`); month boundary **00:00 local**.

**Timezone policy**
UAE → `Asia/Dubai`; KSA → `Asia/Riyadh`. HQ roll-ups displayed in **Asia/Riyadh**.

**Breakdowns**
Primary: **Store → City → Country**.
Secondary: **Channel** (POS / Web / Marketplace).

**Currency / FX**

* Report **AOV_native** in AED (UAE stores) or SAR (KSA stores).
* Report **AOV_AED** using **daily FX at order_local_date**; **freeze FX at T+2**.
* Keep facts in source currency; AED view is for cross-country comparability.

**Filters**
Include final statuses; exclude test/internal/fraud. (Optional DQ: exclude negative Order_Net unless business approves.)

**Related dimensions**
`dim_store` (country, currency, timezone), `dim_date` (role: order_date), `dim_channel`, `dim_currency`.

**SLA / Freeze**
**T+1 by 06:00 Asia/Riyadh (03:00 UTC)**; month **locks at T+2** (values & FX frozen).

**Acceptance example**
Two completed orders in AED: 100 and 200 → **AOV_native = 150 AED**.
If a KSA order = 170 SAR and FX(SAR→AED)=0.98, **AOV_AED** uses 166.6 AED for that order in the numerator.

**Notes**

* Compute line nets at full precision; **round at order level** to 2dp to avoid rounding bias.
* Returns are excluded here (completed orders only). If Finance needs “AOV net of returns,” define a separate metric.

---

If you like, I can draft the **Business Process: Orders** (with the grain sentence and measures this implies) next, plus the tiny **Grain worksheet** for `fact_order_line`.
