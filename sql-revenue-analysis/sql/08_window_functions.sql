-- Running revenue by channel (cumulative revenue)
SELECT
    c.channel,
    o.order_date,
    o.revenue,
    SUM(o.revenue) OVER (
        PARTITION BY c.channel
        ORDER BY o.order_date
    ) AS running_revenue
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
ORDER BY c.channel, o.order_date;


-- First vs Repeat orders by channel
-- Tag each order as first order or repeat order using window function
WITH order_rank AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        o.revenue,
        c.channel,
        ROW_NUMBER() OVER (
            PARTITION BY o.customer_id
            ORDER BY o.order_date
        ) AS rn
    FROM orders o
    JOIN customers c
    ON o.customer_id = c.customer_id
)

SELECT
    channel,
    SUM(CASE WHEN rn = 1 THEN 1 ELSE 0 END) AS first_orders,
    SUM(CASE WHEN rn > 1 THEN 1 ELSE 0 END) AS repeat_orders,
    ROUND(
        1.0 * SUM(CASE WHEN rn > 1 THEN 1 ELSE 0 END) / COUNT(*),
        3
    ) AS repeat_order_rate
FROM order_rank
GROUP BY channel
ORDER BY repeat_order_rate DESC;


-- Monthly New vs Returning Customers
-- New customer = customer's first-ever order happens in that month
-- Returning customer = customer has ordered before, and places an order in that month
WITH base AS (
    SELECT
        o.customer_id,
        o.order_date,
        strftime('%Y-%m', o.order_date) AS order_month,
        MIN(o.order_date) OVER (PARTITION BY o.customer_id) AS first_order_date
    FROM orders o
),
flagged AS (
    SELECT
        customer_id,
        order_month,
        CASE
            WHEN strftime('%Y-%m', first_order_date) = order_month THEN 1
            ELSE 0
        END AS is_new_customer
    FROM base
),
monthly AS (
    SELECT
        order_month,
        COUNT(DISTINCT CASE WHEN is_new_customer = 1 THEN customer_id END) AS new_customers,
        COUNT(DISTINCT CASE WHEN is_new_customer = 0 THEN customer_id END) AS returning_customers,
        COUNT(DISTINCT customer_id) AS total_customers
    FROM flagged
    GROUP BY order_month
)

SELECT
    order_month,
    new_customers,
    returning_customers,
    total_customers,
    ROUND(1.0 * returning_customers / total_customers, 3) AS returning_rate
FROM monthly
ORDER BY order_month;


-- Monthly New vs Returning Customers by Channel
-- New customer = customer's first-ever order happens in that month
-- Returning customer = customer has ordered before, and places an order in that month
WITH base AS (
    SELECT
        o.customer_id,
        o.order_date,
        strftime('%Y-%m', o.order_date) AS order_month,
        MIN(o.order_date) OVER (PARTITION BY o.customer_id) AS first_order_date
    FROM orders o
),
joined AS (
    SELECT
        b.customer_id,
        b.order_month,
        c.channel,
        CASE
            WHEN strftime('%Y-%m', b.first_order_date) = b.order_month THEN 1
            ELSE 0
        END AS is_new_customer
    FROM base b
    JOIN customers c
      ON b.customer_id = c.customer_id
),
monthly_channel AS (
    SELECT
        order_month,
        channel,
        COUNT(DISTINCT CASE WHEN is_new_customer = 1 THEN customer_id END) AS new_customers,
        COUNT(DISTINCT CASE WHEN is_new_customer = 0 THEN customer_id END) AS returning_customers,
        COUNT(DISTINCT customer_id) AS total_customers
    FROM joined
    GROUP BY order_month, channel
)

SELECT
    order_month,
    channel,
    new_customers,
    returning_customers,
    total_customers,
    ROUND(1.0 * returning_customers / total_customers, 3) AS returning_rate
FROM monthly_channel
ORDER BY order_month, channel;


-- Monthly Revenue: MoM growth + running total
WITH monthly_rev AS (
    SELECT
        strftime('%Y-%m', order_date) AS order_month,
        SUM(revenue) AS revenue
    FROM orders
    GROUP BY strftime('%Y-%m', order_date)
),
calc AS (
    SELECT
        order_month,
        revenue,
        LAG(revenue) OVER (ORDER BY order_month) AS prev_month_revenue,
        SUM(revenue) OVER (
            ORDER BY order_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_total_revenue
    FROM monthly_rev
)

SELECT
    order_month,
    revenue,
    prev_month_revenue,
    ROUND(1.0 * (revenue - prev_month_revenue) / prev_month_revenue, 3) AS mom_growth_rate,
    running_total_revenue
FROM calc
ORDER BY order_month;


-- Top Customers: revenue contribution, share, and rank (SQLite-safe)
WITH cust_rev AS (
    SELECT
        customer_id,
        SUM(revenue) AS total_revenue
    FROM orders
    GROUP BY customer_id
),
scored AS (
    SELECT
        customer_id,
        total_revenue,
        ROUND(
            1.0 * total_revenue / SUM(total_revenue) OVER (),
            4
        ) AS revenue_share,
        DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
    FROM cust_rev
)
SELECT
    s.revenue_rank,
    s.customer_id,
    c.channel,
    s.total_revenue,
    s.revenue_share
FROM scored s
LEFT JOIN customers c
  ON s.customer_id = c.customer_id
WHERE s.revenue_rank <= 10
ORDER BY s.revenue_rank, s.customer_id;