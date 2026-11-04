# Multi-Currency Budget vs. Actual Forecasting Model (FY2026)

A multi-currency Budget vs Actual and year-end forecasting model built in Excel. It cleans a raw expense ledger, converts local-currency amounts to USD using monthly exchange rates, compares year-to-date spending with budget by department, and forecasts the full year under three scenarios (Best / Base / Worst).

> **Data note:** all data in this project is fictional and was created for demonstration.
> **Requires Excel 2021 or Microsoft 365** (the model uses XLOOKUP, UNIQUE and SORT). Earlier versions will show `#NAME?` errors.

![Summary sheet](images/summary.png)

## Headline Results (Base Scenario)
* **Full-year budget:** USD 330,900
* **Full-year forecast:** USD 270,873 (USD 60,027 or 18.1% under budget)
* **Year-to-date actual (Jan-Sep 2026):** USD 203,154.55 against a YTD budget of USD 252,000 (19.4% under)
* **Variance tolerance:** 0 of 5 departments exceed the 10% tolerance. Finance is the only department forecast above budget (+0.6%).

## Scenario Results

| Scenario | Factor | Full-year forecast (USD) | Variance vs budget (USD) | Variance % |
| :--- | :--- | :--- | :--- | :--- |
| Best | 0.90 | 264,101 | -66,799 | -20.2% |
| Base | 1.00 | 270,873 | -60,027 | -18.1% |
| Worst | 1.15 | 281,030 | -49,870 | -15.1% |

Even the Worst case ends 15.1% under budget.

## Department Results (Base Scenario, USD)

| Department | YTD Budget | YTD Actual | FY Budget | FY Forecast | Variance (Forecast - Budget) | Variance % | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Finance (FIN) | 47,700 | 44,517.07 | 59,000 | 59,356.09 | +356.09 | +0.6% | Within tolerance |
| Human Resources (HR) | 47,900 | 38,655.09 | 66,100 | 51,540.12 | -14,559.88 | -22.0% | Within tolerance |
| IT | 50,700 | 44,983.98 | 65,100 | 59,978.64 | -5,121.36 | -7.9% | Within tolerance |
| Marketing (MKT) | 50,600 | 30,375.14 | 65,800 | 40,500.19 | -25,299.81 | -38.4% | Within tolerance |
| Sales (SAL) | 55,100 | 44,623.27 | 74,900 | 59,497.69 | -15,402.31 | -20.6% | Within tolerance |
| **Total** | **252,000** | **203,154.55** | **330,900** | **270,872.73** | **-60,027.27** | **-18.1%** | **Within tolerance** |

![Forecast vs Budget chart](images/forecast-chart.png)

## How the Model Works

### 1. Data cleaning
* Mixed date formats (real dates and text) are converted to real dates, and each date is mapped to its month start so exchange rates can be matched by month.
* Department and currency codes are trimmed and upper-cased (`Department Clean`, `Currency Clean`) so lookups do not break on stray spaces or lowercase entries.
* 2 duplicate expense records were removed (152 rows down to 150).

### 2. Currency conversion
Each expense is converted to USD with the exchange rate for its currency and month. Rates are quoted as local currency units per 1 USD (USD, EUR and LBP are included), so:

$$\text{Amount (USD)} = \frac{\text{Local Currency Amount}}{\text{Monthly Exchange Rate}}$$

The rate is found with a two-key XLOOKUP (currency and month). Any expense without a matching rate would be flagged `CHECK RATE`; none are.

### 3. Forecast logic
Months elapsed and months remaining are calculated from the "Actuals through" date on the Inputs sheet, so the model rolls forward when that date changes.

$$\text{Monthly Run Rate} = \frac{\text{YTD Actual}}{\text{Months Elapsed}}$$
$$\text{Forecast Remaining} = \text{Monthly Run Rate} \times \text{Months Remaining} \times \text{Scenario Factor}$$
$$\text{Full-Year Forecast} = \text{YTD Actual} + \text{Forecast Remaining}$$

### 4. Scenarios
The scenario is chosen from a dropdown on the Inputs sheet. The factors are assumptions that can be edited:
* **Best (0.90):** spending runs at 90% of the current run rate.
* **Base (1.00):** spending continues at the current run rate.
* **Worst (1.15):** spending runs 15% above the current run rate.

## Model Structure

| Sheet | Purpose |
| :--- | :--- |
| Summary | Headline numbers and three written findings that update with the scenario |
| README | Conventions and notes inside the workbook |
| Inputs | Variance tolerance, actuals cut-off date, scenario selector and factors |
| Report | YTD budget vs actual by department, plus monthly grids of actual spend and budget |
| Forecast | Full-year forecast by department and the three-scenario comparison |
| Checks | Reconciliation checks |
| Ledger, Budget, Rates, Departments | Source data (Excel Tables) |

## Controls and Checks
* Six reconciliation checks tie the monthly grids, YTD totals, ledger total, budget table and forecast arithmetic back to their sources. All return 0, and an "All checks passed" cell shows OK.
* Variance = Actual (or Forecast) minus Budget. A positive number means overspend.
* Status: `Over tolerance` if variance % is above the tolerance, otherwise `Within tolerance`; `No budget` if the budget is zero.
* Inputs are kept on one sheet and shown in blue. All data tables are Excel Tables, and formulas use table references.

## How to Use
1. Download `FY2026_Budget_vs_Actual_Model.xlsx` and open it in Excel 2021 or Microsoft 365.
2. Pick a scenario on the **Inputs** sheet.
3. Read the results on **Summary**, with detail on **Report** and **Forecast**.
4. Confirm that **Checks** shows "All checks passed: OK".

## Key Observations
* **Under budget in every scenario.** This could mean the budgets were set too high or that costs are back-loaded. The model cannot tell which.
* **Marketing has the largest gap:** a forecast of 40,500 against a budget of 65,800 (-38.4%).
* **Finance is the only department forecast above budget** in the Base case (+0.6%), and it stays within tolerance.

## Limitations
* The forecast assumes spending continues at the average monthly rate. It does not account for seasonality or one-off costs.
* The scenario factors are judgment-based assumptions, not statistically derived.
* The status flag only catches overspend. Large underspends, such as Marketing at -38%, still show "Within tolerance". A two-sided flag would be a useful extension.
* The model covers one calendar year (months remaining = 12 minus the month of the cut-off date).
* Exchange rates are used as supplied for each month. Currency movements are not forecast, and the LBP is highly volatile in reality.
* All data is fictional.

## Skills Demonstrated
Excel Tables and structured references, SUMIFS and XLOOKUP (including two-key lookups), dynamic arrays (UNIQUE, SORT), data validation and named ranges, scenario analysis, variance analysis, reconciliation checks, and model documentation.

## Possible Extensions
Seasonality-adjusted forecast, two-sided variance flag, Power Query for the cleaning steps, and a Power BI dashboard on top of the same data.
