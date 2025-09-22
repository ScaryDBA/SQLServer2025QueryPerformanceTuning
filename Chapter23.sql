--Listing 23-1
CREATE NONCLUSTERED INDEX AK_Product_Name
ON Production.Product (NAME ASC)
WITH (DROP_EXISTING = ON);



--Listing 23-2
SELECT DISTINCT
       (p.NAME)
FROM Production.Product AS p;


--Listing 23-3
CREATE UNIQUE NONCLUSTERED INDEX AK_Product_Name
ON Production.Product (NAME ASC)
WITH (DROP_EXISTING = ON);


--Listing 23-4
DROP TABLE IF EXISTS dbo.Test1;
GO
CREATE TABLE dbo.Test1
(
    C1 INT,
    C2 INT CHECK (C2
                  BETWEEN 10 AND 20
                 )
);
INSERT INTO dbo.Test1
VALUES
(11, 12);
GO
DROP TABLE IF EXISTS dbo.Test2;
GO
CREATE TABLE dbo.Test2
(
    C1 INT,
    C2 INT
);
INSERT INTO dbo.Test2
VALUES
(101, 102);


--Listing 23-5
SELECT T1.C1,
       T1.C2,
       T2.C2
FROM dbo.Test1 AS T1
    JOIN dbo.Test2 AS T2
        ON T1.C1 = T2.C2
           AND T1.C2 = 20;
GO
SELECT T1.C1,
       T1.C2,
       T2.C2
FROM dbo.Test1 AS T1
    JOIN dbo.Test2 AS T2
        ON T1.C1 = T2.C2
           AND T1.C2 = 30;



--Listing 23-6
WITH XMLNAMESPACES
(
    DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
)
, QueryStore
AS (SELECT CAST(qsp.query_plan AS XML) AS QueryPlan
    FROM sys.query_store_plan AS qsp),
  QueryPlans
AS (SELECT RelOp.pln.value(N'@EstimatedTotalSubtreeCost', N'float') AS EstimatedCost,
           RelOp.pln.value(N'@NodeId', N'integer') AS NodeId,
           qs.QueryPlan
    FROM QueryStore AS qs
        CROSS APPLY qs.queryplan.nodes(N'//RelOp') RelOp(pln) )
SELECT qp.EstimatedCost
FROM QueryPlans AS qp
WHERE qp.NodeId = 0;


--Listing 23-7
SELECT p.ProductID,
       p.Name,
       p.ProductNumber,
       p.SafetyStockLevel,
       p.ReorderPoint,
       p.StandardCost,
       p.ListPrice,
       p.Size,
       p.DaysToManufacture,
       p.ProductLine
FROM Production.Product AS p
WHERE p.NAME LIKE '%Caps';


--Listing 23-8
SELECT soh.SalesOrderNumber
FROM Sales.SalesOrderHeader AS soh
WHERE 'SO5' = LEFT(SalesOrderNumber, 3);
SELECT soh.SalesOrderNumber
FROM Sales.SalesOrderHeader AS soh
WHERE SalesOrderNumber LIKE 'SO5%';
