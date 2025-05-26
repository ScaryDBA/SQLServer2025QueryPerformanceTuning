--Listing 5-1
DROP TABLE IF EXISTS dbo.Test1;
GO
CREATE TABLE dbo.Test1
(
    C1 INT,
    C2 INT IDENTITY
);
SELECT TOP 1500
       IDENTITY(INT, 1, 1) AS n
INTO #Nums
FROM master.dbo.syscolumns AS sC1,
     master.dbo.syscolumns AS sC2;
INSERT INTO dbo.Test1
(
    C1
)
SELECT n
FROM #Nums;
DROP TABLE #Nums;
CREATE NONCLUSTERED INDEX i1 ON dbo.Test1 (C1);



--Listing 5-2
SELECT t.C1,
       t.C2
FROM dbo.Test1 AS t
WHERE t.C1 = 2;
--GO 50


--Listing 5-3
CREATE EVENT SESSION [Statistics]
ON SERVER
    ADD EVENT sqlserver.auto_stats
    (ACTION
     (
         sqlserver.sql_text
     )
     WHERE (sqlserver.database_name = N'AdventureWorks')
    ),
    ADD EVENT sqlserver.sql_batch_completed
    (WHERE (sqlserver.database_name = N'AdventureWorks'));
GO
ALTER EVENT SESSION [Statistics] ON SERVER STATE = START;


--Listing 5-4
INSERT INTO dbo.Test1
(
    C1
)
VALUES
(2  );



--Listing 5-5
SELECT TOP 1500
       IDENTITY(INT, 1, 1) AS n
INTO #Nums
FROM master.dbo.syscolumns AS scl,
     master.dbo.syscolumns AS sC2;
INSERT INTO dbo.Test1
(
    C1
)
SELECT 2
FROM #Nums;
DROP TABLE #Nums;



--Listing 5-6
ALTER DATABASE AdventureWorks SET AUTO_UPDATE_STATISTICS OFF;



--Listing 5-7
ALTER DATABASE AdventureWorks SET AUTO_UPDATE_STATISTICS ON;



--Listing 5-8
DROP TABLE IF EXISTS dbo.Test1;
GO
CREATE TABLE dbo.Test1
(
    Test1_C1 INT IDENTITY,
    Test1_C2 INT
);
INSERT INTO dbo.Test1
(
    Test1_C2
)
VALUES
(1  );
SELECT TOP 10000
       IDENTITY(INT, 1, 1) AS n
INTO #Nums
FROM master.dbo.syscolumns AS scl,
     master.dbo.syscolumns AS sC2;
INSERT INTO dbo.Test1
(
    Test1_C2
)
SELECT 2
FROM #Nums;
GO
CREATE CLUSTERED INDEX i1 ON dbo.Test1 (Test1_C1);
--Create second table with 10001 rows, -- but opposite data distribution
IF
(
    SELECT OBJECT_ID('dbo.Test2')
) IS NOT NULL
    DROP TABLE dbo.Test2;
GO
CREATE TABLE dbo.Test2
(
    Test2_C1 INT IDENTITY,
    Test2_C2 INT
);
INSERT INTO dbo.Test2
(
    Test2_C2
)
VALUES
(2  );
INSERT INTO dbo.Test2
(
    Test2_C2
)
SELECT 1
FROM #Nums;
DROP TABLE #Nums;
GO
CREATE CLUSTERED INDEX il ON dbo.Test2 (Test2_C1);


--Listing 5-9
SELECT DATABASEPROPERTYEX('AdventureWorks', 'IsAutoCreateStatistics');



--Listing 5-10
ALTER DATABASE AdventureWorks SET AUTO_CREATE_STATISTICS ON;


--Listing 5-11
SELECT t1.Test1_C2,
       t2.Test2_C2
FROM dbo.Test1 AS t1
    JOIN dbo.Test2 AS t2
        ON t1.Test1_C2 = t2.Test2_C2
WHERE t1.Test1_C2 = 2;
GO 50

--Listing 5-12
SELECT s.name,
       s.auto_created,
       s.user_created
FROM sys.stats AS s
WHERE object_id = OBJECT_ID('Test1');



--Listing 5-13
SELECT t1.Test1_C2,
       t2.Test2_C2
FROM dbo.Test1 AS t1
    JOIN dbo.Test2 AS t2
        ON t1.Test1_C2 = t2.Test2_C2
WHERE t1.Test1_C2 = 1;


--Listing 5-14
ALTER DATABASE AdventureWorks SET AUTO_CREATE_STATISTICS OFF;



--Listing 5-15
DROP TABLE IF EXISTS dbo.Test1;
GO
CREATE TABLE dbo.Test1
(
    C1 INT,
    C2 INT IDENTITY
);
INSERT INTO dbo.Test1
(
    C1
)
VALUES
(1  );
SELECT TOP 10000
       IDENTITY(INT, 1, 1) AS n
INTO #Nums
FROM master.dbo.syscolumns sc1,
     master.dbo.syscolumns sc2;
INSERT INTO dbo.Test1
(
    C1
)
SELECT 2
FROM #Nums;
DROP TABLE #Nums;
CREATE NONCLUSTERED INDEX FirstIndex ON dbo.Test1 (C1);



--Listing 5-16
DBCC SHOW_STATISTICS(Test1, FirstIndex);



--Listing 5-17
SELECT 1.0 / COUNT(DISTINCT C1)
FROM dbo.Test1;



--Listing 5-18
DBCC SHOW_STATISTICS('Sales.SalesOrderDetail', 'IX_SalesOrderDetail_ProductID');



--LIsting 5-19
CREATE EVENT SESSION [CardinalityEstimation]
ON SERVER
    ADD EVENT sqlserver.auto_stats
    (WHERE ([sqlserver].[database_name] = N'AdventureWorks')),
    ADD EVENT sqlserver.query_optimizer_estimate_cardinality
    (WHERE ([sqlserver].[database_name] = N'AdventureWorks')),
    ADD EVENT sqlserver.sql_batch_completed
    (WHERE ([sqlserver].[database_name] = N'AdventureWorks')),
    ADD EVENT sqlserver.sql_batch_starting
    (WHERE ([sqlserver].[database_name] = N'AdventureWorks'))
    ADD TARGET package0.event_file
    (SET filename = N'cardinalityestimation')
WITH
(
    TRACK_CAUSALITY = ON
);



--Listing 5-20
SELECT so.Description,
       p.Name AS ProductName,
       p.ListPrice,
       p.Size,
       pv.AverageLeadTime,
       pv.MaxOrderQty,
       v.Name AS VendorName
FROM Sales.SpecialOffer AS so
    JOIN Sales.SpecialOfferProduct AS sop
        ON sop.SpecialOfferID = so.SpecialOfferID
    JOIN Production.Product AS p
        ON p.ProductID = sop.ProductID
    JOIN Purchasing.ProductVendor AS pv
        ON pv.ProductID = p.ProductID
    JOIN Purchasing.Vendor AS v
        ON v.BusinessEntityID = pv.BusinessEntityID
WHERE so.DiscountPct > .15;



--Listing 5-21
SELECT p.Name,
       p.Class
FROM Production.Product AS p
WHERE p.Color = 'Red'
      AND p.DaysToManufacture > 15;



--Listing 5-22
SELECT s.name,
       s.auto_created,
       s.user_created,
       s.filter_definition,
       sc.column_id,
       c.name AS ColumnName
FROM sys.stats AS s
    JOIN sys.stats_columns AS sc
        ON sc.stats_id = s.stats_id
           AND sc.object_id = s.object_id
    JOIN sys.columns AS c
        ON c.column_id = sc.column_id
           AND c.object_id = s.object_id
WHERE s.object_id = OBJECT_ID('Production.Product');


--Listing 5-23
CREATE NONCLUSTERED INDEX FirstIndex
ON dbo.Test1 (
                 C1,
                 C2
             )
WITH (DROP_EXISTING = ON);



--Listing 5-24
CREATE INDEX IX_Test ON Sales.SalesOrderHeader (PurchaseOrderNumber);

DBCC SHOW_STATISTICS('Sales.SalesOrderHeader', 'IX_Test');



--Listing 5-25
CREATE INDEX IX_Test
ON Sales.SalesOrderHeader (PurchaseOrderNumber)
WHERE PurchaseOrderNumber IS NOT NULL
WITH (DROP_EXISTING = ON);



--Listing 5-26
DROP INDEX Sales.SalesOrderHeader.IX_Test;



--Listing 5-27
ALTER DATABASE AdventureWorks SET COMPATIBILITY_LEVEL = 110;



--Listing 5-28
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = ON;



--Listing 5-29
SELECT p.Name,
       p.Class
FROM Production.Product AS p
WHERE p.Color = 'Red'
      AND p.DaysToManufacture > 15
OPTION (USE HINT ('FORCE_LEGACY_CARDINALITY_ESTIMATION'));



--Listing 5-30
ALTER DATABASE AdventureWorks SET AUTO_CREATE_STATISTICS OFF;



--Listing 5-31
ALTER DATABASE AdventureWorks SET AUTO_UPDATE_STATISTICS OFF;



--Listing 5-32
ALTER DATABASE AdventureWorks SET AUTO_UPDATE_STATISTICS_ASYNC ON;



--Listing 5-33
USE AdventureWorks;
EXEC sp_autostats
    'HumanResources.Department',
    'OFF';


--lIsting 5-34
EXEC sp_autostats
    'HumanResources.Department',
    'OFF',
    AK_Department_Name;



--Listing 5-35
EXEC sp_autostats 'HumanResources.Department';




--Listing 5-36
EXEC sp_autostats
    'HumanResources.Department',
    'ON';
EXEC sp_autostats
    'HumanResources.Department',
    'ON',
    AK_Department_Name;



--Listing 5-37
UPDATE STATISTICS dbo.bigProduct
WITH RESAMPLE,
     INCREMENTAL = ON;




--Listing 5-38
ALTER DATABASE AdventureWorks SET AUTO_CREATE_STATISTICS OFF;
ALTER DATABASE AdventureWorks SET AUTO_UPDATE_STATISTICS OFF;
GO
DROP TABLE IF EXISTS dbo.Test1;
GO
CREATE TABLE dbo.Test1
(
    C1 INT,
    C2 INT,
    C3 CHAR(50)
);
INSERT INTO dbo.Test1
(
    C1,
    C2,
    C3
)
VALUES
(51, 1, 'C3'),
(52, 1, 'C3');
CREATE NONCLUSTERED INDEX iFirstIndex ON dbo.Test1 (C1, C2);
SELECT TOP 10000
       IDENTITY(INT, 1, 1) AS n
INTO #Nums
FROM master.dbo.syscolumns AS scl,
     master.dbo.syscolumns AS sC2;
INSERT INTO dbo.Test1
(
    C1,
    C2,
    C3
)
SELECT n % 50,
       n,
       'C3'
FROM #Nums;
DROP TABLE #Nums;


--Listing 5-39
SELECT t.C1,
       t.C2,
       t.C3
FROM dbo.Test1 AS t
WHERE t.C2 = 1;
go 50


--Listing 5-40
CREATE STATISTICS Stats1 ON Test1(C2);



--Listing 5-41
DECLARE @Planhandle VARBINARY(64);
SELECT @Planhandle = deqs.plan_handle
FROM sys.dm_exec_query_stats AS deqs
    CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.text = 'SELECT  *
FROM    dbo.Test1
WHERE   C2 = 1;';
IF @Planhandle IS NOT NULL
BEGIN
    DBCC FREEPROCCACHE(@Planhandle);
END;



--Listing 5-42
DBCC SHOW_STATISTICS (Test1, iFirstIndex);



--Listing 5-43
SELECT C1,
       C2,
       C3
FROM dbo.Test1
WHERE C1 = 51;
go 50



--Listing 5-44
UPDATE STATISTICS Test1 iFirstIndex
WITH FULLSCAN;


--Listing 5-45
ALTER DATABASE AdventureWorks SET AUTO_CREATE_STATISTICS ON;
ALTER DATABASE AdventureWorks SET AUTO_UPDATE_STATISTICS ON;
