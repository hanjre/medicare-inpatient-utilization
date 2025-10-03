-- Ensure each beneficiary_type + utilization_year is unique
SELECT beneficiary_type, utilization_year, COUNT(*) AS dup_count
FROM public.utilization_trends
GROUP BY 1,2
HAVING COUNT(*) > 1;