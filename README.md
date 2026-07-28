# 💰Sales/Revenue Performance Dashboard

So this one started because I got annoyed at dashboards that just show revenue going up and call it a win. Cool, revenue's up, but is anyone actually making money? That's basically what this project digs into.

##Pipeline: Excel -MySQL → Python → Tableau.

##Dataset
Customer shopping trends data — purchase amount, category, item, season, discount applied, shipping type, ratings, subscription status, payment method, previous purchases. Pretty standard retail transactions setup.


#Step : Cleaning it in MySQL
Data was messy as usual, so:

Fixed corrupted rows and dtype issues
Got dates into proper date format
Checked for duplicate order IDs and weird negative profit values
Renamed columns to snake_case, fixed encoding issues

#Step : Tableau dashboard
9 views:

-Revenue / profit / margin % overall and by year

-Revenue & profit by region, store, category, sub-category

-Sub-categories that are actually losing money on average (window function)

-Discount buckets (0%, 1-20%, 21-40%, 40%+) vs avg profit per bucket

-Top 10 customers by lifetime profit vs top customers by revenue alone (not the same list, which was kind of the whole point)

-Month-over-month revenue growth (LAG())

-Running total of revenue by month

-Avg order-to-ship time by ship mode

-Repeat vs one-time customers — who actually brings in more revenue takeaways

-Discounts can pump up revenue numbers while profit quietly bleeds out. Dashboard makes that visible instead of letting one big "total revenue" number hide it.

##Stack
-MySQL / MySQL Workbench — cleaning + SQL
-Python (pandas) — EDA + feature engineering
-Tableau Public — dashboard (on Mac, so no Power BI here)

##Folder structure

├── sql/

│   ├── data_cleaning.sql

│   └── analysis_queries.sql

├── python/

│   ├── eda.ipynb

│   └── feature_engineering.py

├── tableau/

│   └── sales_revenue_dashboard.twbx

└── README.md

##Running it

-Import the CSV into MySQL (Table Data Import Wizard)
-Run sql/data_cleaning.sql
-Run sql/analysis_queries.sql
-Run the Python notebook
-Open the Tableau workbook, point it at the cleaned data

