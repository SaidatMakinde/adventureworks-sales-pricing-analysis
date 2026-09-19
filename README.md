# AdventureWorks Sales & Pricing Performance Dashboard

## Project Overview

This project analyzes sales, product performance, customer activity, pricing, cost and profitability using the **AdventureWorks2019** database.

The analysis was completed using **SQL Server and Power BI**, with SQL used to extract, validate and analyze the underlying data and Power BI used to build an interactive dashboard for business reporting.

The objective was to understand where revenue and profit are being generated, identify products with weaker margins, examine pricing performance and provide insights that could support pricing and commercial decision-making.

---

## Business Problem

A retail business needs a clear view of its sales and pricing performance across products, customers and territories.

The key business questions addressed in this analysis are:

* How much revenue and profit is the business generating?
* Which product categories contribute the most revenue and profit?
* Which products are driving sales performance?
* Which customers and territories generate the most revenue?
* What is the relationship between selling price, cost and margin?
* Which products have margins below a 10% analytical threshold?
* Are discounts meaningfully different across product categories?
* Where should management focus further pricing and profitability investigation?

---

## Stakeholders

The analysis is designed to support the information needs of:

* **Sales Managers** — monitor revenue and sales performance
* **Pricing / Commercial Managers** — investigate pricing and margin performance
* **Product Managers** — identify high- and low-performing products
* **Finance Managers** — monitor revenue, cost, profit and margins
* **Senior Management** — review overall business performance and areas requiring further investigation

---

## Tools & Technologies

* **SQL Server**
* **SQL**
* **Power BI Desktop**
* **DAX**
* **Power Query**
* **GitHub**

---

## Data

The project uses the **AdventureWorks2019** sample database.

The analysis combines sales order, product, product category, product subcategory, vendor and sales territory information.

A SQL view, `dbo.vw_PricingAnalytics`, was created to provide a consolidated analytical dataset for the project.

### Key Fields

* SalesOrderID
* OrderDate
* CustomerID
* TerritoryName
* ProductID
* ProductName
* ProductCategory
* ProductSubcategory
* OrderQty
* UnitPrice
* UnitPriceDiscount
* LineTotal
* StandardCost
* GrossRevenue
* Cost
* Profit
* MarginPercent

---

# SQL Analysis

SQL was used as the analytical foundation before building the Power BI dashboard.

The analysis included the following areas:

### 1. Data Validation

* Row counts
* Date range validation
* Distinct orders
* Distinct customers
* Distinct products
* NULL-value checks
* Validation of revenue, cost and profit calculations

### 2. Sales & Profitability

* Total revenue
* Total cost
* Total profit
* Overall profit margin
* Revenue by product category
* Profit by product category
* Revenue contribution by category
* Monthly revenue trends

### 3. Product Analysis

* Product revenue
* Product profit
* Quantity sold
* Average selling price
* Product margin
* Top products by revenue
* Top products by profit
* Product ranking within categories

### 4. Customer & Territory Analysis

* Customer revenue
* Customer profit
* Order volume
* Average order value
* Territory revenue
* Territory profitability

### 5. Pricing & Margin Analysis

* Average selling price
* Average unit cost
* Discount analysis
* Product margin
* Products below the 10% margin threshold
* Revenue and profitability of low-margin products

### SQL Techniques Demonstrated

* `JOIN`
* `GROUP BY`
* Aggregate functions
* `CASE`
* `NULLIF`
* CTEs
* Subqueries
* `HAVING`
* `RANK()`
* Window functions
* Date functions
* Business metric calculations

---

# Power BI Dashboard

The Power BI report contains four pages designed to provide different views of sales, product, customer and pricing performance.

## 1. Executive Overview

Provides a high-level view of:

* Total Revenue
* Total Profit
* Overall Margin
* Total Orders
* Total Customers
* Products Sold
* Monthly Revenue Trend
* Revenue by Product Category
* Revenue by Territory

### Purpose

The Executive Overview provides management with a quick view of overall business performance and the major contributors to revenue and profit.

---

## 2. Product Performance

This page examines product-level and category-level performance.

It includes:

* Products Sold
* Average Revenue per Product
* Average Profit per Product
* Average Selling Price
* Revenue by Product Category
* Profit by Product Category
* Product-level performance

### Purpose

The analysis helps identify which products and categories are contributing to sales and profitability and highlights areas requiring further investigation.

---

## 3. Customer Insights

This page analyzes customer and territory performance.

It includes:

* Total Customers
* Average Revenue per Customer
* Average Profit per Customer
* Average Order Value
* Revenue by Territory
* Customer Performance

### Purpose

The page provides visibility into customer and geographic sales performance and helps identify areas of higher revenue contribution.

---

## 4. Pricing & Margin Analysis

This page focuses on pricing and profitability.

It includes:

* Products Below Target Margin
* Average Selling Price
* Average Unit Cost
* Product-level margin analysis
* Low-margin product table
* Pricing and profitability matrix

A **10% margin threshold** was used as an analytical threshold to identify products requiring further review. This threshold is an analytical assumption for this project and is not presented as an official AdventureWorks business target.

### Purpose

The page helps identify products where selling prices, costs and sales volumes may require additional investigation to understand their impact on profitability.

---

# Key Takeaways

The analysis identified several important patterns in sales, profitability and demand:

* **Bikes generated approximately 86% of total revenue**, making them the primary revenue driver.
* **Bikes contributed approximately 84% of total profit**, generating approximately **$8.43M of the $10.06M total profit**.
* **Revenue peaked in March and May**, indicating seasonal variation in demand during the analysis period.
* **Accessories, Clothing and Components contributed less than 15% of total revenue combined**, indicating potential opportunities to grow sales across these categories.
* **Low-margin products require further investigation**, particularly where relatively strong sales are not translating into proportionate profitability.
* **Discount levels were relatively consistent across product categories**, suggesting that differences in category performance were not primarily driven by discounting.

---

# Business Recommendations

Based on the analysis, the following areas would warrant further business investigation:

### 1. Review Pricing and Cost Structure

Review pricing and cost structures for low-margin products to identify opportunities to improve profitability without negatively affecting demand.

### 2. Focus on Bikes Margin Performance

Because Bikes account for a significant proportion of both revenue and profit, management should closely monitor pricing, costs, product mix and margins within the category.

### 3. Leverage High-Performing Customers and Territories

Analyze high-performing customers and territories to understand purchasing patterns and identify opportunities to increase customer value and expand sales.

### 4. Develop Promotional Strategies for Lower-Revenue Categories

Consider targeted promotional strategies for **Accessories, Clothing and Components** to increase sales volume and their contribution to overall revenue.

### 5. Use Seasonal Patterns for Planning

Use observed periods of higher revenue to support sales planning, inventory decisions and promotional activities.

### 6. Monitor Revenue and Profit Concentration

Continue monitoring the concentration of revenue and profit within the Bikes category to identify potential business risks and opportunities for portfolio diversification.

---

# What I Would Do Next

The current analysis is based primarily on historical sales and product data. For a real business decision, I would extend the analysis by incorporating additional data.

### 1. Competitive Pricing

Compare AdventureWorks selling prices with market or competitor prices to determine whether products are competitively priced.

### 2. Price Elasticity

Analyze how changes in selling price relate to quantity sold to better understand customer price sensitivity.

### 3. Discount Effectiveness

Determine whether higher discounts generate enough additional sales volume to offset the associated reduction in margin.

### 4. Time-Based Margin Trends

Analyze whether product margins are improving or declining over time.

### 5. Customer Segmentation

Segment customers based on revenue, purchase frequency, profitability and purchasing behavior.

### 6. Inventory Analysis

Combine sales and inventory data to identify potential stockout, excess inventory or demand planning risks.

### 7. Supplier Analysis

Investigate supplier costs for products with consistently low margins and identify potential cost optimization opportunities.

### 8. Profitability Forecasting

Develop forecasts for revenue, profit and margin by product category to support future planning.

---

# Key Analytical Assumptions

* `LineTotal` is used as the primary revenue measure because it represents the sales-line total after applicable discounts.
* `GrossRevenue` represents quantity multiplied by unit price before the discount effect.
* Margin is calculated as total profit divided by total revenue.
* The **10% margin level is an analytical threshold created for this project**, not an official AdventureWorks target.
* Average Selling Price is calculated using total revenue divided by total quantity sold.
* Historical AdventureWorks data is used for analysis and does not represent current commercial performance.

---

# Dashboard Walkthrough

A Power BI walkthrough video is included in this repository.

**AdventureWorks Sales & Pricing Performance Dashboard**

The walkthrough demonstrates the four dashboard pages, interactive filters and the main analytical findings.

---

# Skills Demonstrated

### SQL

`SQL Server` `SQL` `JOINs` `CTEs` `Subqueries` `Window Functions` `Aggregations` `CASE` `Data Validation` `Business Metrics`

### Power BI

`Power BI` `DAX` `Power Query` `Data Modeling` `Slicers` `KPI Cards` `Interactive Dashboards`

### Business Analysis

`Revenue Analysis` `Profitability Analysis` `Pricing Analysis` `Margin Analysis` `Customer Analysis` `Product Analysis` `Business Recommendations` `Stakeholder Reporting`

---

# Conclusion

This project demonstrates an end-to-end analytics workflow:

**SQL Server → Data Validation → Business Analysis → Power BI → Insights → Business Recommendations**

The objective was not only to build a dashboard, but to demonstrate how SQL and Power BI can be used together to investigate a business problem, identify meaningful patterns and communicate findings to stakeholders.

The analysis highlights the importance of understanding **revenue concentration, profitability, pricing, customer performance and product mix** when evaluating business performance.

The AdventureWorks2019 database is a sample dataset and the findings are intended for portfolio and analytical demonstration purposes.

