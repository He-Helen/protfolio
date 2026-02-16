# Customer Revenue & Retention Analysis (SQL Project)
## Project Goal
This project analyzes customer revenue and retention performance using SQL.

The objective is to simulate a real-world business analytics scenario by calculating key performance indicators (KPIs), cohort retention, customer lifetime value (LTV), and channel performance using relational database queries.

This project demonstrates advanced SQL techniques including JOINs, CTEs, aggregation, cohort analysis, and pivot logic.

## Data Model
### The project uses two relational tables:
customers
customer_id (Primary Key)
signup_date
channel
orders
order_id (Primary Key)
customer_id (Foreign Key → customers)
order_date
revenue

The relationship between tables enables revenue attribution and retention tracking by acquisition channel.

## Key Metrics Computed
### The project calculates:
Total Revenue
Total Orders
Total Customers
Average Order Value (AOV)
ARPU (Average Revenue per User)
LTV (Lifetime Value)
Revenue by Channel
Repeat Purchase Rate
Cohort Retention (M0, M1, M2)
Cohort Pivot Table

## How to Run
### Run the SQL files in the following order:
00_reset.sql (optional)
01_create_tables.sql
04_create_orders.sql
02_kpi_queries.sql
03_cohort_retention.sql
05_cohort_pivot.sql
07_final_report.sql

The final report script aggregates all major KPIs and retention summaries.

## Sample Outputs
### Example outputs include:
Revenue breakdown by channel
Customer lifetime value ranking
Cohort retention table
Pivoted cohort retention matrix (M0/M1 retention rates)
These outputs simulate dashboards used in SaaS, fintech, and subscription-based businesses.

## Future Improvements
### Potential enhancements:
Add refund and churn logic
Introduce subscription billing model
Implement rolling 30-day retention
Add window functions for cumulative revenue
Connect to BI tool (Tableau / Power BI)
Deploy on cloud database (PostgreSQL / Snowflake)