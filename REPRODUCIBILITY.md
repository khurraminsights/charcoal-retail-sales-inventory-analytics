# Files, Reproducibility and Project Integrity

## What is included

- `sql/charcoal.sql`: **original uploaded SQL script** (1,335 lines). This is actual working project code, including exploratory queries and schema alterations.
- `powerbi/Charcoal_Pakistan_Retail_Analytics.pbix`: **original uploaded Power BI report**. This is a binary PBIX file and requires compatible Power BI Desktop for full inspection.
- `assets/dashboards/Power_BI_Dashboard_3_Pages.pdf`: **original three-page Power BI export**.
- `assets/dashboards/*.png`: PNG renders of the three original dashboard PDF pages.
- `docs/DAX_MEASURES.md`: measures documented during the project and validation; **not a complete automated PBIX measure export**.

## What is not included

- The original Excel input datasets and SQL Server database backups.
- A complete schema-creation and data-loading pipeline.
- Proof that a third party can refresh the PBIX without the original SQL Server connection, permissions and input tables.
- Evidence that business recommendations were implemented or produced real-world gains.

## Suggested inspection path

1. Review the rendered dashboards and KPI explanations in `README.md`.
2. Open the PBIX in Power BI Desktop; inspect the relationships, queries, measures and filter behavior.
3. Read `sql/charcoal.sql` as a historical analysis script; **do not run all statements blindly**. It contains `ALTER TABLE` commands and depends on pre-existing staging tables.
4. Use `docs/SQL_ANALYSIS.md` and `docs/DAX_MEASURES.md` to understand the intended logic and documented checks.

## Accuracy notes

- The project uses simulated data, not actual Charcoal Pakistan company financials.
- Some dashboard content (for example the repeated inventory snapshot label on page 3) is a visible export issue preserved in the original evidence.
- The dashboard's movement donut includes opening balances and both sides of internal transfers, so it is not an ending-stock measure.
- KPI validation was substantial but not an exhaustive independent audit.

## Publishing checklist

- Ensure the PBIX does not contain private credentials or sensitive data-source addresses before making the repository public. The report is included as supplied; this packaging step does not constitute a security audit.
- Confirm that you have rights to publish the underlying code, PBIX and screenshots.
- Avoid adding private datasets, passwords, connection strings, or actual confidential company data.
