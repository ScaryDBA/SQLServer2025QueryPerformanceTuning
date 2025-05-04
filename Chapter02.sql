--Listing 2-1
--NOTE: This intentionally generates an error

CREATE TABLE dbo.Example
(
    Col1 INT
);
INSERT INTO dbo.Example
(
    Col1
)
VALUES
(1  );
SELECT e.Col1
FORM dbo.Example AS e; -- Generates an error because of 'FORM'



--Listing 2-2

SELECT soh.AccountNumber,
       soh.OrderDate,
       soh.PurchaseOrderNumber,
       soh.SalesOrderNumber
FROM Sales.SalesOrderHeader AS soh
WHERE soh.SalesOrderID
BETWEEN 62500 AND 62550;



--Listing 2-3

SELECT soh.SalesOrderNumber,
       sod.OrderQty,
       sod.LineTotal,
       sod.UnitPrice,
       sod.UnitPriceDiscount,
       p.Name AS ProductName,
       p.ProductNumber,
       ps.Name AS ProductSubCategoryName,
       pc.Name AS ProductCategoryName
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Production.Product AS p
        ON sod.ProductID = p.ProductID
    JOIN Production.ProductModel AS pm
        ON p.ProductModelID = pm.ProductModelID
    JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE soh.CustomerID = 29658;



--Listing 2-4

SELECT deqoi.counter,
       deqoi.occurrence,
       deqoi.value
FROM sys.dm_exec_query_optimizer_info AS deqoi;


--Listing 2-5

USE master;
EXEC sp_configure 'show advanced option', '1';
RECONFIGURE;
EXEC sp_configure 'max degree of parallelism', 2;
RECONFIGURE;


--Listing 2-6
--Can't actually execute w/o creating the table defined

SELECT e.ID,
       e.SomeValue
FROM dbo.Example AS e
WHERE e.ID = 42
OPTION (MAXDOP 2);


--Listing 2-7

USE master;
EXEC sp_configure 'show advanced option', '1';
RECONFIGURE;
EXEC sp_configure 'cost threshold for parallelism', 35;
RECONFIGURE;


--Listing 2-8

WITH XMLNAMESPACES
(
    DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
)
, TextPlans
AS (SELECT CAST(detqp.query_plan AS XML) AS QueryPlan,
           detqp.dbid
    FROM sys.dm_exec_query_stats AS deqs
        CROSS APPLY sys.dm_exec_text_query_plan(
                                                   deqs.plan_handle,
                                                   deqs.statement_start_offset,
                                                   deqs.statement_end_offset
                                               ) AS detqp ),
  QueryPlans
AS (SELECT RelOp.pln.value(N'@EstimatedTotalSubtreeCost', N'float') AS EstimatedCost,
           RelOp.pln.value(N'@NodeId', N'integer') AS NodeId,
           tp.dbid,
           tp.QueryPlan
    FROM TextPlans AS tp
        CROSS APPLY tp.QueryPlan.nodes(N'//RelOp') RelOp(pln) )
SELECT qp.EstimatedCost
FROM QueryPlans AS qp
WHERE qp.NodeId = 0;