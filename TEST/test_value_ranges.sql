-- Check for implausible values (domain sanity checks)
SELECT *
FROM public.utilization_trends
WHERE realization_rate_per_1000 < 0
   OR average_length_of_stay <= 0
   OR total_medicare_payments < 0
   OR average_payments_per_service < 0;