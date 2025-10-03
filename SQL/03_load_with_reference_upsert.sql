/* =========================================================
   03_load_with_reference_upsert.sql
   Purpose: Normalize keys by joining to a clean reference
            table (clean_data_year) and upsert.
   Requires: public.clean_data_year(utilization_year, beneficiary_type)
   ========================================================= */

WITH parsed AS (
  SELECT
    mi.*,
    ((regexp_match(mi."Type of Entitlement and Calendar Year", '(\d{4})')))[1]::int AS year_key,
    trim(
      regexp_replace(mi."Type of Entitlement and Calendar Year", '\s*\d{4}.*$', '', 'g')
    ) AS type_key
  FROM public.mdcr_inpt_hosp mi
),
joined AS (
  SELECT
    c.utilization_year,
    c.beneficiary_type,
    /* Metrics with robust cleanup */
    NULLIF(regexp_replace(p."Total Persons With Utilization"::text, '[^0-9]', '', 'g'), '')::int                AS number_of_beneficiaries,
    NULLIF(regexp_replace(p."Total Discharges"::text,               '[^0-9]', '', 'g'), '')::int                AS number_of_services_used,
    NULLIF(regexp_replace(p."Discharges Per 1,000 Original Medicare Part A Enrollees"::text, '[^0-9.\-]', '', 'g'), '')::numeric(12,3) AS realization_rate_per_1000,
    NULLIF(regexp_replace(p."Total Days of Care Per Discharge"::text,                         '[^0-9.\-]', '', 'g'), '')::numeric(12,3) AS average_length_of_stay,
    NULLIF(regexp_replace(p."Total Program Payments"::text,                                   '[^0-9.\-]', '', 'g'), '')::numeric(14,2) AS total_medicare_payments,
    NULLIF(regexp_replace(p."Program Payments Per Discharge"::text,                           '[^0-9.\-]', '', 'g'), '')::numeric(12,2) AS average_payments_per_service
  FROM parsed p
  JOIN public.clean_data_year c
    ON c.utilization_year = p.year_key
   AND c.beneficiary_type = p.type_key
)
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
  j.utilization_year,
  j.beneficiary_type,
  'Inpatient Hospital' AS hosp_service_type,
  j.number_of_beneficiaries,
  j.number_of_services_used,
  j.realization_rate_per_1000,
  j.average_length_of_stay,
  j.total_medicare_payments,
  j.average_payments_per_service
FROM joined j
ON CONFLICT (beneficiary_type, utilization_year) DO UPDATE
SET
  hosp_service_type             = EXCLUDED.hosp_service_type,
  number_of_beneficiaries       = EXCLUDED.number_of_beneficiaries,
  number_of_services_used       = EXCLUDED.number_of_services_used,
  realization_rate_per_1000     = EXCLUDED.realization_rate_per_1000,
  average_length_of_stay        = EXCLUDED.average_length_of_stay,
  total_medicare_payments       = EXCLUDED.total_medicare_payments,
  average_payments_per_service  = EXCLUDED.average_payments_per_service;

/* If you previously hit SQLSTATE 25P02 in this session:
   ROLLBACK;  -- once, then re-run this script. */