/* =========================================================
   04_matrix_rownumber_pivot.sql
   Purpose: Handle “matrix-like” source where years and
            beneficiary blocks are based on row positions.
   Steps:
     1) Snapshot source with row_id.
     2) Mark rows that contain years for each beneficiary_type.
     3) Join back and load.
   ========================================================= */

-- 1) Snapshot with stable row numbers
DROP TABLE IF EXISTS public.mdcr_inpt_hosp_numbered;
CREATE TABLE public.mdcr_inpt_hosp_numbered AS
SELECT
  row_number() OVER (ORDER BY (SELECT 1)) AS row_id,
  mi.*
FROM public.mdcr_inpt_hosp mi;

CREATE UNIQUE INDEX IF NOT EXISTS ux_mdcr_inpt_hosp_numbered_rowid
  ON public.mdcr_inpt_hosp_numbered(row_id);

-- 2) Label the year rows for each beneficiary block
CREATE OR REPLACE VIEW public.mdcr_inpt_year_rows AS
WITH labeled AS (
  SELECT
    n.row_id,
    n."Type of Entitlement and Calendar Year" AS raw_column,
    CASE
      WHEN n.row_id BETWEEN  3 AND  8  THEN 'All Beneficiaries'
      WHEN n.row_id BETWEEN 11 AND 16  THEN 'Aged Beneficiaries'
      WHEN n.row_id BETWEEN 18 AND 24  THEN 'Disabled Beneficiaries'
      ELSE NULL
    END AS beneficiary_type
  FROM public.mdcr_inpt_hosp_numbered n
)
SELECT
  row_id,
  beneficiary_type,
  CAST(raw_column AS integer) AS utilization_year
FROM labeled
WHERE beneficiary_type IS NOT NULL
  AND raw_column ~ '^\d{4}$';

-- 3) Load (upsert) from the labeled year rows
INSERT INTO public.utilization_trends (
  utilization_year,
  beneficiary_type,
  hosp_service_type,
  number_of_beneficiaries,
  number_of_services_used,
  realization_rate_per_1000,
  average_length_of_stay,
  total_medicare_payments,
  average_payments_per_service
)
SELECT
  y.utilization_year,
  y.beneficiary_type,
  'Inpatient Hospital' AS hosp_service_type,

  NULLIF(regexp_replace(n."Total Persons With Utilization"::text, '[^0-9]',    '', 'g'), '')::int          AS number_of_beneficiaries,
  NULLIF(regexp_replace(n."Total Discharges"::text,               '[^0-9]',    '', 'g'), '')::int          AS number_of_services_used,
  NULLIF(regexp_replace(n."Discharges Per 1,000 Original Medicare Part A Enrollees"::text, '[^0-9.\-]', '', 'g'), '')::numeric(12,3) AS realization_rate_per_1000,
  NULLIF(regexp_replace(n."Total Days of Care Per Discharge"::text,            '[^0-9.\-]', '', 'g'), '')::numeric(12,3) AS average_length_of_stay,
  NULLIF(regexp_replace(n."Total Program Payments"::text,                      '[^0-9.\-]', '', 'g'), '')::numeric(14,2) AS total_medicare_payments,
  NULLIF(regexp_replace(n."Program Payments Per Discharge"::text,              '[^0-9.\-]', '', 'g'), '')::numeric(12,2) AS average_payments_per_service
FROM public.mdcr_inpt_year_rows y
JOIN public.mdcr_inpt_hosp_numbered n
  USING (row_id)
ON CONFLICT (beneficiary_type, utilization_year) DO UPDATE
SET
  hosp_service_type             = EXCLUDED.hosp_service_type,
  number_of_beneficiaries       = EXCLUDED.number_of_beneficiaries,
  number_of_services_used       = EXCLUDED.number_of_services_used,
  realization_rate_per_1000     = EXCLUDED.realization_rate_per_1000,
  average_length_of_stay        = EXCLUDED.average_length_of_stay,
  total_medicare_payments       = EXCLUDED.total_medicare_payments,
  average_payments_per_service  = EXCLUDED.average_payments_per_service;