-- Repeat purchase rate
WITH orders_per_customer AS (
  SELECT customer_id, COUNT(*) AS order_cnt
  FROM orders
  GROUP BY customer_id
),
buyers AS (
  SELECT COUNT(*) AS buyer_cnt
  FROM orders_per_customer
),
repeat_buyers AS (
  SELECT COUNT(*) AS repeat_buyer_cnt
  FROM orders_per_customer
  WHERE order_cnt >= 2
)
SELECT
  repeat_buyer_cnt,
  buyer_cnt,
  ROUND(1.0 * repeat_buyer_cnt / buyer_cnt, 3) AS repeat_purchase_rate
FROM buyers, repeat_buyers;


-- ARPU (Revenue per buyer)
WITH buyer_revenue AS (
  SELECT customer_id, SUM(revenue) AS customer_revenue
  FROM orders
  GROUP BY customer_id
)
SELECT
  ROUND(SUM(customer_revenue), 2) AS total_revenue,
  COUNT(*) AS buyer_cnt,
  ROUND(1.0 * SUM(customer_revenue) / COUNT(*), 2) AS arpu
FROM buyer_revenue;


-- New customers in each channel
SELECT
  channel,
  COUNT(*) AS customers
FROM customers
GROUP BY channel
ORDER BY customers DESC;


-- Each channel's revanue、order、buyer、AOV、ARPU
WITH base AS (
  SELECT
    c.channel,
    o.order_id,
    o.customer_id,
    o.revenue
  FROM orders o
  JOIN customers c
    ON o.customer_id = c.customer_id
),
buyer_revenue AS (
  SELECT
    channel,
    customer_id,
    SUM(revenue) AS customer_revenue
  FROM base
  GROUP BY channel, customer_id
)
SELECT
  b.channel,
  ROUND(SUM(b.revenue), 2) AS total_revenue,
  COUNT(b.order_id) AS orders,
  COUNT(DISTINCT b.customer_id) AS buyers,
  ROUND(1.0 * SUM(b.revenue) / COUNT(b.order_id), 2) AS aov,          -- average order value
  ROUND(1.0 * SUM(b.revenue) / COUNT(DISTINCT b.customer_id), 2) AS arpu, -- revenue per buyer
  ROUND(1.0 * SUM(br.customer_revenue) / COUNT(*), 2) AS avg_ltv_per_buyer
FROM base b
JOIN buyer_revenue br
  ON b.channel = br.channel AND b.customer_id = br.customer_id
GROUP BY b.channel
ORDER BY total_revenue DESC;


-- Repeat Purchase Rate for channels
WITH orders_per_customer AS (
  SELECT
    c.channel,
    o.customer_id,
    COUNT(*) AS order_cnt
  FROM orders o
  JOIN customers c
    ON o.customer_id = c.customer_id
  GROUP BY c.channel, o.customer_id
),
buyers AS (
  SELECT channel, COUNT(*) AS buyer_cnt
  FROM orders_per_customer
  GROUP BY channel
),
repeat_buyers AS (
  SELECT channel, COUNT(*) AS repeat_buyer_cnt
  FROM orders_per_customer
  WHERE order_cnt >= 2
  GROUP BY channel
)
SELECT
  b.channel,
  COALESCE(r.repeat_buyer_cnt, 0) AS repeat_buyers,
  b.buyer_cnt AS buyers,
  ROUND(1.0 * COALESCE(r.repeat_buyer_cnt, 0) / b.buyer_cnt, 3) AS repeat_purchase_rate
FROM buyers b
LEFT JOIN repeat_buyers r
  ON b.channel = r.channel
ORDER BY repeat_purchase_rate DESC;


-- Cohort retention（M0/M1）for channels
WITH base AS (
  SELECT
    c.customer_id,
    c.channel,
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
  SELECT
    channel,
    cohort_month,
    COUNT(DISTINCT customer_id) AS cohort_customers
  FROM base
  GROUP BY channel, cohort_month
),
retained AS (
  SELECT
    channel,
    cohort_month,
    months_since_signup,
    COUNT(DISTINCT customer_id) AS retained_customers
  FROM base
  WHERE months_since_signup IS NOT NULL
    AND months_since_signup >= 0
  GROUP BY channel, cohort_month, months_since_signup
)
SELECT
  cs.channel,
  cs.cohort_month,
  cs.cohort_customers,

  COALESCE(MAX(CASE WHEN r.months_since_signup = 0 THEN r.retained_customers END), 0) AS m0_retained,
  ROUND(
    1.0 * COALESCE(MAX(CASE WHEN r.months_since_signup = 0 THEN r.retained_customers END), 0) / cs.cohort_customers,
    3
  ) AS m0_retention_rate,

  COALESCE(MAX(CASE WHEN r.months_since_signup = 1 THEN r.retained_customers END), 0) AS m1_retained,
  ROUND(
    1.0 * COALESCE(MAX(CASE WHEN r.months_since_signup = 1 THEN r.retained_customers END), 0) / cs.cohort_customers,
    3
  ) AS m1_retention_rate

FROM cohort_size cs
LEFT JOIN retained r
  ON cs.channel = r.channel
 AND cs.cohort_month = r.cohort_month
GROUP BY cs.channel, cs.cohort_month, cs.cohort_customers
ORDER BY cs.channel, cs.cohort_month;
