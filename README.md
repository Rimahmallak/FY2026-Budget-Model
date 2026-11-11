# FY2026 Multi-Currency Budget vs Actual Model

An Excel model that compares departmental spending with budget across three currencies (USD, EUR, LBP), converts everything to USD at monthly rates, reports year-to-date variances and forecasts full-year spending under three scenarios.

The project was built in three stages:
1. **v1: the core model built by hand with formulas:** cleaning, FX conversion, variance reporting, forecasting and reconciliation checks.
2. **v2: an automated Power Query pipeline added later:** the same ledger cleaning and FX conversion, made refreshable from monthly exports and reconciled to v1 with zero difference.
3. **v3: SQL added before the Power Query stage:** budget vs actual pulled directly from a database with a SQL query, loaded into the workbook with Power Query and reconciled to v1 with zero difference.

📥 **[Download the Excel model](https://github.com/Rimahmallak/FY2026-Budget-Model/raw/main/FY2026_Budget_vs_Actual_Model.xlsx)**

> All data is fictional. Actuals: January–September 2026. Budget: January–December 2026.
> When opening the file, Excel may show *"External data connections have been disabled"*. All results display without enabling it; refreshing needs the original source files.

---

## At a glance

| | |
|---|---|
| **Scope** | 5 departments · 3 currencies · 150 ledger transactions · 12-month budget |
| **Reporting currency** | USD (local amount ÷ monthly rate, local units per 1 USD) |
| **Outputs** | YTD budget vs actual, monthly grids, full-year forecast, Best / Base / Worst scenarios, written key findings |
| **Controls** | Reconciliation checks with a single "All checks passed" flag; Power Query and SQL outputs reconciled to the formula model |
| **Tools** | Excel (dynamic arrays, XLOOKUP, SUMIFS, Tables, named inputs, data validation) · Power Query · SQL (SQLite) |

### Three stages, one answer
| Check (YTD to 30 Sep 2026) | v1 Excel | v2 Power Query | v3 SQL |
|---|---|---|---|
| Transactions | 150 | 150 | 150 |
| Actual spend (USD) | 203,154.55 | 203,154.55 | 203,154.55 |
| Budget (USD) | 252,000.00 | – | 252,000.00 |
| Variance % | −19.38% | – | −19.38% |

---

## Part 1: Excel model (v1, built manually)

### How to use
1. Pick a scenario (**Best / Base / Worst**) on the **Inputs** sheet.
2. Read the results on **Summary**. Details are on **Report** (year to date) and **Forecast** (full year).
3. When new months of data are added, change **Actuals through** on **Inputs**. The YTD and forecast sheets roll forward.
4. Confirm **All checks passed = OK** on the **Checks** sheet.

### Sheets
| Sheet | Contents |
|---|---|
| **Summary** | Headline numbers and three key findings written automatically by formula |
| **README** | Model guide |
| **Inputs** | Variance tolerance, actuals cut-off date, scenario selector (drop-down) and scenario factors |
| **Report** | YTD budget vs actual by department, plus monthly grids of actual spend and budget |
| **Forecast** | Full-year forecast by department and the three-scenario comparison |
| **Checks** | Reconciliation checks |
| **Ledger** | Raw expenses plus cleaning columns, exchange rate and USD amount (`tblLedger`) |
| **Budget, Rates, Departments** | Source tables (`tblBudget`, `tblRates`, `tblDept`) |
| **Ledger_PQ** | Power Query output and reconciliation (added in v2, see Part 2) |
| **Report_SQL** | SQL budget vs actual loaded with Power Query (added in v3, see Part 3) |

### What was done by hand
- **General ledger cleaning with helper columns:** mixed text/real dates converted to real dates; department and currency codes trimmed and upper-cased (`UPPER(TRIM())`); duplicate expenses removed (152 → 150 rows).
- **FX conversion:** rate looked up by currency **and** month with a two-key `XLOOKUP` (with a `"CHECK RATE"` flag when no rate is found), then `Amount USD = ROUND(local ÷ rate, 2)`.
- **Variance reporting:** `SUMIFS` by department and cut-off date; dynamic department and month lists with `UNIQUE`, `SORT` and `TRANSPOSE`; status flags against a tolerance input.
- **Forecasting:** full-year forecast = YTD actual + (monthly run rate × months remaining × scenario factor).
- **Scenario analysis:** Best 90% / Base 100% / Worst 115% of the run rate, selected from a data-validation drop-down.
- **Built for maintenance:** Excel Tables and structured references instead of fixed ranges; named inputs (`Tolerance`, `Scenario`, `Factor`, `ActualsThrough`).

### Conventions
- **Variance** = Actual − Budget (or Forecast − Budget). Positive means overspend.
- **Status:** "Over tolerance" if variance % is above the tolerance, otherwise "Within tolerance"; "No budget" if the budget is zero.

### Reconciliation checks (Checks sheet)
- Row count after removing duplicates, and rows with no rate found
- Monthly grid total vs YTD actual total
- YTD actual total vs ledger total
- YTD budget vs budget through the cut-off date
- Forecast total vs (YTD actual + remaining forecast)
- Selected scenario vs forecast table total
- Full-year budget vs total of the budget table
- SQL report total vs formula report total (added in v3)
- **All checks passed:** a single OK / CHECK flag

### Limitations
- The run rate ignores seasonality and one-off costs.
- The LBP exchange rate is volatile in reality; the model uses the rate supplied for each month.
- In every scenario all departments forecast below budget, which may mean the budget was set too high or spending is back-loaded; the model cannot tell which.

---

## Part 2: Power Query pipeline (v2, November 2026)

### Why
In v1 the ledger is cleaned with helper formulas, which have to be extended and re-checked every time new data is pasted in. v2 rebuilds the same cleaning and FX conversion as a **refreshable Power Query pipeline**, matching how finance teams receive monthly ledger exports from an accounting system.

**Month-end routine:** save the new month's ledger export into the source folder → **Data > Refresh All**. No formulas or queries need editing.

### Queries
| Query | Role |
|---|---|
| `qLedgerFolder` | Combines all monthly CSV exports (`GL_2026-01.csv` … `GL_2026-09.csv`) from one folder; connection only |
| `qRates` | Reads the monthly FX table `tblRates`; connection only |
| `qLedger` | The cleaning and conversion pipeline (steps below); loads to `tblLedgerPQ` on **Ledger_PQ** |

### `qLedger` steps
1. Start from the combined monthly files (`qLedgerFolder`)
2. **Trim** and **UPPERCASE** department and currency codes
3. Convert dates with a **fixed locale (English, US)** so the ISO (`2026-01-12`) and text (`13-Jan-2026`) formats both parse the same way on any PC
4. Set data types explicitly (auto-detected types removed)
5. **Remove duplicates** across all columns, after cleaning, so rows differing only in spacing or case are also caught
6. Add **Month Start** (start of month)
7. **Merge** with `qRates` on Currency + Month (left outer join)
8. Calculate **Amount USD** = local ÷ rate, rounded to 2 decimals, half away from zero, to match Excel's `ROUND`

### Controls
A reconciliation block on **Ledger_PQ** compares the Power Query output with the formula-based ledger from v1:

| Check | Power Query | Formula model | Difference |
|---|---|---|---|
| Rows | 150 | 150 | 0 |
| EUR (local) | 47,600 | 47,600 | 0 |
| USD (local) | 122,050 | 122,050 | 0 |
| LBP (local) | 2,640,000,000 | 2,640,000,000 | 0 |
| Total Amount USD | 203,154.55 | 203,154.55 | 0 |
| Missing FX rates | 0 | 0 | 0 |

**Refresh test:** with only January–August files in the folder, the pipeline returned 129 rows; after adding the September file and refreshing, it returned all 150 rows and every difference returned to 0.

### Note on source files
The monthly CSV exports are not included in this repository. Results are pre-loaded in the workbook, and the full transformation logic can be reviewed in **Data > Queries & Connections** (right-click a query > **Edit**). To refresh with your own files, point the source to your folder via **Data > Get Data > Data Source Settings > Change Source**.

The Report, Forecast and Summary sheets still read the v1 formula ledger (`tblLedger`); the Power Query output runs alongside it and is reconciled to it.

---

## Part 3: SQL before Power Query (v3, November 2026)

### Why
In most organisations the ledger is not received as files: it sits in the accounting system's database. v3 adds the step that comes **before** Power Query: a SQL query pulls the data from the database, joins the ledger with FX rates and budget, and returns budget vs actual by department. Power Query then loads that result into the workbook.

**Pipeline:** Database → SQL query → CSV → Power Query (`qReportSQL`) → **Report_SQL** sheet

### Database (`sql/fy2026_finance.db`, SQLite)
| Table | Rows | Content | Excel equivalent |
|---|---|---|---|
| `gl_transactions` | 150 | Expense ledger, Jan–Sep 2026, in USD / EUR / LBP | `tblLedger` |
| `fx_rates` | 27 | Monthly rates, local currency per 1 USD | `tblRates` |
| `budget` | 60 | Monthly budget per department, USD | `tblBudget` |
| `departments` | 5 | Department names and budget owners | `tblDept` |

### The query (`sql/budget_vs_actual.sql`)
Built in steps with CTEs (`WITH`), mirroring how the Report sheet is built:
1. `budget_ytd`: budget per department, January–September
2. `actual_ytd`: ledger converted to USD at each month's rate (join on currency **and** month), rounded per transaction to match Excel
3. `dept_rows`: the two summaries joined on department (each side totalled first, so nothing is double-counted)
4. `all_rows`: department rows plus a Total row (`UNION ALL`)
5. Final step: variance, variance % (ratio of totals, `NULLIF` to avoid dividing by zero) and status (`CASE`, same rule as the Excel model)

The result is saved as `sql/budget_vs_actual_result.csv` and loaded with Power Query into `tblReportSQL` on **Report_SQL**.

### Result
| Dept | Budget USD | Actual USD | Variance USD | Variance % | Status |
|---|---:|---:|---:|---:|---|
| FIN | 47,700.00 | 44,517.07 | −3,182.93 | −6.67% | Within tolerance |
| HR | 47,900.00 | 38,655.09 | −9,244.91 | −19.30% | Within tolerance |
| IT | 50,700.00 | 44,983.98 | −5,716.02 | −11.27% | Within tolerance |
| MKT | 50,600.00 | 30,375.14 | −20,224.86 | −39.97% | Within tolerance |
| SAL | 55,100.00 | 44,623.27 | −10,476.73 | −19.01% | Within tolerance |
| **Total** | **252,000.00** | **203,154.55** | **−48,845.45** | **−19.38%** | Within tolerance |

### Controls
A row on the **Checks** sheet subtracts the formula Report total from the SQL Report total. It returns **0** and is included in **All checks passed**.

### Note on running it
To run the query yourself, open `sql/fy2026_finance.db` in any SQLite tool (a browser-based SQLite viewer or DB Browser for SQLite) and run `budget_vs_actual.sql`. **Report_SQL** is a snapshot: to update it, re-run the query, export the result to CSV in the source folder, then **Data > Refresh All**.

---

## Version history
| Version | Date | Changes |
|---|---|---|
| v1 | Nov 2026 | Formula-based model: ledger cleaning, FX conversion, variance report, forecast, scenarios, checks |
| v2 | Nov 2026 | Power Query pipeline: folder-based monthly import, automated cleaning, de-duplication, FX merge, reconciliation to v1 |
| v3 | Nov 2026 | SQL stage before Power Query: budget vs actual queried from a SQLite database, loaded with Power Query (`Report_SQL`), reconciled to v1 in the Checks sheet |

## Next
Planned: Power BI dashboard, Python (pandas) for data processing.

---

**Rimah Mallak** · [LinkedIn](https://www.linkedin.com/in/rimah-mallak)
