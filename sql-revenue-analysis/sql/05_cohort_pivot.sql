-- Cohort retention pivot (M0/M1)
WITH base AS (
  SELECT
    c.customer_id,
    strftime('%Y-%m', c.signup_date) AS cohort_month,
    (
      (CAST(strftime('%Y', o.order_date) AS INT) - CAST(strftime('%Y', c.signup_date) AS INT)) * 12
      + (CAST(strftime('%m', o.order_date) AS INT) - CAST(strftime('%m', c.signup_date) AS INT))
    ) AS months_since_signup
  FROM customers c
  LEFT JOIN orders o
    ON c.customer_id = o.customer_id
),
cohort_size AS (
  SELECT cohort_month, COUNT(DISTINCT customer_id) AS cohort_customers
  FROM base
  GROUP BY cohort_month
),
retained AS (
  SELECT cohort_month, months_since_signup, COUNT(DISTINCT customer_id) AS retained_customers
  FROM base
  WHERE months_since_signup >= 0
  GROUP BY cohort_month, months_since_signup
)
SELECT
  cs.cohort_month,
  cs.cohort_customers,

  COALESCE(MAX(CASE WHEN r.months_since_signup = 0 THEN r.retained_customers END), 0) AS m0_retained,
  ROUND(
    1.0 * COALESCE(MAX(CASE WHEN r.months_since_signup = 0 THEN r.retained_customers END), 0) / cs.cohort_customers
  , 3) AS m0_retention_rate,

  COALESCE(MAX(CASE WHEN r.months_since_signup = 1 THEN r.retained_customers END), 0) AS m1_retained,
  ROUND(
    1.0 * COALESCE(MAX(CASE WHEN r.months_since_signup = 1 THEN r.retained_customers END), 0) / cs.cohort_customers
  , 3) AS m1_retention_rate

FROM cohort_size cs
LEFT JOIN retained r
  ON cs.cohort_month = r.cohort_month
GROUP BY cs.cohort_month, cs.cohort_customers
ORDER BY cs.cohort_month;
