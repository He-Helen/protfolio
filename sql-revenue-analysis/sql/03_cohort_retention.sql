-- Total revenue
SELECT SUM(revenue) AS total_revenue
FROM orders;


SELECT 
    c.channel,
    SUM(o.revenue) AS total_revenue
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY c.channel
ORDER BY total_revenue DESC;

-- average order value
SELECT 
    AVG(revenue) AS avg_order_value
FROM orders;

-- average order value for each channel
SELECT 
    c.channel,
    AVG(o.revenue) AS avg_order_value
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY c.channel
ORDER BY avg_order_value DESC;

-- customer's lifetime value
SELECT 
    customer_id,
    SUM(revenue) AS ltv
FROM orders
GROUP BY customer_id
ORDER BY ltv DESC;

-- Cohort retention: cohort_month x months_since_signup
WITH base AS (
  SELECT
    c.customer_id,
    strftime('%Y-%m', c.signup_date) AS cohort_month,
    strftime('%Y-%m', o.order_date)  AS order_month,
    (
      (CAST(strftime('%Y', o.order_date) AS INT) - CAST(strftime('%Y', c.signup_date) AS INT)) * 12
      + (CAST(strftime('%m', o.order_date) AS INT) - CAST(strftime('%m', c.signup_date) AS INT))
    ) AS months_since_signup
  FROM customers c
  LEFT JOIN orders o
    ON c.customer_id = o.customer_id
),
cohort_size AS (
  SELECT
    cohort_month,
    COUNT(DISTINCT customer_id) AS cohort_customers
  FROM base
  GROUP BY cohort_month
),
retained AS (
  SELECT
    cohort_month,
    months_since_signup,
    COUNT(DISTINCT customer_id) AS retained_customers
  FROM base
  WHERE months_since_signup IS NOT NULL
  GROUP BY cohort_month, months_since_signup
)
SELECT
  r.cohort_month,
  r.months_since_signup,
  cs.cohort_customers,
  r.retained_customers,
  ROUND(1.0 * r.retained_customers / cs.cohort_customers, 3) AS retention_rate
FROM retained r
JOIN cohort_size cs
  ON r.cohort_month = cs.cohort_month
WHERE r.months_since_signup IN (0, 1, 2)
ORDER BY r.cohort_month, r.months_since_signup;
