# Multi-Currency Budget vs. Actual Forecasting Model (FY2026)

## Project Overview
An advanced, dynamically rolling corporate finance model designed to track, clean, and forecast departmental expenditures across multiple foreign currencies into a unified reporting currency (**USD**). 

This model tracks financial performance for 5 separate departments across multiple countries, adjusting mid-year forecasts against original budget targets using an automated, three-scenario rolling variance methodology.

### Key Financial Highlights (Base Scenario)
* **Full-Year Budget:** $330,900
* **Full-Year Forecast:** $270,873 ($60,027 under budget, or -18.1%)
* **Year-to-Date (YTD) Actual Spend:** $203,154.55 (January – September 2026)
* **Budget Conformance:** 0 out of 5 departments have exceeded the organization's 10% variance tolerance limit.

---

## Model Architecture & Methodology

### 1. Data Integrity & Cleaning Pipeline
Raw ledger data is processed and sanitized through a structured transformation pipeline before entering the calculation layers:
* **Temporal Alignment:** Standardizes mixed-format dates into dynamic month-start indices (`Month Start`) to map variable exchange rates accurately.
* **Text Normalization:** Automated string trimming and upper-casing for department (`Department Clean`) and currency codes (`Currency Clean`) to prevent calculation breaks in lookup formulas.
* **Deduplication:** Programmatic removal of duplicate transaction IDs to maintain financial reconciliation integrity.

### 2. Multi-Currency Translation Layer
The model converts localized expenses into the target reporting currency ($USD) dynamically:
$$\text{Amount (USD)} = \frac{\text{Local Currency Amount}}{\text{Looked-up Monthly Exchange Rate}}$$
Exchange rates (including USD, EUR, and highly volatile local units like LBP) are indexed dynamically by currency type and the specific transaction month.

### 3. Dynamic Forecasting Logic
The model utilizes a rolling monthly run rate to estimate year-end landing positions:
$$\text{Monthly Run Rate} = \frac{\text{YTD Actual Spend}}{\text{Months Elapsed}}$$
$$\text{Forecast Remaining Months} = \text{Monthly Run Rate} \times \text{Months Remaining} \times \text{Scenario Factor}$$
$$\text{Full-Year Forecast} = \text{YTD Actual} + \text{Forecast Remaining Months}$$

The model compares performance across three distinct scenario vectors:
* **Best Case (Factor: 0.90):** Assumes spending tapers to 90% of the current run rate.
* **Base Case (Factor: 1.00):** Projects a linear continuation (100%) of the current run rate.
* **Worst Case (Factor: 1.15):** Models an aggressive 15% acceleration in spending run rates.

---

## Performance Summary by Department (Base Case)

| Department | YTD Budget | YTD Actual | FY Budget | FY Forecast | Budget Variance ($) | Variance (%) | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Finance (FIN)** | $47,700 | $44,517.07 | $59,000 | $59,356.09 | +$356.09 | +0.6% | Within Tolerance |
| **Human Resources (HR)** | $47,900 | $38,655.09 | $66,100 | $51,540.12 | -$14,559.88 | -22.0% | Within Tolerance |
| **IT (IT)** | $50,700 | $44,983.98 | $65,100 | $59,978.64 | -$5,121.36 | -7.9% | Within Tolerance |
| **Marketing (MKT)** | $50,600 | $30,375.14 | $65,800 | $40,500.19 | -$25,299.81 | -38.4% | Within Tolerance |
| **Sales (SAL)** | $55,100 | $44,623.27 | $74,900 | $59,497.69 | -$15,402.31 | -20.6% | Within Tolerance |
| **TOTAL** | **$252,000** | **$203,154.55** | **$330,900** | **$270,872.73** | **-$60,027.27** | **-18.1%** | **Within Tolerance** |

---

## Core Operational Insights & Limitations
* **Strategic Under-Spending:** Under the base scenario, every department is currently tracking below its historical full-year budget framework. This suggests either an overly conservative initial budgeting process or heavily back-loaded cost profiles.
* **Marketing Cost Gap:** Marketing exhibits the single largest budget deviation, tracking 38.4% under its expected allocation ($40,500 forecast vs. $65,800 budget). 
* **Seasonality Blindspot:** The forecasting methodology assumes a linear operational baseline. It does not account for corporate seasonality, cyclical spending periods, or unexpected one-off lump capital expenditures.
