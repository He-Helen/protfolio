-- Revenue KPI SQL Project
-- Author: Tianxiao He
-- Date: 2026-02-15

CREATE TABLE IF NOT EXISTS customers (
    customer_id INT PRIMARY KEY,
    signup_date DATE,
    channel VARCHAR(50)
);

