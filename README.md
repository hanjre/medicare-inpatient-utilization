# Medicare Inpatient Utilization

SQL pipeline to transform raw Medicare inpatient data into annual utilization trends with quality checks.

---

## Project Overview
This project demonstrates how to take **raw healthcare tables** (inpatient Medicare hospital data) and transform them into a **tidy, analysis-ready table**.  

It covers:
- Parsing messy text fields (year + beneficiary type combined).
- Cleaning numeric values that contain commas, dollar signs, or symbols.
- Creating a standardized summary table (`utilization_trends`) with annualized counts, rates, and payments.
- Running **data quality checks** (duplicate keys, nulls, row counts).
- Idempotent upserts (`ON CONFLICT DO UPDATE`) so the pipeline can be safely rerun.

---

## How to Run

1. Clone this repository:
   ```bash
   git clone https://github.com/hanjre/medicare-inpatient-utilization.git
   cd medicare-inpatient-utilization