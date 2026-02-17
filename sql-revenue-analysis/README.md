# Customer Revenue & Retention Analysis (SQL Project)
## Project Goal
This project analyzes customer revenue and retention performance using SQL.

The objective is to simulate a real-world subscription / SaaS analytics workflow by calculating business-critical KPIs including revenue growth, customer lifetime value (LTV), acquisition channel performance, and cohort retention analysis.

This project demonstrates intermediate-to-advanced SQL techniques including JOINs, CTEs, aggregation, cohort analysis, pivot logic, and KPI reporting queries.

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

The relationship between tables enables revenue attribution, customer lifetime value calculation, and retention tracking by acquisition channel.

## Key Metrics Computed
### Revenue & Growth Metrics
Total Revenue  
Total Orders  
Total Customers  
Monthly Revenue  
Revenue Growth Rate  
### Customer Metrics
Average Order Value (AOV)  
ARPU (Average Revenue per User)  
Customer Lifetime Value (LTV)  
Revenue Share by Customer  
### Channel Performance
Revenue by Channel  
Customer Acquisition by Channel  
Channel-Level Retention  
### Cohort Analytics
Standard Cohort Retention Table  
Retention Rate by Month Since Signup  
Channel-Level Cohort Retention  
Pivoted Cohort Retention Matrix (M0 / M1)  

## How to Run
### Run the SQL files in the following order:
00_reset.sql (optional)  
01_create_tables.sql  
04_create_orders.sql  
02_kpi_queries.sql  
03_cohort_retention.sql  
05_cohort_pivot.sql  
06_growth_kpis.sql  
07_final_report.sql  

The final report script aggregates all major KPIs and retention summaries.

Recommended environment:  
VS Code  
SQLite extension  
SQLite database file: revenue.db  

## Sample Outputs
### Example outputs include:
Revenue breakdown by channel  
Customer lifetime value ranking  
Revenue growth metrics  
Cohort retention table  
Pivoted cohort retention matrix (M0 / M1 retention rates)  
Channel-level retention comparison  

These outputs simulate dashboards used in SaaS, fintech, insurance, and subscription-based businesses.

## Future Improvements
### Potential enhancements:
Add refund and churn logic  
Introduce subscription billing model  
Implement rolling 30-day retention  
Add window functions for cumulative revenue  
Add region or plan-level segmentation  
Connect to BI tool (Tableau / Power BI)  
Deploy on cloud database (PostgreSQL / Snowflake)  
Convert to production-ready warehouse model  