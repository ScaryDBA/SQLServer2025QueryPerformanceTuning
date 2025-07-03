--Listing 8-1
CREATE OR ALTER PROCEDURE dbo.WorkOrder
AS
SELECT wo.WorkOrderID,
       wo.ProductID,
       wo.StockedQty
FROM Production.WorkOrder AS wo
WHERE wo.StockedQty
BETWEEN 500 AND 700;


EXEC dbo.WorkOrder;


--Listing 8-2
CREATE INDEX IX_Test ON Production.WorkOrder (StockedQty, ProductID);



--Lising 8-3
DROP INDEX Production.WorkOrder.IX_Test;



--Listing 8-4
CREATE OR ALTER PROCEDURE dbo.WorkOrderAll
AS
--intentionally using SELECT * as an example
SELECT *
FROM Production.WorkOrder AS wo;
GO



--Listing 8-5
CREATE EVENT SESSION [QueryAndRecompile]
ON SERVER
    ADD EVENT sqlserver.rpc_completed
    (WHERE ([sqlserver].[database_name] = N'AdventureWorks')),
    ADD EVENT sqlserver.rpc_starting
    (WHERE ([sqlserver].[database_name] = N'AdventureWorks')),
    ADD EVENT sqlserver.sp_statement_completed
    (WHERE ([sqlserver].[database_name] = N'AdventureWorks')),
    ADD EVENT sqlserver.sp_statement_starting
    (WHERE ([sqlserver].[database_name] = N'AdventureWorks')),
    ADD EVENT sqlserver.sql_batch_completed
    (WHERE ([sqlserver].[database_name] = N'AdventureWorks')),
    ADD EVENT sqlserver.sql_batch_starting
    (WHERE ([sqlserver].[database_name] = N'AdventureWorks')),
    ADD EVENT sqlserver.sql_statement_completed
    (WHERE ([sqlserver].[database_name] = N'AdventureWorks')),
    ADD EVENT sqlserver.sql_statement_recompile
    (WHERE ([sqlserver].[database_name] = N'AdventureWorks')),
    ADD EVENT sqlserver.sql_statement_starting
    (WHERE ([sqlserver].[database_name] = N'AdventureWorks'))
    ADD TARGET package0.event_file
    (SET filename = N'QueryAndRecompile')
WITH
(
    TRACK_CAUSALITY = ON
);


--Listing 8-6
EXEC dbo.WorkOrderAll;
GO
CREATE INDEX IX_Test ON Production.WorkOrder(StockedQty,ProductID);
GO
EXEC dbo.WorkOrderAll; --After creation of index IX_Test


--Listing 8-7
SELECT dxmv.map_value
FROM sys.dm_xe_map_values AS dxmv
WHERE dxmv.name = 'statement_recompile_cause';


--Listing 8-8
CREATE OR ALTER PROC dbo.RecompileTable
AS
CREATE TABLE dbo.ProcTest1
(
    C1 INT
);
SELECT *
FROM dbo.ProcTest1;
DROP TABLE dbo.ProcTest1;
GO

--run twice
exec dbo.RecompileTable;


--Listing 8-9
CREATE OR ALTER PROC dbo.RecompileProc
AS
CREATE TABLE #TempTable (C1 INT);
INSERT INTO #TempTable (C1)
VALUES (42);
GO

--execute twice
exec dbo.RecompileProc;



--Listing 8-10
CREATE OR ALTER PROC dbo.TempTable
AS
--All statements are compiled initially
CREATE TABLE #MyTempTable
(
    ID INT,
    Dsc NVARCHAR(50)
);
--This statement must be recompiled
INSERT INTO #MyTempTable
(
    ID,
    Dsc
)
SELECT pm.ProductModelID,
       pm.Name
FROM Production.ProductModel AS pm;
--This statement must be recompiled
SELECT mtt.ID,
       mtt.Dsc
FROM #MyTempTable AS mtt;
CREATE CLUSTERED INDEX iTest ON #MyTempTable (ID);
--Creating index causes a recompile
SELECT mtt.ID,
       mtt.Dsc
FROM #MyTempTable AS mtt;
CREATE TABLE #t2
(
    c1 INT
);
--Recompile from a new table
SELECT c1
FROM #t2;
GO

EXEC dbo.TempTable;


--Listing 8-11
IF
(
    SELECT OBJECT_ID('dbo.Test1')
) IS NOT NULL
    DROP TABLE dbo.Test1;
GO
CREATE TABLE dbo.Test1
(
    C1 INT,
    C2 CHAR(50)
);
INSERT INTO dbo.Test1
VALUES
(1, '2');
CREATE NONCLUSTERED INDEX IndexOne ON dbo.Test1 (C1);
GO
--Create a stored procedure referencing the previous table
CREATE OR ALTER PROC dbo.TestProc
AS
SELECT t.C1,
       t.C2
FROM dbo.Test1 AS t
WHERE t.C1 = 1
OPTION (KEEPFIXED PLAN);
GO
--First execution of stored procedure with 1 row in the table
EXEC dbo.TestProc; --First execution
--Add many rows to the table to cause statistics change
WITH Nums
AS (SELECT 1 AS n
    UNION ALL
    SELECT Nums.n + 1
    FROM Nums
    WHERE Nums.n < 1000)
INSERT INTO dbo.Test1
(
    C1,
    C2
)
SELECT 1,
       Nums.n
FROM Nums
OPTION (MAXRECURSION 1000);
GO
--Reexecute the stored procedure with a change in statistics
EXEC dbo.TestProc;


--Listing 8-12
EXEC sys.sp_autostats 'dbo.Test1', 'OFF';


--Listing 8-13
DECLARE @count INT;
CREATE TABLE #TempTable
(
    C1 INT PRIMARY KEY
);
SET @count = 1;
WHILE @count < 8
BEGIN
    INSERT INTO #TempTable
    (
        C1
    )
    VALUES
    (@count);
    SELECT tt.C1
    FROM #TempTable AS tt
        JOIN Production.ProductModel AS pm
            ON pm.ProductModelID = tt.C1
    WHERE tt.C1 < @count;
    SET @count += 1;
END;
DROP TABLE #TempTable;


--Listing 8-14
DECLARE @TempTable TABLE
(
    C1 INT PRIMARY KEY
);
DECLARE @Count TINYINT = 1;
WHILE @Count < 8
BEGIN
    INSERT INTO @TempTable
    (
        C1
    )
    VALUES
    (@Count );
    SELECT tt.C1
    FROM @TempTable AS tt
       JOIN Production.ProductModel AS pm
       ON pm.ProductModelID = tt.C1
       WHERE tt.C1 < @Count;
    SET @Count += 1;
END;


--Listing 8-15
CREATE OR ALTER PROC dbo.OuterProc
AS
CREATE TABLE #Scope
(ID INT PRIMARY KEY,
ScopeName VARCHAR(50));
EXEC dbo.InnerProc
GO
CREATE OR ALTER PROC dbo.InnerProc
AS
INSERT INTO #Scope
(
    ID,
    ScopeName
)
VALUES
(   1,   -- ID - int
    'InnerProc' -- ScopeName - varchar(50)
    );
SELECT s.ScopeName
FROM #Scope AS s;
GO



--Listing 8-16
CREATE OR ALTER PROC dbo.TestProc
AS
SELECT 'a' + NULL + 'b'; --1st
SET CONCAT_NULL_YIELDS_NULL OFF;
SELECT 'a' + NULL + 'b'; --2nd
SET ANSI_NULLS OFF;
SELECT 'a' + NULL + 'b';--3rd
GO
EXEC dbo.TestProc; --First execution
EXEC dbo.TestProc; --Second execution


--Listing 8-17
CREATE OR ALTER PROCEDURE dbo.CustomerList @CustomerID INT
AS
SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       sod.OrderQty,
       sod.LineTotal
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.CustomerID >= @CustomerID
OPTION (OPTIMIZE FOR (@CustomerID = 1));


--Listing 8-18
EXEC dbo.CustomerList @CustomerID = 7920 WITH RECOMPILE;
EXEC dbo.CustomerList @CustomerID = 30118 WITH RECOMPILE;



--Listing 8-19
CREATE OR ALTER PROCEDURE dbo.CustomerList @CustomerID INT
AS
SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       sod.OrderQty,
       sod.LineTotal
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.CustomerID >= @CustomerID;


--Listing 8-20
sp_create_plan_guide @name = N'MyGuide',
                     @stmt = N'SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       sod.OrderQty,
       sod.LineTotal
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.CustomerID >= @CustomerID;',
                     @type = N'OBJECT',
                     @module_or_batch = N'dbo.CustomerList',
                     @params = NULL,
                     @hints = N'OPTION (OPTIMIZE FOR (@CustomerID = 1))';


EXEC dbo.CustomerList @CustomerID = 0 -- int


--Listing 8-21
SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       sod.OrderQty,
       sod.LineTotal
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.CustomerID >= 1;


--Listing 8-22
EXECUTE sp_create_plan_guide @name = N'MyGoodSQLGuide',
                             @stmt = N'SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       sod.OrderQty,
       sod.LineTotal
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.CustomerID >= 1;',
                             @type = N'SQL',
                             @module_or_batch = NULL,
                             @params = NULL,
                             @hints = N'OPTION  (TABLE HINT(soh,  FORCESEEK))';


DBCC FREEPROCCACHE();


--Listing 8-23
EXECUTE sp_control_plan_guide @operation = 'Drop', @name = N'MyGoodSQLGuide';
EXECUTE sp_control_plan_guide @operation = 'Drop', @name = N'MyGuide';


--Listing 8-24
DECLARE @plan_handle VARBINARY(64),
        @start_offset INT;
SELECT @plan_handle = deqs.plan_handle,
       @start_offset = deqs.statement_start_offset
FROM sys.dm_exec_query_stats AS deqs
    CROSS APPLY sys.dm_exec_sql_text(sql_handle)
    CROSS APPLY sys.dm_exec_text_query_plan(deqs.plan_handle, deqs.statement_start_offset, deqs.statement_end_offset) AS qp
WHERE text LIKE N'SELECT soh.SalesOrderNumber%';
EXECUTE sp_create_plan_guide_from_handle
@name = N'ForcedPlanGuide',
      @plan_handle = @plan_handle,
      @statement_start_offset = @start_offset;
