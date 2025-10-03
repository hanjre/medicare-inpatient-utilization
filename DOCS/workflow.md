---

#  `workflow.md`

```markdown
# Workflow: Medicare Inpatient Utilization Pipeline

This document explains the step-by-step workflow implemented in the SQL scripts.

---

## 🔄 High-Level Flow

**Raw Data (CSV) → Staging Table → Transform & Clean → Utilization Trends (Mart) → Data Quality Checks**

---

## 1. Load Raw Data
- Source: `data/sample_data.csv` (synthetic, demo-only).
- Loaded into `public.mdcr_inpt_hosp`.
- All columns stored as text to tolerate messy symbols, commas, or dollar signs.

---

## 2. Create Target Table
- `sql/01_create_target_table.sql` defines `utilization_trends`.
- Enforces composite primary key `(beneficiary_type, utilization_year)`.

---

## 3. Transform & Insert
Three supported loaders:
1. **Mixed Key Parser (`02_load_from_mixed_key.sql`)**
   - Regex extracts year + beneficiary type from a single combined column.
2. **Reference Upsert (`03_load_with_reference_upsert.sql`)**
   - Joins parsed data to a clean reference table (`clean_data_year`) before upsert.
3. **Matrix Pivot (`04_matrix_rownumber_pivot.sql`)**
   - Handles matrix-style inputs where years appear in row headers.

All loaders apply **numeric cleanup** using regex to remove non-numeric characters.

---

## 4. Data Quality Checks
- Implemented in `sql/05_quality_checks.sql` and extended in `tests/`:
  - Row count confirmation.
  - No duplicate `(beneficiary_type, utilization_year)` keys.
  - No null or empty keys.
  - Range checks (non-negative payments, realistic LOS, etc.).

---

## 5. Demo Run
- `demo/run.sql` orchestrates the pipeline:
  1. Creates staging table.
  2. Loads synthetic sample CSV.
  3. Creates target table.
  4. Runs chosen loader.
  5. Runs data quality checks.
  6. Outputs results.

Run with:
```bash
psql -h localhost -U postgres -d medicare_demo -f demo/run.sql