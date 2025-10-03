-- =========================================================
-- demo/run.sql
-- Purpose: One-command demo to build the inpatient
--          utilization pipeline and load synthetic data.
-- Usage:
--   psql -h <host> -U <user> -d <db> -f demo/run.sql
-- =========================================================

\echo '==> Setting search_path to public'
SET search_path TO public;

\echo '==> Creating source table: public.mdcr_inpt_hosp (text columns, tolerant of messy inputs)'
CREATE TABLE IF NOT EXISTS public.mdcr_inpt_hosp (
  "Type of Entitlement and Calendar Year"                                         text,
  "Total Persons With Utilization"                                                text,
  "Total Discharges"                                                              text,
  "Discharges Per 1,000 Original Medicare Part A Enrollees"                       text,
  "Total Days of Care Per Discharge"                                              text,
  "Total Program Payments"                                                        text,
  "Program Payments Per Discharge"                                                text
);

\echo '==> Clearing source table (demo-friendly refresh)'
TRUNCATE TABLE public.mdcr_inpt_hosp;

\echo '==> Loading synthetic CSV from data/sample_data.csv'
\copy public.mdcr_inpt_hosp
      FROM 'data/sample_data.csv'
      WITH (FORMAT CSV, HEADER TRUE);

\echo '==> Creating/ensuring target table exists'
\i sql/01_create_target_table.sql

\echo '==> Loading (mixed key parser path) with idempotent upsert'
\i sql/02_load_from_mixed_key.sql
-- Alternative loaders you can try:
-- \i sql/03_load_with_reference_upsert.sql
-- \i sql/04_matrix_rownumber_pivot.sql

\echo '==> Running data quality checks'
\i sql/05_quality_checks.sql

\echo '==> Sample results'
TABLE public.utilization_trends
ORDER BY beneficiary_type, utilization_year;

\echo '==> Demo complete.'