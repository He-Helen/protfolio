INSERT OR IGNORE INTO customers (customer_id, signup_date, channel) VALUES
(1, '2026-01-03', 'Paid Search'),
(2, '2026-01-05', 'Organic'),
(3, '2026-01-07', 'Referral'),
(4, '2026-01-15', 'Paid Social'),
(5, '2026-02-02', 'Organic'),
(6, '2026-02-10', 'Paid Search');


INSERT INSERT OR IGNORE INTO orders (order_id, customer_id, order_date, revenue) VALUES
(1, 1, '2026-01-10', 120.00),
(2, 2, '2026-01-15', 200.00),
(3, 1, '2026-02-05', 80.00),
(4, 3, '2026-02-10', 150.00),
(5, 4, '2026-02-12', 300.00),
(6, 5, '2026-02-20', 90.00);


SELECT
  channel,
  COUNT(*) AS new_customers
FROM customers
GROUP BY channel
ORDER BY new_customers DESC;
