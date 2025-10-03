/* =========================================================
   02_load_from_mixed_key.sql
   Purpose: Parse year + beneficiary_type from one mixed
            text column and load into utilization_trends.
   Source:  public.mdcr_inpt_hosp
   Notes:   Robust numeric cleanup from text fields.
   ========================================================= */

WITH parsed AS (
  SELECT
    mi.*,
    /* Extract 4-digit year from a mixed column like
       "All Beneficiaries 2019 ..." */
    ((regexp_match(mi."Type of Entitlement and Calendar Year", '(\d{4})')))[1]::int AS year_key,
    /* Remove year and trailing text to get the type */
    trim(
      regexp_replace(
        mi."Type of Entitlement and Calendar Year",
        '\s*\d{4}.*$',
        '',
        'g'
      )
    ) AS type_key
  FROM public.mdcr_inpt_hosp mi
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
  p.year_key,
  p.type_key,
  'Inpatient Hospital' AS hosp_service_type,
  NULLIF(regexp_replace(p."Total Persons With Utilization"::text, '[^0-9]',    '', 'g'), '')::int,
  NULLIF(regexp_replace(p."Total Discharges"::text,               '[^0-9]',    '', 'g'), '')::int,
  NULLIF(regexp_replace(p."Discharges Per 1,000 Original Medicare Part A Enrollees"::text, '[^0-9.\-]', '', 'g'), '')::numeric(12,3),
  NULLIF(regexp_replace(p."Total Days of Care Per Discharge"::text,                         '[^0-9.\-]', '', 'g'), '')::numeric(12,3),
  NULLIF(regexp_replace(p."Total Program Payments"::text,                                   '[^0-9.\-]', '', 'g'), '')::numeric(14,2),
  NULLIF(regexp_replace(p."Program Payments Per Discharge"::text,                           '[^0-9.\-]', '', 'g'), '')::numeric(12,2)
FROM parsed p
WHERE p.year_key IS NOT NULL
  AND p.type_key <> ''
ON CONFLICT (beneficiary_type, utilization_year) DO UPDATE
SET
  hosp_service_type             = EXCLUDED.hosp_service_type,
  number_of_beneficiaries       = EXCLUDED.number_of_beneficiaries,
  number_of_services_used       = EXCLUDED.number_of_services_used,
  realization_rate_per_1000     = EXCLUDED.realization_rate_per_1000,
  average_length_of_stay        = EXCLUDED.average_length_of_stay,
  total_medicare_payments       = EXCLUDED.total_medicare_payments,
  average_payments_per_service  = EXCLUDED.average_payments_per_service;