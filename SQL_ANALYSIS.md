# SQL Server Analysis — Actual Script Walkthrough

**Source of truth:** [`../sql/charcoal.sql`](../sql/charcoal.sql), the actual uploaded 1,335-line working script. This is a walkthrough of that script, not a claim that a new database can be rebuilt from it alone.

## 1. Staging data inspection and types

The script starts with the `Charcoal_Inventory_Analytics` database, inspects `FactPurchaseOrders_Stage`, checks `INFORMATION_SCHEMA.COLUMNS`, and adjusts `OrderedQty` to `INT NULL` and `UnitPurchaseCostPKR` to `DECIMAL(18,2) NULL` using `ALTER TABLE`. These are schema changes, so do not execute blindly against a production database.

## 2. Purchase-order and goods-receipt analysis

The early script checks record counts, unique IDs, null fields and quantities. Later queries use `WITH LastReceipt AS (...)` and `WITH ReceiptSummary AS (...)` to study receipts and supplier timing. A CTE is useful because it gives an intermediate name to a calculation before joining or summarizing it.

## 3. Sales questions

The script includes gross/net sales analysis, monthly comparisons, top products and store rankings. It uses `SUM`, `COUNT`, `GROUP BY`, `TOP`, date expressions and joins. This is the foundation for the commercial KPIs shown on the first two dashboard pages.

## 4. Inventory and movement questions

Inventory queries compare recorded and calculated closing quantities, inspect discrepancies by product and location, and review signed movement quantities. A positive and negative discrepancy can cancel in a signed total; the gross absolute magnitude is therefore a separate business metric.

## 5. Referential integrity — eight checks

The `-- CHECK 1: REFERENTIAL INTEGRITY` section (near the final fifth of the script) uses `LEFT JOIN` to find fact keys without a matching dimension row. This is essential because unmatched dimension keys can cause incomplete categories or misleading aggregations in BI reports. The documented test result was **zero missing matches across eight checks**.

## 6. Transfers — `TransferMovements` CTE

The `-- check 2` section builds a `TransferMovements` CTE and groups movement rows by `SourceDocumentID`. Conditional `SUM(CASE ...)` expressions reconcile the two sides of internal transfers. Documented result: **1,528 transfers checked**, with zero reported mismatches. This does not mean transfer-in plus transfer-out is additional stock: they are two legs of the same movement.

## 7. Goods receipts — `ReceiptMovements` CTE

The `-- Check 3 — Goods Receipts Reconciliation` section builds a `ReceiptMovements` CTE, aggregates `SignedQty`, and compares the movement records with goods-receipt lines. Documented result: **511 receipt lines**, **26,058 received and accepted units**, **zero rejected units**.

## Function reference

| SQL construct | What it does | Why it matters here |
|---|---|---|
| `COUNT(*)` | Counts rows | Check source totals and transaction volume |
| `COUNT(DISTINCT ...)` | Counts distinct identifiers | Validate uniqueness and orders |
| `SUM(...)` | Adds numeric values | Revenue, quantities and movement totals |
| `CASE WHEN` | Creates conditional logic | On-time flags, positive/negative movement checks |
| `LEFT JOIN` | Keeps left-side records even without matches | Find orphan keys and reconciliation gaps |
| `GROUP BY` | Aggregates at a defined grain | Monthly, store, product and source-document analysis |
| `WITH ... AS` | Defines a common table expression | Break multi-step validations into readable logic |
| `INFORMATION_SCHEMA.COLUMNS` | Reads column metadata | Confirm data types before calculations |

## How to review the original code

Search for these anchors in [`charcoal.sql`](../sql/charcoal.sql): `WITH MonthlySales`, `Top 10 Products by Net Sales`, `REFERENTIAL INTEGRITY`, `WITH TransferMovements`, and `WITH ReceiptMovements`.

**Execution note:** The script references staging tables that must already exist. It contains multiple exploratory statements and schema changes, not a single ordered setup/migration. The project files do not include the original full SQL database or raw data extracts.
