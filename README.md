Brazilian E-Commerce Analysis (Olist Dataset)
Overview

This project analyzes the Brazilian e-commerce dataset from Olist on Kaggle
 using SQL.
The goal is to understand product and category performance, revenue distribution, and customer behavior, while producing actionable business insights.

All work was done in DataGrip, with query results exported for reporting and portfolio purposes.

Data Sources
Tables and What they contain
olist_orders_dataset	Orders with status and dates
olist_order_items_dataset	Individual products in each order, with price
olist_products_dataset	Product details, including category
olist_order_reviews_dataset	Customer reviews per order
product_category_name_translation	Translated product category names

Questions Answered
**1. Top Products by Revenue**

Which products make the most revenue?

Helps identify key products driving sales and focus inventory or marketing strategies.

**2. Pareto Analysis (80/20 Rule)**

What percentage of revenue comes from the top products?

Shows that a small portion of products generates most of the revenue, highlighting where the business relies heavily on certain items.

**3. Category Revenue Performance**

Which product categories bring in the most revenue?

Aggregates revenue at the category level to guide marketing, inventory, and promotional focus.

**4. High-Revenue Products with Low Ratings**

Which high-revenue products have low customer ratings?

Flags products that are financially important but may hurt brand reputation due to poor reviews.

Includes the global average review score for context.

**5. Payment Type Analysis**

What percentage of total orders comes from each payment method?

Shows which payment types customers prefer and which contribute most to revenue.

Tools & Techniques

SQL (PostgreSQL syntax)

CTEs for step-by-step calculations

Joins across multiple tables

Window functions for cumulative metrics

Percentile functions to identify top-performing products
