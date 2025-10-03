-- Ensure no null/empty business keys
SELECT *
FROM public.utilization_trends
WHERE utilization_year IS NULL
   OR beneficiary_type IS NULL
   OR beneficiary_type = '';