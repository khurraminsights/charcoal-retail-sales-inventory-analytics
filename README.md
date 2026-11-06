<div align="center">

![Charcoal Pakistan Retail Analytics](assets/branding/project_banner.svg)

# From Retail Data to Business Decisions

**An end-to-end retail analytics portfolio case study** — from SQL validation and reconciliation to Power BI reporting, DAX measures, and evidence-based business recommendations.

![SQL Server](https://img.shields.io/badge/SQL_Server-Data%20Validation-242424?style=flat-square) ![Power BI](https://img.shields.io/badge/Power_BI-3%20Dashboards-C9A24D?style=flat-square) ![DAX](https://img.shields.io/badge/DAX-KPI%20Engineering-242424?style=flat-square) ![Dataset](https://img.shields.io/badge/Data-Simulated-777777?style=flat-square)

**[Business Challenge](#the-business-challenge) · [Dashboards](#power-bi-dashboards) · [SQL](#sql-server-workflow) · [DAX](#dax--kpi-engineering) · [Insights](#findings-and-recommendations) · [Files](#repository-guide)**

</div>

> **Portfolio integrity:** This project analyzes a **simulated apparel-retail dataset**. The metrics below are results of the case-study data, not audited or actual operating figures for a real company. Recommendations are proposals, not implemented business outcomes.

## Project at a glance

| Business scope | Analytical implementation | Deliverable |
|:---|:---|:---|
| Sales, products, stores, suppliers and inventory | Excel source data → SQL Server staging and reconciliation → Power BI data model → DAX | Three-page interactive retail performance report |
| Reporting period: **Jan 2025–Sep 2026** | **12** staging tables (5 dimensions, 7 facts) | Executive, Sales & Product, and Inventory dashboards |
| Inventory snapshot: **30 Sep 2026** | SQL integrity tests, movement reconciliation and slicer QA | Documented metrics, findings and suggested actions |

### Headline metrics

| Net sales | Units sold | Orders | Supplier on-time | Latest stock | Stockout SKU-locations |
|---:|---:|---:|---:|---:|---:|
| **PKR 58.42M** | **13,154** | **5,371** | **47.44%** | **61,198** | **152** |

## The business challenge

A multi-location apparel retailer generates data in different operational processes. Sales records describe what customers buy; purchasing and goods receipts describe incoming supply; transfers and inventory snapshots describe where stock sits. Reporting on these separately makes it difficult to answer cross-functional questions consistently.

The case study was designed to help retail decision-makers ask:

- **Commercial performance:** How much revenue was generated, and which stores, categories and products contribute most?
- **Supplier execution:** Are purchase-order lines delivered on time? Which delays merit investigation?
- **Stock availability:** Which product–location combinations are out of stock or near a low-stock threshold?
- **Inventory accuracy:** Do recorded and calculated stock balances reconcile, and where are differences concentrated?

**My objective as the analyst:** build a traceable reporting workflow, check the underlying records before interpreting results, define useful KPIs, and translate dashboard observations into concrete next analytical questions.

## My end-to-end approach

```mermaid
flowchart LR
  A[Excel source data] --> B[SQL Server staging]
  B --> C[Integrity and reconciliation checks]
  C --> D[Power BI semantic model]
  D --> E[DAX measures and slicer testing]
  E --> F[Three dashboards]
  F --> G[Business findings and recommendations]
```

**Why this order matters:** A visually attractive dashboard can still mislead if the joins, movement signs, date logic or filter context are wrong. Validation was treated as part of analysis, not a finishing touch.

## Power BI dashboards

### 01 · Executive Overview

![Executive Overview dashboard](assets/dashboards/01_executive_overview.png)

**Purpose:** give management one view of revenue, orders, units, supplier delivery and inventory variance, supported by monthly sales trends, store rankings and leading products.

| KPI | Verified value | Business interpretation |
|---|---:|---|
| Net Sales | PKR 58,418,127 | Revenue after discounts in the case-study sales records |
| Units Sold | 13,154 | Sales volume, distinct from order count |
| Total Orders | 5,371 | Number of orders represented in the sales analysis |
| On-Time PO Lines | 47.44% | 204 of 430 evaluated purchase-order lines were on time |
| Gross Inventory Variance | 14 units | Sum of absolute recorded-vs-calculated differences |

**Decision signal:** 226 of 430 evaluated PO lines were late (52.56%). Investigate supplier-level performance and lead-time variability before assuming a root cause.

### 02 · Sales & Product Performance

![Sales & Product Performance dashboard](assets/dashboards/02_sales_product_performance.png)

**Purpose:** understand revenue composition and compare performance across time, product categories, products and stores.

| KPI | Verified value | Meaning |
|---|---:|---|
| Gross Sales | PKR 60,219,390 | Sales value before discounts |
| Discounts | PKR 1,801,263 | Reduction between gross and net sales |
| Net Sales | PKR 58,418,127 | Gross sales minus discounts |
| Average Order Value | PKR 10,876.58 | Net sales divided by orders |
| Units Sold | 13,154 | Total quantity sold |

The dashboard compares monthly gross and net sales, top products by revenue, product categories and store rankings. **Revenue is not profit:** margins and costs would be needed to identify the most profitable products or stores. A high-revenue category may also require closer review of discounts and stock availability.

### 03 · Inventory Health & Stock Availability

![Inventory Health dashboard](assets/dashboards/03_inventory_health.png)

**Purpose:** show latest available stock, product–location availability, historical reconciliation issues and stock movement components.

| KPI | Verified value | Interpretation |
|---|---:|---|
| Latest Closing Stock | 61,198 units | Calculated stock at the latest snapshot (30 Sep 2026) |
| Stockout SKU-Locations | 152 | Product–location combinations with closing stock ≤ 0 |
| Low-Stock SKU-Locations | 375 | Product–location combinations with closing stock from 1 to 10 units |
| Gross Inventory Variance | 14 units | Absolute sum of inventory discrepancies |
| Historical Discrepancy Locations | 4 | Locations with nonzero differences in the historical records |

**Important definitions:** 152 stockout SKU-locations does **not** mean 152 physical stores or 152 distinct products. The low-stock cutoff of 10 units is an **analytical assumption**, not a verified company reorder policy. Historical discrepancy locations are not necessarily locations with a current discrepancy.

The four historical discrepancies were **S004 +5**, **S008 +2**, **W002 −3**, and **W001 −4** units. Their **gross absolute variance is 14**, while the **signed net is zero**. Netting away errors would conceal the location-level problems.

The movement donut uses absolute movement quantities: Opening 48,040; Receipt 26,058; Transfer In 15,519; Transfer Out 15,519; Sale 13,154; Return Restock 254. The **118,544 total is not closing inventory**: it includes opening balance and counts both legs of internal transfers.

> **Visual QA note:** The supplied inventory dashboard PDF has a duplicated inventory-snapshot label in its header. The screenshot is preserved as exported; this cosmetic issue should be corrected in a future PBIX export.

## SQL Server workflow

**Actual SQL source:** [`sql/charcoal.sql`](sql/charcoal.sql) — the uploaded project script, preserved rather than replaced with invented examples.

The script contains **1,335 lines** of exploration, schema adjustments, business analysis and validation queries. It is a **working analysis script**, not a clean, idempotent database deployment or a dataset creation script. Review its `ALTER TABLE` statements and table dependencies before running it against another database.

### Data structure

| Dimensions (5) | Fact tables (7) |
|---|---|
| `DimStores_Stage` | `FactSales_Stage` |
| `DimProducts_Stage` | `FactPurchaseOrders_Stage` |
| `DimSuppliers_Stage` | `FactGoodsReceipts_Stage` |
| `DimProductVariants_Stage` | `FactTransfers_Stage` |
| `DimWarehouses_Stage` | `FactReturns_Stage` |
| | `FactStockMovements_Stage` |
| | `FactInventory_Stage` |

### SQL techniques and why I used them

| Technique | Practical use in the supplied script |
|---|---|
| `SELECT`, `WHERE`, `TOP` | Inspect records, sample tables and isolate business questions |
| `SUM`, `COUNT`, `COUNT(DISTINCT)` | Aggregate revenue, quantities, orders and record counts |
| `GROUP BY` | Summarize monthly sales, stores, products and movements |
| `JOIN` / `LEFT JOIN` | Enrich fact data with descriptive dimensions; expose missing matches |
| `CASE` | Build conditional totals and reconciliation flags |
| CTEs (`WITH`) | Stage multi-step calculations such as monthly sales and transfer/receipt checks |
| Date functions and grouping | Compare sales periods and report monthly trends |
| `ALTER TABLE`, `INFORMATION_SCHEMA` | Inspect and adjust staging-column data types in the working script |

### Concrete SQL quality checks

**Referential integrity:** the script includes eight dimension-relationship checks with `LEFT JOIN` logic. The documented execution results reported zero missing matches.

**Transfers:** a `TransferMovements` CTE aggregates stock movement signs and quantities by `SourceDocumentID` and compares them with transfer records. The documented result: **1,528 transfers**, with zero reported reconciliation mismatches.

**Goods receipts:** a `ReceiptMovements` CTE aggregates receipt movements by source document and reconciles receipt lines. The documented result: **511 receipt lines**, **26,058 received/accepted units**, and **zero rejected units**.

**Inventory:** the analysis includes **4,992 inventory snapshots** and identifies four nonzero discrepancy records. The presence of discrepancies is a finding, not proof that all records were perfectly accurate.

For a guided walkthrough of the actual script, see **[SQL Analysis Guide](docs/SQL_ANALYSIS.md)**.

## DAX & KPI engineering

The report uses reusable measures to make calculations consistent across visuals and slicer selections. The following definitions are documented and tested during the project workflow. **They are not claimed to be an automated, complete extraction of all measures inside the PBIX model.**

| Measure | Business question | Definition / method |
|---|---|---|
| Gross Sales | What was sold before discounts? | Sum of gross sales amounts |
| Total Discounts | How much was discounted? | Sum of discount amounts |
| Net Sales | What was sold after discounts? | Gross sales − discounts |
| Total Units Sold | How many units were sold? | Sum of sales quantities |
| Total Orders | How many orders occurred? | Distinct order count |
| Average Order Value | Average revenue per order? | Net Sales / Total Orders |
| On-Time Delivery % | How reliably are suppliers delivering? | On-time evaluated PO lines / all evaluated PO lines |
| Latest Closing Stock | What is stock on the latest inventory date? | Sum of calculated closing quantities on latest snapshot |
| Stockout SKU-Locations | How many product–location combinations are out of stock? | Count grouped combinations with closing quantity ≤ 0 |
| Low-Stock SKU-Locations | How many combinations are near stockout? | Count grouped combinations with closing quantity 1–10 |
| Gross Inventory Variance | What is the magnitude of reconciliation differences? | Sum of absolute discrepancies |

### A real debugging example: DAX filter context

The original stockout measure returned **152** even when the user selected store **S001**, because `ALL(FactInventory_Stage)` removed the location filter. I revised the measure to preserve the location selection while explicitly handling the snapshot-date filter.

| Test | Expected behavior | Observed result |
|---|---|---:|
| All locations | Portfolio-wide stockouts | **152** |
| S001 selected | Store-specific stockouts | **15** |
| All locations — closing stock | Latest total stock | **61,198** |
| S001 selected — closing stock | Store-specific latest stock | **2,013** |
| All locations — low stock | Latest low-stock combinations | **375** |
| S001 selected — low stock | Store-specific low-stock combinations | **36** |

This matters because **a KPI can be numerically correct in the default view but wrong under interaction**. See **[DAX Measures & QA](docs/DAX_MEASURES.md)** for the documented expressions and limitations.

## Findings and recommendations

| Observed evidence | Business implication | Proposed next step |
|---|---|---|
| **47.44%** of evaluated PO lines were on time | Supplier delivery reliability merits attention | Segment late lines by supplier, category and lead-time variation; validate whether delays coincide with stockouts |
| **152** stockout SKU-location combinations | Some products were unavailable at specific locations at the latest snapshot | Prioritize by demand, margin (if available), and replenishment lead time |
| **375** low-stock SKU-location combinations | Locations may face near-term replenishment exposure | Replace the provisional 10-unit threshold with demand- and lead-time-based reorder points |
| **14** units gross variance, **0** net variance | Opposing errors can cancel in a net metric | Investigate the four underlying location records and movement trails |
| Sales vary across stores and categories | Revenue mix differs by channel/location and assortment | Compare demand, promotions, inventory availability and costs before making commercial decisions |

**Evidence boundary:** These are observations and proposed investigations. The data does **not** establish that late suppliers caused the observed stockouts, that low stock led to lost sales, or that recommendations delivered financial gains.

## What I learned about the business

This project strengthened my understanding of the **retail operating cycle**: customer demand produces sales, purchasing and supplier deliveries replenish supply, warehouses and stores move inventory, and reconciliations help maintain confidence in stock records. A useful analyst connects those processes rather than treating each dashboard as an isolated report.

For example, supplier on-time percentage is not simply a score: it prompts questions about vendor concentration, order dates, promised dates and operational exposure. Likewise, a stockout count becomes more useful when combined with product demand, replenishment lead times and location priorities.

**My main takeaway:** data analysis is the combination of sound data checks, correct KPI definitions, business context and appropriately cautious recommendations.

## Limitations and next improvements

- Dataset is simulated; insights should not be generalized to a real company.
- Margin and cost-of-goods analysis would be needed before drawing profitability conclusions.
- A fixed low-stock threshold is a temporary analytical rule, not a forecasting model.
- Full cross-filter, refresh, relationship and security QA was not exhaustively documented.
- Supplier delays and stockouts should be linked at product/date/location level before suggesting causation.
- Future versions could include inventory turnover, stock cover, sell-through, demand forecasting and supplier scorecards.

## Repository guide

```text
Charcoal_Retail_Analytics_GitHub_Enhanced/
├── README.md                         ← Start here: complete business case study
├── assets/
│   ├── branding/project_banner.svg   ← Custom charcoal-and-gold cover
│   └── dashboards/
│       ├── 01_executive_overview.png
│       ├── 02_sales_product_performance.png
│       ├── 03_inventory_health.png
│       └── Power_BI_Dashboard_3_Pages.pdf
├── sql/charcoal.sql                   ← Actual uploaded SQL working script
├── powerbi/Charcoal_Pakistan_Retail_Analytics.pbix  ← Actual uploaded PBIX
└── docs/
    ├── SQL_ANALYSIS.md               ← Script walkthrough and query logic
    ├── DAX_MEASURES.md               ← Documented DAX + validation tests
    ├── BUSINESS_GLOSSARY.md          ← Retail concepts and KPI definitions
    └── REPRODUCIBILITY.md            ← How to inspect / limitations
```

### How to explore this project

1. Read the business challenge and dashboard interpretations above.
2. Open the three screenshots for a quick visual overview.
3. Explore [`sql/charcoal.sql`](sql/charcoal.sql) and its [walkthrough](docs/SQL_ANALYSIS.md) for actual SQL logic.
4. Open the [PBIX file](powerbi/Charcoal_Pakistan_Retail_Analytics.pbix) in Power BI Desktop to inspect the report and model; refreshing may require the original SQL Server database and local configuration.
5. Read the [DAX guide](docs/DAX_MEASURES.md) for the documented measure logic and filter-context QA.

---

<div align="center"><strong>From validated retail data to clearer business decisions.</strong><br/><sub>Independent simulated-data analytics portfolio project · SQL Server · Power BI · DAX</sub></div>
