# DAX Measures and Quality Assurance

These expressions were documented and validated in the project workflow. **This is not a complete programmatic export of all measures from the PBIX binary.** Open the PBIX in Power BI Desktop to inspect the authoritative live model.

## Latest inventory snapshot

```dax
Latest Snapshot Date =
CALCULATE(
    MAX(FactInventory_Stage[SnapshotDate]),
    REMOVEFILTERS(FactInventory_Stage[SnapshotDate])
)
```

**Purpose:** choose the latest available inventory date while removing a date-column selection. Other report filters may still affect the context.

## Latest closing stock

```dax
Latest Closing Stock =
VAR LatestDate = [Latest Snapshot Date]
RETURN
    CALCULATE(
        SUM(FactInventory_Stage[CalculatedClosingQty]),
        REMOVEFILTERS(FactInventory_Stage[SnapshotDate]),
        FactInventory_Stage[SnapshotDate] = LatestDate
    )
```

**Validation:** 61,198 overall; 2,013 when `LocationID = S001`.

## Stockout SKU-locations — corrected filter-context measure

```dax
Stockout SKU-Locations =
VAR LatestDate = [Latest Snapshot Date]
VAR StockByLocation =
    CALCULATETABLE(
        SUMMARIZE(
            FactInventory_Stage,
            FactInventory_Stage[ProductID],
            FactInventory_Stage[LocationID],
            "ClosingStock",
                SUM(FactInventory_Stage[CalculatedClosingQty])
        ),
        REMOVEFILTERS(FactInventory_Stage[SnapshotDate]),
        FactInventory_Stage[SnapshotDate] = LatestDate
    )
RETURN
    COUNTROWS(
        FILTER(
            StockByLocation,
            [ClosingStock] <= 0
        )
    )
```

**Business definition:** count distinct product-location combinations whose aggregated latest calculated closing quantity is zero or negative. **Validation:** 152 overall; 15 for S001.

**Debugging:** the earlier version wrapped the inventory table in `ALL(FactInventory_Stage)`, which removed location filtering and incorrectly returned 152 even when S001 was selected. The revised expression was retested with and without the slicer.

## Low-stock SKU-locations

```dax
Low Stock SKU-Locations =
VAR LatestDate = [Latest Snapshot Date]
VAR StockByLocation =
    CALCULATETABLE(
        SUMMARIZE(
            FactInventory_Stage,
            FactInventory_Stage[ProductID],
            FactInventory_Stage[LocationID],
            "ClosingStock",
                SUM(FactInventory_Stage[CalculatedClosingQty])
        ),
        REMOVEFILTERS(FactInventory_Stage[SnapshotDate]),
        FactInventory_Stage[SnapshotDate] = LatestDate
    )
RETURN
    COUNTROWS(
        FILTER(
            StockByLocation,
            [ClosingStock] > 0
                && [ClosingStock] <= 10
        )
    )
```

**Validation:** 375 overall; 36 for S001. The 10-unit cutoff is a provisional case-study assumption.

## Historical discrepancy locations

```dax
Locations with Discrepancies =
CALCULATE(
    DISTINCTCOUNT(FactInventory_Stage[LocationID]),
    FILTER(
        FactInventory_Stage,
        FactInventory_Stage[DiscrepancyQty] <> 0
    )
)
```

**Validation:** 4 overall; 0 for S001. This is a historical metric over the visible fact context, not a latest-snapshot-only metric.

## Stock movement absolute volume

```dax
Stock Movement Volume =
SUMX(
    FactStockMovements_Stage,
    ABS(FactStockMovements_Stage[SignedQty])
)
```

**Validated movement components:** Opening 48,040; Receipt 26,058; Transfer In 15,519; Transfer Out 15,519; Sale 13,154; Return Restock 254; total absolute quantity 118,544. This total is **not** the latest stock balance, and transfers are counted once on each side.

## Other business KPI definitions

| KPI | Calculation concept | Verified output |
|---|---|---:|
| Gross Sales | Gross sales amounts summed | PKR 60,219,390 |
| Discounts | Discount amounts summed | PKR 1,801,263 |
| Net Sales | Gross Sales − Discounts | PKR 58,418,127 |
| Total Units Sold | Sum of units sold | 13,154 |
| Total Orders | Distinct order count | 5,371 |
| AOV | Net Sales ÷ Total Orders | PKR 10,876.58 |
| Supplier On-Time Delivery | 204 on-time ÷ 430 evaluated PO lines | 47.44% |
| Gross Inventory Variance | Sum of absolute discrepancy quantities | 14 units |

The precise DAX source text for these additional commercial KPIs was not independently extracted here; their calculation concepts and reported outputs are documented. Do not treat the table as a code export.

## QA boundaries

- Confirmed tests include overall versus S001 filter behavior for selected measures.
- Not every date/store/product filter combination was exhaustively validated.
- The PDF dashboard is a static export; the PBIX is the interactive source for further QA.
