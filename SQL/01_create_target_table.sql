CREATE TABLE utilization_trends (
  utilization_year                integer        NOT NULL,
  beneficiary_type                varchar(200)   NOT NULL,
  hosp_service_type               varchar(50)    NOT NULL DEFAULT 'Inpatient Hospital',
  number_of_beneficiaries         integer,
  number_of_services_used         integer,
  realization_rate_per_1000       numeric(12,3),
  average_length_of_stay          numeric(12,3),
  total_medicare_payments         numeric(14,2),
  average_payments_per_service    numeric(12,2),
  PRIMARY KEY (beneficiary_type, utilization_year)
);
