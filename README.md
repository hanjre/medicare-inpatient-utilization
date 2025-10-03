# Medicare Inpatient Utilization

## About
SQL pipeline that transforms messy Medicare inpatient hospital data into a clean, analysis-ready dataset of annual utilization trends. Includes modular SQL scripts, synthetic demo data, automated quality checks, and documentation (schema + workflow). Demonstrates healthcare data engineering and data quality validation in a reproducible, portfolio-friendly project.

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
