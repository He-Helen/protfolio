-- ========================================
-- Executive Summary
-- ========================================

-- Total revenue
SELECT SUM(revenue) AS total_revenue
FROM orders;

-- Total orders
SELECT COUNT(*) AS total_orders
FROM orders;

-- Total customers
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM orders;

-- Average order value (AOV)
SELECT AVG(revenue) AS avg_order_value
FROM orders;

-- ARPU
SELECT 
    SUM(revenue) * 1.0 / COUNT(DISTINCT customer_id) AS arpu
FROM orders;


-- ========================================
-- Channel Performance
-- ========================================

SELECT
    c.channel,
    COUNT(DISTINCT o.customer_id) AS buyers,
    COUNT(o.order_id) AS total_orders,
    SUM(o.revenue) AS total_revenue,
    ROUND(AVG(o.revenue), 2) AS avg_order_value,
    ROUND(SUM(o.revenue) * 1.0 / COUNT(DISTINCT o.customer_id), 2) AS arpu
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY c.channel
ORDER BY total_revenue DESC;


-- ========================================
-- Repeat Purchase Rate by Channel
-- ========================================

WITH customer_orders AS (
    SELECT
        c.channel,
        o.customer_id,
        COUNT(o.order_id) AS order_count
    FROM orders o
    JOIN customers c
    ON o.customer_id = c.customer_id
    GROUP BY c.channel, o.customer_id
)

SELECT
    channel,
    COUNT(CASE WHEN order_count > 1 THEN 1 END) * 1.0 /
    COUNT(*) AS repeat_rate
FROM customer_orders
GROUP BY channel;


-- ========================================
-- Cohort Retention Summary
-- ========================================

WITH base AS (
    SELECT
        c.customer_id,
        strftime('%Y-%m', c.signup_date) AS cohort_month,
        (
            CAST(strftime('%Y', o.order_date) AS INT) * 12 +
            CAST(strftime('%m', o.order_date) AS INT)
            -
            (CAST(strftime('%Y', c.signup_date) AS INT) * 12 +
             CAST(strftime('%m', c.signup_date) AS INT))
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
    ROUND(
        1.0 * r.retained_customers / cs.cohort_customers,
        3
    ) AS retention_rate
FROM retained r
JOIN cohort_size cs
    ON r.cohort_month = cs.cohort_month
WHERE r.months_since_signup IN (0, 1, 2)
ORDER BY r.cohort_month, r.months_since_signup;


-- ========================================
-- 2. Cohort Retention Summary by Channel (Pivot)
-- ========================================
WITH base AS (
    SELECT
        c.channel,
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
