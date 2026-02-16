CREATE TABLE IF NOT EXISTS orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    revenue REAL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
