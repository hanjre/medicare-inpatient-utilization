# Data Model: Utilization Trends

This document describes the target table `public.utilization_trends` created by the SQL pipeline.

---

## Purpose
The `utilization_trends` table provides **annualized, analysis-ready utilization metrics** derived from raw Medicare inpatient hospital data. It enables trend analysis of beneficiaries, discharges, payment amounts, and care patterns by beneficiary type and year.

---

## Table Structure

| Column                      | Type            | Description |
|-----------------------------|-----------------|-------------|
| utilization_year            | integer         | Calendar year of utilization (extracted from raw data). |
| beneficiary_type            | varchar(200)    | Beneficiary category (e.g., All Beneficiaries, Aged Beneficiaries, Disabled Beneficiaries). |
| hosp_service_type           | varchar(50)     | Service category (defaults to `Inpatient Hospital`). |
| number_of_beneficiaries     | integer         | Number of unique persons with utilization. |
| number_of_services_used     | integer         | Number of discharges/services delivered. |
| realization_rate_per_1000   | numeric(12,3)   | Discharges per 1,000 Part A enrollees. |
| average_length_of_stay      | numeric(12,3)   | Average days of care per discharge. |
| total_medicare_payments     | numeric(14,2)   | Total Medicare program payments. |
| average_payments_per_service| numeric(12,2)   | Average Medicare payment per discharge/service. |

Primary Key: `(beneficiary_type, utilization_year)`

---

## Entity Relationship Diagram

```mermaid
erDiagram
  MDCR_INPT_HOSP ||--o{ UTILIZATION_TRENDS : feeds

  MDCR_INPT_HOSP {
    text Type_of_Entitlement_and_Calendar_Year
    text Total_Persons_With_Utilization
    text Total_Discharges
    text Discharges_Per_1000
    text Total_Days_of_Care_Per_Discharge
    text Total_Program_Payments
    text Program_Payments_Per_Discharge
  }

  UTILIZATION_TRENDS {
    int utilization_year PK
    varchar beneficiary_type PK
    varchar hosp_service_type
    int number_of_beneficiaries
    int number_of_services_used
    numeric realization_rate_per_1000
    numeric average_length_of_stay
    numeric total_medicare_payments
    numeric average_payments_per_service
  }