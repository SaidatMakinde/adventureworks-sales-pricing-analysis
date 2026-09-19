/*
============================================================
ADVENTUREWORKS SALES & PRICING PERFORMANCE ANALYSIS
Database: AdventureWorks2019
Tools: SQL Server / SQL / Power BI
============================================================

This single script:
1. Creates dbo.vw_PricingAnalytics
2. Validates the analytical dataset
3. Analyzes sales and profitability
4. Analyzes products
5. Analyzes customers and territories
6. Analyzes pricing and margins
7. Demonstrates CTEs and window functions

NOTE:
LineTotal = primary revenue measure (after applicable discounts)
GrossRevenue = OrderQty * UnitPrice (before discount effect)
10% margin = analytical threshold for this portfolio project
============================================================
*/

USE AdventureWorks2019;
GO

/* ============================================================
   SETUP — CREATE ANALYTICAL VIEW
   ============================================================ */

DROP VIEW IF EXISTS dbo.vw_PricingAnalytics;
GO

CREATE VIEW dbo.vw_PricingAnalytics
AS
SELECT
    soh.SalesOrderID,
    soh.OrderDate,
    soh.CustomerID,
    soh.TerritoryID,

    st.Name AS TerritoryName,
    st.CountryRegionCode,
    st.[Group] AS TerritoryGroup,

    p.ProductID,
    p.Name AS ProductName,
    pc.Name AS ProductCategory,
    psc.Name AS ProductSubcategory,

    v.BusinessEntityID AS VendorID,
    v.Name AS VendorName,

    sod.OrderQty,
    sod.UnitPrice,
    sod.UnitPriceDiscount,
    sod.LineTotal,

    p.StandardCost,

    sod.OrderQty * sod.UnitPrice AS GrossRevenue,

    sod.OrderQty * p.StandardCost AS Cost,

    (sod.OrderQty * sod.UnitPrice)
        - (sod.OrderQty * p.StandardCost) AS Profit,

    CASE
        WHEN sod.OrderQty * sod.UnitPrice = 0 THEN NULL
        ELSE
            (
                (sod.OrderQty * sod.UnitPrice)
                - (sod.OrderQty * p.StandardCost)
            )
            /
            (sod.OrderQty * sod.UnitPrice)
    END AS MarginPercent

FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
    ON sod.ProductID = p.ProductID
LEFT JOIN Production.ProductSubcategory AS psc
    ON p.ProductSubcategoryID = psc.ProductSubcategoryID
LEFT JOIN Production.ProductCategory AS pc
    ON psc.ProductCategoryID = pc.ProductCategoryID
LEFT JOIN Purchasing.ProductVendor AS pv
    ON p.ProductID = pv.ProductID
LEFT JOIN Purchasing.Vendor AS v
    ON pv.BusinessEntityID = v.BusinessEntityID
LEFT JOIN Sales.SalesTerritory AS st
    ON soh.TerritoryID = st.TerritoryID;
GO


/* ============================================================
   01 — DATA VALIDATION
   ============================================================ */

/* 01.1 Row Count */
SELECT COUNT(*) AS TotalRows
FROM dbo.vw_PricingAnalytics;


/* 01.2 Analysis Period */
SELECT
    MIN(OrderDate) AS StartDate,
    MAX(OrderDate) AS EndDate
FROM dbo.vw_PricingAnalytics;


/* 01.3 Core Business Counts */
SELECT
    COUNT(DISTINCT SalesOrderID) AS TotalOrders,
    COUNT(DISTINCT CustomerID) AS TotalCustomers,
    COUNT(DISTINCT ProductID) AS TotalProducts,
    SUM(OrderQty) AS TotalQuantitySold
FROM dbo.vw_PricingAnalytics;


/* 01.4 Missing Values */
SELECT
    SUM(CASE WHEN ProductCategory IS NULL THEN 1 ELSE 0 END)
        AS MissingProductCategory,
    SUM(CASE WHEN ProductSubcategory IS NULL THEN 1 ELSE 0 END)
        AS MissingProductSubcategory,
    SUM(CASE WHEN TerritoryName IS NULL THEN 1 ELSE 0 END)
        AS MissingTerritory,
    SUM(CASE WHEN VendorID IS NULL THEN 1 ELSE 0 END)
        AS MissingVendor
FROM dbo.vw_PricingAnalytics;


/* 01.5 Revenue Validation */
SELECT
    SUM(GrossRevenue) AS GrossRevenueBeforeDiscount,
    SUM(LineTotal) AS RevenueAfterDiscount,
    SUM(GrossRevenue - LineTotal) AS DiscountImpact
FROM dbo.vw_PricingAnalytics;


/* 01.6 Discount Values */
SELECT
    UnitPriceDiscount,
    COUNT(*) AS TransactionLines
FROM dbo.vw_PricingAnalytics
GROUP BY UnitPriceDiscount
ORDER BY UnitPriceDiscount;


/* ============================================================
   02 — SALES & PROFITABILITY ANALYSIS
   ============================================================ */

/* 02.1 Overall Revenue, Cost, Profit and Margin */
SELECT
    SUM(LineTotal) AS TotalRevenue,
    SUM(Cost) AS TotalCost,
    SUM(Profit) AS TotalProfit,
    CAST(
        SUM(Profit) / NULLIF(SUM(LineTotal), 0) * 100
        AS DECIMAL(10,2)
    ) AS MarginPercent
FROM dbo.vw_PricingAnalytics;


/* 02.2 Monthly Revenue and Profit */
SELECT
    YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
    FORMAT(OrderDate, 'yyyy-MM') AS YearMonth,
    SUM(LineTotal) AS TotalRevenue,
    SUM(Profit) AS TotalProfit
FROM dbo.vw_PricingAnalytics
GROUP BY
    YEAR(OrderDate),
    MONTH(OrderDate),
    FORMAT(OrderDate, 'yyyy-MM')
ORDER BY OrderYear, OrderMonth;


/* 02.3 Revenue and Profit by Product Category */
SELECT
    ProductCategory,
    SUM(LineTotal) AS TotalRevenue,
    SUM(Cost) AS TotalCost,
    SUM(Profit) AS TotalProfit,
    CAST(
        SUM(Profit) / NULLIF(SUM(LineTotal), 0) * 100
        AS DECIMAL(10,2)
    ) AS MarginPercent
FROM dbo.vw_PricingAnalytics
GROUP BY ProductCategory
ORDER BY TotalRevenue DESC;


/* 02.4 Category Contribution to Revenue */
SELECT
    ProductCategory,
    SUM(LineTotal) AS CategoryRevenue,
    CAST(
        SUM(LineTotal) /
        NULLIF(
            (SELECT SUM(LineTotal)
             FROM dbo.vw_PricingAnalytics), 0
        ) * 100
        AS DECIMAL(10,2)
    ) AS RevenueContributionPercent
FROM dbo.vw_PricingAnalytics
GROUP BY ProductCategory
ORDER BY CategoryRevenue DESC;


/* 02.5 Category Contribution to Profit */
SELECT
    ProductCategory,
    SUM(Profit) AS CategoryProfit,
    CAST(
        SUM(Profit) /
        NULLIF(
            (SELECT SUM(Profit)
             FROM dbo.vw_PricingAnalytics), 0
        ) * 100
        AS DECIMAL(10,2)
    ) AS ProfitContributionPercent
FROM dbo.vw_PricingAnalytics
GROUP BY ProductCategory
ORDER BY CategoryProfit DESC;


/* 02.6 Revenue by Territory */
SELECT
    TerritoryName,
    COUNT(DISTINCT CustomerID) AS TotalCustomers,
    COUNT(DISTINCT SalesOrderID) AS TotalOrders,
    SUM(LineTotal) AS TotalRevenue,
    SUM(Profit) AS TotalProfit,
    CAST(
        SUM(Profit) / NULLIF(SUM(LineTotal), 0) * 100
        AS DECIMAL(10,2)
    ) AS MarginPercent
FROM dbo.vw_PricingAnalytics
GROUP BY TerritoryName
ORDER BY TotalRevenue DESC;


/* 02.7 Average Order Value */
SELECT
    CAST(
        SUM(LineTotal) /
        NULLIF(COUNT(DISTINCT SalesOrderID), 0)
        AS DECIMAL(10,2)
    ) AS AverageOrderValue
FROM dbo.vw_PricingAnalytics;


/* ============================================================
   03 — PRODUCT PERFORMANCE
   ============================================================ */

/* 03.1 Product Performance */
SELECT
    ProductID,
    ProductName,
    ProductCategory,
    ProductSubcategory,
    SUM(OrderQty) AS QuantitySold,
    SUM(LineTotal) AS TotalRevenue,
    SUM(Cost) AS TotalCost,
    SUM(Profit) AS TotalProfit,
    CAST(
        SUM(LineTotal) / NULLIF(SUM(OrderQty), 0)
        AS DECIMAL(10,2)
    ) AS AverageSellingPrice,
    CAST(
        SUM(Cost) / NULLIF(SUM(OrderQty), 0)
        AS DECIMAL(10,2)
    ) AS AverageUnitCost,
    CAST(
        SUM(Profit) / NULLIF(SUM(LineTotal), 0) * 100
        AS DECIMAL(10,2)
    ) AS MarginPercent
FROM dbo.vw_PricingAnalytics
GROUP BY
    ProductID,
    ProductName,
    ProductCategory,
    ProductSubcategory
ORDER BY TotalRevenue DESC;


/* 03.2 Top 10 Products by Revenue */
SELECT TOP 10
    ProductID,
    ProductName,
    ProductCategory,
    SUM(LineTotal) AS TotalRevenue,
    SUM(Profit) AS TotalProfit,
    CAST(
        SUM(Profit) / NULLIF(SUM(LineTotal), 0) * 100
        AS DECIMAL(10,2)
    ) AS MarginPercent
FROM dbo.vw_PricingAnalytics
GROUP BY ProductID, ProductName, ProductCategory
ORDER BY TotalRevenue DESC;


/* 03.3 Top 10 Products by Profit */
SELECT TOP 10
    ProductID,
    ProductName,
    ProductCategory,
    SUM(LineTotal) AS TotalRevenue,
    SUM(Profit) AS TotalProfit,
    CAST(
        SUM(Profit) / NULLIF(SUM(LineTotal), 0) * 100
        AS DECIMAL(10,2)
    ) AS MarginPercent
FROM dbo.vw_PricingAnalytics
GROUP BY ProductID, ProductName, ProductCategory
ORDER BY TotalProfit DESC;


/* 03.4 Average Selling Price */
SELECT
    CAST(
        SUM(LineTotal) / NULLIF(SUM(OrderQty), 0)
        AS DECIMAL(10,2)
    ) AS AverageSellingPrice
FROM dbo.vw_PricingAnalytics;


/* 03.5 Average Revenue and Profit per Product */
SELECT
    CAST(
        SUM(LineTotal) /
        NULLIF(COUNT(DISTINCT ProductID), 0)
        AS DECIMAL(10,2)
    ) AS AverageRevenuePerProduct,
    CAST(
        SUM(Profit) /
        NULLIF(COUNT(DISTINCT ProductID), 0)
        AS DECIMAL(10,2)
    ) AS AverageProfitPerProduct
FROM dbo.vw_PricingAnalytics;


/* ============================================================
   04 — CUSTOMER & TERRITORY ANALYSIS
   ============================================================ */

/* 04.1 Customer Performance */
SELECT
    CustomerID,
    TerritoryName,
    COUNT(DISTINCT SalesOrderID) AS TotalOrders,
    SUM(OrderQty) AS TotalQuantity,
    SUM(LineTotal) AS TotalRevenue,
    SUM(Profit) AS TotalProfit,
    CAST(
        SUM(Profit) / NULLIF(SUM(LineTotal), 0) * 100
        AS DECIMAL(10,2)
    ) AS MarginPercent
FROM dbo.vw_PricingAnalytics
GROUP BY CustomerID, TerritoryName
ORDER BY TotalRevenue DESC;


/* 04.2 Top 20 Customers by Revenue */
SELECT TOP 20
    CustomerID,
    COUNT(DISTINCT SalesOrderID) AS TotalOrders,
    SUM(LineTotal) AS TotalRevenue,
    SUM(Profit) AS TotalProfit,
    CAST(
        SUM(Profit) / NULLIF(SUM(LineTotal), 0) * 100
        AS DECIMAL(10,2)
    ) AS MarginPercent
FROM dbo.vw_PricingAnalytics
GROUP BY CustomerID
ORDER BY TotalRevenue DESC;


/* 04.3 Average Revenue and Profit per Customer */
SELECT
    CAST(
        SUM(LineTotal) /
        NULLIF(COUNT(DISTINCT CustomerID), 0)
        AS DECIMAL(10,2)
    ) AS AverageRevenuePerCustomer,
    CAST(
        SUM(Profit) /
        NULLIF(COUNT(DISTINCT CustomerID), 0)
        AS DECIMAL(10,2)
    ) AS AverageProfitPerCustomer
FROM dbo.vw_PricingAnalytics;


/* 04.4 Territory Performance */
SELECT
    TerritoryName,
    COUNT(DISTINCT CustomerID) AS TotalCustomers,
    COUNT(DISTINCT SalesOrderID) AS TotalOrders,
    SUM(LineTotal) AS TotalRevenue,
    SUM(Profit) AS TotalProfit,
    CAST(
        SUM(Profit) / NULLIF(SUM(LineTotal), 0) * 100
        AS DECIMAL(10,2)
    ) AS MarginPercent
FROM dbo.vw_PricingAnalytics
GROUP BY TerritoryName
ORDER BY TotalRevenue DESC;


/* ============================================================
   05 — PRICING & MARGIN ANALYSIS
   ============================================================ */

/* 05.1 Pricing and Cost by Product */
SELECT
    ProductID,
    ProductName,
    ProductCategory,
    ProductSubcategory,
    SUM(OrderQty) AS QuantitySold,
    CAST(
        SUM(LineTotal) / NULLIF(SUM(OrderQty), 0)
        AS DECIMAL(10,2)
    ) AS AverageSellingPrice,
    CAST(
        SUM(Cost) / NULLIF(SUM(OrderQty), 0)
        AS DECIMAL(10,2)
    ) AS AverageUnitCost,
    SUM(LineTotal) AS TotalRevenue,
    SUM(Cost) AS TotalCost,
    SUM(Profit) AS TotalProfit,
    CAST(
        SUM(Profit) / NULLIF(SUM(LineTotal), 0) * 100
        AS DECIMAL(10,2)
    ) AS MarginPercent
FROM dbo.vw_PricingAnalytics
GROUP BY
    ProductID,
    ProductName,
    ProductCategory,
    ProductSubcategory
ORDER BY MarginPercent ASC;


/* 05.2 Products Below 10% Margin */
SELECT
    ProductID,
    ProductName,
    ProductCategory,
    ProductSubcategory,
    SUM(OrderQty) AS QuantitySold,
    SUM(LineTotal) AS TotalRevenue,
    SUM(Cost) AS TotalCost,
    SUM(Profit) AS TotalProfit,
    CAST(
        SUM(Profit) / NULLIF(SUM(LineTotal), 0) * 100
        AS DECIMAL(10,2)
    ) AS MarginPercent
FROM dbo.vw_PricingAnalytics
GROUP BY
    ProductID,
    ProductName,
    ProductCategory,
    ProductSubcategory
HAVING
    SUM(Profit) /
    NULLIF(SUM(LineTotal), 0) < 0.10
ORDER BY MarginPercent ASC;


/* 05.3 Count of Products Below 10% Margin */
SELECT
    COUNT(*) AS ProductsBelow10PercentMargin
FROM
(
    SELECT
        ProductID,
        SUM(LineTotal) AS TotalRevenue,
        SUM(Profit) AS TotalProfit
    FROM dbo.vw_PricingAnalytics
    GROUP BY ProductID
    HAVING
        SUM(Profit) /
        NULLIF(SUM(LineTotal), 0) < 0.10
) AS ProductMargins;


/* 05.4 Average Discount */
SELECT
    CAST(
        AVG(UnitPriceDiscount) * 100
        AS DECIMAL(10,2)
    ) AS AverageDiscountPercent
FROM dbo.vw_PricingAnalytics;


/* 05.5 Discount by Product Category */
SELECT
    ProductCategory,
    CAST(
        AVG(UnitPriceDiscount) * 100
        AS DECIMAL(10,2)
    ) AS AverageDiscountPercent
FROM dbo.vw_PricingAnalytics
GROUP BY ProductCategory
ORDER BY AverageDiscountPercent DESC;


/* 05.6 High-Revenue / Low-Margin Products */
SELECT
    ProductID,
    ProductName,
    ProductCategory,
    SUM(LineTotal) AS TotalRevenue,
    SUM(Profit) AS TotalProfit,
    CAST(
        SUM(Profit) / NULLIF(SUM(LineTotal), 0) * 100
        AS DECIMAL(10,2)
    ) AS MarginPercent
FROM dbo.vw_PricingAnalytics
GROUP BY ProductID, ProductName, ProductCategory
HAVING
    SUM(LineTotal) > 100000
    AND
    SUM(Profit) /
    NULLIF(SUM(LineTotal), 0) < 0.10
ORDER BY TotalRevenue DESC;


/* ============================================================
   06 — ADVANCED PRODUCT RANKING
   ============================================================ */

/* 06.1 Top 5 Products by Revenue Within Each Category */
WITH ProductPerformance AS
(
    SELECT
        ProductID,
        ProductName,
        ProductCategory,
        SUM(OrderQty) AS QuantitySold,
        SUM(LineTotal) AS Revenue,
        SUM(Profit) AS Profit,
        CAST(
            SUM(Profit) /
            NULLIF(SUM(LineTotal), 0) * 100
            AS DECIMAL(10,2)
        ) AS MarginPercent
    FROM dbo.vw_PricingAnalytics
    GROUP BY ProductID, ProductName, ProductCategory
),
RankedProducts AS
(
    SELECT
        *,
        RANK() OVER
        (
            PARTITION BY ProductCategory
            ORDER BY Revenue DESC
        ) AS RevenueRank
    FROM ProductPerformance
)
SELECT
    ProductCategory,
    RevenueRank,
    ProductID,
    ProductName,
    QuantitySold,
    Revenue,
    Profit,
    MarginPercent
FROM RankedProducts
WHERE RevenueRank <= 5
ORDER BY ProductCategory, RevenueRank;


/* 06.2 Top 5 Products by Profit Within Each Category */
WITH ProductPerformance AS
(
    SELECT
        ProductID,
        ProductName,
        ProductCategory,
        SUM(LineTotal) AS Revenue,
        SUM(Profit) AS Profit,
        CAST(
            SUM(Profit) /
            NULLIF(SUM(LineTotal), 0) * 100
            AS DECIMAL(10,2)
        ) AS MarginPercent
    FROM dbo.vw_PricingAnalytics
    GROUP BY ProductID, ProductName, ProductCategory
),
RankedProducts AS
(
    SELECT
        *,
        RANK() OVER
        (
            PARTITION BY ProductCategory
            ORDER BY Profit DESC
        ) AS ProfitRank
    FROM ProductPerformance
)
SELECT
    ProductCategory,
    ProfitRank,
    ProductID,
    ProductName,
    Revenue,
    Profit,
    MarginPercent
FROM RankedProducts
WHERE ProfitRank <= 5
ORDER BY ProductCategory, ProfitRank;


/* 06.3 Category Revenue Concentration */
WITH CategoryRevenue AS
(
    SELECT
        ProductCategory,
        SUM(LineTotal) AS Revenue
    FROM dbo.vw_PricingAnalytics
    GROUP BY ProductCategory
)
SELECT
    ProductCategory,
    Revenue,
    CAST(
        Revenue /
        NULLIF(SUM(Revenue) OVER (), 0) * 100
        AS DECIMAL(10,2)
    ) AS RevenueSharePercent,
    RANK() OVER
    (
        ORDER BY Revenue DESC
    ) AS RevenueRank
FROM CategoryRevenue
ORDER BY RevenueRank;


/* 06.4 High-Revenue / Low-Margin Ranking */
WITH ProductPerformance AS
(
    SELECT
        ProductID,
        ProductName,
        ProductCategory,
        SUM(LineTotal) AS Revenue,
        SUM(Cost) AS Cost,
        SUM(Profit) AS Profit,
        CAST(
            SUM(Profit) /
            NULLIF(SUM(LineTotal), 0) * 100
            AS DECIMAL(10,2)
        ) AS MarginPercent
    FROM dbo.vw_PricingAnalytics
    GROUP BY ProductID, ProductName, ProductCategory
),
LowMarginProducts AS
(
    SELECT *
    FROM ProductPerformance
    WHERE MarginPercent < 10
)
SELECT
    ProductID,
    ProductName,
    ProductCategory,
    Revenue,
    Cost,
    Profit,
    MarginPercent,
    RANK() OVER
    (
        ORDER BY Revenue DESC
    ) AS RevenueRankAmongLowMarginProducts
FROM LowMarginProducts
ORDER BY RevenueRankAmongLowMarginProducts;


/* ============================================================
   END OF SCRIPT
   ============================================================ */
