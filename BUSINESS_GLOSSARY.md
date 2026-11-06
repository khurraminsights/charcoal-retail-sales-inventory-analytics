# Retail Business Knowledge & KPI Glossary

A data analyst needs to understand what a metric represents, its **grain** (what one row or count means), and the operational decision it can support.

| Concept | Plain-English meaning | Analyst's question |
|---|---|---|
| Gross sales | Sales value before discounts | How much was sold at pre-discount value? |
| Discounts | Value reduced from gross sales | How much revenue was given up in discounts? |
| Net sales | Gross sales minus discounts | What revenue remained after discounts? |
| Average order value (AOV) | Net sales divided by order count | How much does an average order contribute? |
| Units sold | Quantity sold, not number of orders | What was the volume of product movement to customers? |
| Supplier on-time delivery | Share of evaluated PO lines delivered on time | Which vendors or items cause delays? |
| Latest closing stock | Quantity calculated at the latest snapshot | How much inventory is available in the snapshot? |
| Stockout SKU-location | A particular product at a particular location with zero or negative closing quantity | Which combinations need replenishment attention? |
| Low-stock SKU-location | A product-location combination with 1–10 units in this case study | Which combinations may be exposed to near-term shortages? |
| Gross inventory variance | Sum of absolute stock discrepancies | How large are differences regardless of sign? |
| Net inventory variance | Sum of signed stock discrepancies | Do positive and negative differences cancel? |
| Stock movement volume | Absolute total of signed movement events | How much activity is recorded, including transfers and opening entries? |

## Retail operating cycle

**Customer demand → sale → stock reduction → replenishment need → purchase order → supplier delivery → receipt → warehouse/store stock → possible transfer → sale.**

A stockout can have many possible causes, including demand shifts, delayed receipts, inaccurate records or allocation choices. **This project does not establish causality** between supplier lateness and stockouts.

## Interpreting the actual case-study results

- **PKR 58.42M net sales** describes revenue, not profit. COGS and operating expenses are needed for profitability.
- **47.44% on-time PO lines** is an operational signal, but the business would need supplier segmentation and expected delivery dates to act precisely.
- **152 stockout SKU-locations** counts product-location combinations; it does not count unique products or stores.
- **375 low-stock combinations** depends on the provisional 10-unit cutoff; proper reorder points should consider demand and lead time.
- **14 gross variance / 0 net variance** means discrepancies exist even though signed differences offset.

## What to ask next

1. Which high-demand products were out of stock and for how long?
2. Were late receipts associated with those products and locations?
3. Which product categories drive sales, and which drive profit once costs are available?
4. What share of stockouts are concentrated in a few stores or suppliers?
5. Do stock discrepancies repeat by transaction type, warehouse or time period?

**Business understanding is what turns a KPI into a useful decision question.**
