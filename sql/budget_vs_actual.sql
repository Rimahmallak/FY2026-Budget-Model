-- =====================================================================
-- budget_vs_actual.sql
-- Stage 3 (SQL) of the FY2026 Budget vs Actual model.
-- Pulls YTD budget vs actual by department (Jan–Sep 2026, in USD)
-- straight from the database. The result is exported to CSV and
-- loaded into the Excel model with Power Query (query qBvA_SQL).
--
-- Steps : 1) budget_ytd - budget per department, Jan–Sep
--         2) actual_ytd - ledger converted to USD at each month's FX rate
--         3) dept_rows  - the two summaries joined on dept_code
--         4) all_rows   - department rows + Total row
--         5) final      - variance, variance % and status
-- Check : Total 252,000.00 budget | 203,154.55 actual | -19.38%
--         (same as the Excel formulas and the Power Query pipeline)
-- =====================================================================

WITH budget_ytd AS (
    SELECT dept_code,
           SUM(budget_usd) AS budget_usd
    FROM budget
    WHERE month_start < '2026-10-01'
    GROUP BY dept_code
),
actual_ytd AS (
    SELECT g.dept_code,
           ROUND(SUM(ROUND(g.amount_local / r.local_per_usd, 2)), 2) AS actual_usd
    FROM gl_transactions AS g
    JOIN fx_rates AS r
      ON  r.currency    = g.currency
      AND r.month_start = substr(g.txn_date, 1, 8) || '01'
    GROUP BY g.dept_code
),
dept_rows AS (
    SELECT b.dept_code,
           b.budget_usd,
           a.actual_usd
    FROM budget_ytd AS b
    LEFT JOIN actual_ytd AS a
      ON a.dept_code = b.dept_code
),
all_rows AS (
    SELECT dept_code, budget_usd, actual_usd, 1 AS sort_key
    FROM dept_rows
    UNION ALL
    SELECT 'Total', SUM(budget_usd), ROUND(SUM(actual_usd), 2), 2
    FROM dept_rows
)
SELECT dept_code,
       budget_usd,
       actual_usd,
       ROUND(actual_usd - budget_usd, 2) AS variance_usd,
       ROUND((actual_usd - budget_usd) / NULLIF(budget_usd, 0), 4) AS variance_pct,
       CASE
           WHEN budget_usd = 0 THEN 'No budget'
           WHEN (actual_usd - budget_usd) / budget_usd > 0.10 THEN 'Over tolerance'
           ELSE 'Within tolerance'
       END AS status
FROM all_rows
ORDER BY sort_key, dept_code;
