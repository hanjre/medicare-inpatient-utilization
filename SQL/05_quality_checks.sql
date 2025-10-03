/* =========================================================
   05_quality_checks.sql
   Purpose: Sanity checks for utilization_trends after load.
   ========================================================= */

-- 1) Row count landed
SELECT COUNT(*) AS rows_loaded FROM public.utilization_trends;

-- 2) No duplicate business keys
SELECT beneficiary_type, utilization_year, COUNT(*) AS dup_count
FROM public.utilization_trends
GROUP BY 1,2
HAVING COUNT(*) > 1;

-- 3) Spot null or empty keys
SELECT *
FROM public.utilization_trends
WHERE utilization_year IS NULL
   OR beneficiary_type IS NULL
   OR beneficiary_type = '';

-- 4) (Optional) Value range checks
-- SELECT * FROM public.utilization_trends
-- WHERE realization_rate_per_1000 < 0
--    OR average_length_of_stay < 0
--    OR total_medicare_payments < 0
--    OR average_payments_per_service < 0;

-- 5) Final peek
-- SELECT * FROM public.utilization_trends ORDER BY beneficiary_type, utilization_year;