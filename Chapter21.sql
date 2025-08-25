--Listing 21-1
CREATE OR ALTER FUNCTION dbo.SalesInfo
()
RETURNS @return_variable TABLE
(
    SalesOrderID INT,
    OrderDate DATETIME,
    SalesPersonID INT,
    PurchaseOrderNumber dbo.OrderNumber,
    AccountNumber dbo.AccountNumber,
    ShippingCity NVARCHAR(30)
)
AS
BEGIN;
    INSERT INTO @return_variable
    (
        SalesOrderID,
        OrderDate,
        SalesPersonID,
        PurchaseOrderNumber,
        AccountNumber,
        ShippingCity
    )
    SELECT soh.SalesOrderID,
           soh.OrderDate,
           soh.SalesPersonID,
           soh.PurchaseOrderNumber,
           soh.AccountNumber,
           A.City
    FROM Sales.SalesOrderHeader AS soh
        JOIN Person.ADDRESS AS A
            ON soh.ShipToAddressID = A.AddressID;
    RETURN;
END;
GO
CREATE OR ALTER FUNCTION dbo.SalesDetails
()
RETURNS @return_variable TABLE
(
    SalesOrderID INT,
    SalesOrderDetailID INT,
    OrderQty SMALLINT,
    UnitPrice MONEY
)
AS
BEGIN;
    INSERT INTO @return_variable
    (
        SalesOrderID,
        SalesOrderDetailID,
        OrderQty,
        UnitPrice
    )
    SELECT sod.SalesOrderID,
           sod.SalesOrderDetailID,
           sod.OrderQty,
           sod.UnitPrice
    FROM Sales.SalesOrderDetail AS sod;
    RETURN;
END;
GO
CREATE OR ALTER FUNCTION dbo.CombinedSalesInfo
()
RETURNS @return_variable TABLE
(
    SalesPersonID INT,
    ShippingCity NVARCHAR(30),
    OrderDate DATETIME,
    PurchaseOrderNumber dbo.OrderNumber,
    AccountNumber dbo.AccountNumber,
    OrderQty SMALLINT,
    UnitPrice MONEY
)
AS
BEGIN;
    INSERT INTO @return_variable
    (
        SalesPersonID,
        ShippingCity,
        OrderDate,
        PurchaseOrderNumber,
        AccountNumber,
        OrderQty,
        UnitPrice
    )
    SELECT si.SalesPersonID,
           si.ShippingCity,
           si.OrderDate,
           si.PurchaseOrderNumber,
           si.AccountNumber,
           sd.OrderQty,
           sd.UnitPrice
    FROM dbo.SalesInfo() AS si
        JOIN dbo.SalesDetails() AS sd
            ON si.SalesOrderID = sd.SalesOrderID;
    RETURN;
END;
GO


--Listing 21-2
ALTER DATABASE SCOPED CONFIGURATION SET INTERLEAVED_EXECUTION_TVF = OFF;
GO
SELECT csi.OrderDate,
       csi.PurchaseOrderNumber,
       csi.AccountNumber,
       csi.OrderQty,
       csi.UnitPrice,
       sp.SalesQuota
FROM dbo.CombinedSalesInfo() AS csi
    JOIN Sales.SalesPerson AS sp
        ON csi.SalesPersonID = sp.BusinessEntityID
WHERE csi.SalesPersonID = 277
      AND csi.ShippingCity = 'Odessa';
GO --50
ALTER DATABASE SCOPED CONFIGURATION SET INTERLEAVED_EXECUTION_TVF = ON;
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
SELECT csi.OrderDate,
       csi.PurchaseOrderNumber,
       csi.AccountNumber,
       csi.OrderQty,
       csi.UnitPrice,
       sp.SalesQuota
FROM dbo.CombinedSalesInfo() AS csi
    JOIN Sales.SalesPerson AS sp
        ON csi.SalesPersonID = sp.BusinessEntityID
WHERE csi.SalesPersonID = 277
      AND csi.ShippingCity = 'Odessa';
GO --50


--Listing 21-3
CREATE OR ALTER FUNCTION dbo.AllSalesInfo
(
    @SalesPersonID INT,
    @ShippingCity VARCHAR(50)
)
RETURNS @return_variable TABLE
(
    SalesPersonID INT,
    ShippingCity NVARCHAR(30),
    OrderDate DATETIME,
    PurchaseOrderNumber dbo.OrderNumber,
    AccountNumber dbo.AccountNumber,
    OrderQty SMALLINT,
    UnitPrice MONEY
)
AS
BEGIN;
    INSERT INTO @return_variable
    (
        SalesPersonID,
        ShippingCity,
        OrderDate,
        PurchaseOrderNumber,
        AccountNumber,
        OrderQty,
        UnitPrice
    )
    SELECT soh.SalesPersonID,
           A.City,
           soh.OrderDate,
           soh.PurchaseOrderNumber,
           soh.AccountNumber,
           sod.OrderQty,
           sod.UnitPrice
    FROM Sales.SalesOrderHeader AS soh
        JOIN Person.ADDRESS AS A
            ON A.AddressID = soh.ShipToAddressID
        JOIN Sales.SalesOrderDetail AS sod
            ON sod.SalesOrderID = soh.SalesOrderID
    WHERE soh.SalesPersonID = @SalesPersonID
          AND A.City = @ShippingCity;
    RETURN;
END;
GO


--Listing 21-4
SELECT asi.OrderDate,
       asi.PurchaseOrderNumber,
       asi.AccountNumber,
       asi.OrderQty,
       asi.UnitPrice,
       sp.SalesQuota
FROM dbo.AllSalesInfo(277, 'Odessa') AS asi
    JOIN Sales.SalesPerson AS sp
        ON asi.SalesPersonID = sp.BusinessEntityID;
--GO 50


--Listing 21-5
CREATE EVENT SESSION MemoryGrant
ON SERVER
    ADD EVENT sqlserver.memory_grant_feedback_loop_disabled
    (WHERE (sqlserver.database_name = N'AdventureWorks')),
    ADD EVENT sqlserver.memory_grant_updated_by_feedback
    (WHERE (sqlserver.database_name = N'AdventureWorks')),
    ADD EVENT sqlserver.sql_batch_completed
    (WHERE (sqlserver.database_name = N'AdventureWorks'))
WITH
(
    TRACK_CAUSALITY = ON
);
GO
ALTER EVENT SESSION MemoryGrant ON SERVER STATE = START;


--Listing 21-6
CREATE OR ALTER PROCEDURE dbo.CostCheck
(@Cost MONEY)
AS
SELECT p.NAME,
       AVG(th.Quantity),
       AVG(th.ActualCost)
FROM dbo.bigTransactionHistory AS th
    JOIN dbo.bigProduct AS p
        ON p.ProductID = th.ProductID
WHERE th.ActualCost = @Cost
GROUP BY p.NAME;


DBCC FREEPROCCACHE();



EXEC dbo.CostCheck @Cost = 0

EXEC dbo.CostCheck @Cost = 325.7354



--Listing 21-7
ALTER DATABASE SCOPED CONFIGURATION SET ROW_MODE_MEMORY_GRANT_FEEDBACK = OFF; --or ON


--Listing 21-8
CREATE EVENT SESSION [CardinalityFeedback]
ON SERVER
    ADD EVENT sqlserver.query_ce_feedback_telemetry(),
    ADD EVENT sqlserver.query_feedback_analysis(),
    ADD EVENT sqlserver.query_feedback_validation(),
    ADD EVENT sqlserver.sql_batch_completed();
GO
ALTER EVENT SESSION CardinalityFeedback ON SERVER STATE = START;


--Listing 21-9
SELECT AddressID,
       AddressLine1,
       AddressLine2
FROM Person.ADDRESS
WHERE StateProvinceID = 79
      AND City = N'Redmond';
GO 16


--Listing 21-10
SELECT qsqt.query_sql_text,
       CAST(qsp.query_plan AS XML) AS queryplan,
       qspf.feature_id,
       qspf.feature_desc,
       qspf.feedback_data,
       qspf.STATE,
       qspf.state_desc
FROM sys.query_store_plan_feedback AS qspf
    JOIN sys.query_store_plan AS qsp
        ON qsp.plan_id = qspf.plan_id
    JOIN sys.query_store_query AS qsq
        ON qsq.query_id = qsp.query_id
    JOIN sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id;


--Listing 21-11
SELECT TOP (100)
       bp.Name,
       bp.ProductNumber,
       bth.Quantity,
       bth.ActualCost
FROM dbo.bigProduct AS bp
    JOIN dbo.bigTransactionHistory AS bth
        ON bth.ProductID = bp.ProductID
WHERE bth.Quantity = 10
      AND bth.ActualCost > 357
        ORDER BY bp.Name;
GO 17


--Listing 21-12
--intentionally using SELECT *
SELECT *
FROM dbo.bigTransactionHistory AS bth
    JOIN dbo.bigProduct AS bp
        ON bp.ProductID = bth.ProductID
WHERE bth.Quantity = 10
      AND bth.ActualCost > 357;
GO 17


--Listing 21-13
ALTER DATABASE SCOPED CONFIGURATION SET DOP_FEEDBACK = ON;


--Listing 21-14
CREATE EVENT SESSION [DOPFeedback]
ON SERVER
    ADD EVENT sqlserver.dop_feedback_eligible_query(),
    ADD EVENT sqlserver.dop_feedback_provided(),
    ADD EVENT sqlserver.dop_feedback_reverted(),
    ADD EVENT sqlserver.dop_feedback_validation(),
    ADD EVENT sqlserver.sql_batch_completed();
GO
ALTER EVENT SESSION DOPFeedback ON SERVER STATE = START;



--Listing 21-15
SELECT COUNT(DISTINCT bth.TransactionID)
FROM dbo.bigTransactionHistory AS bth
GROUP BY bth.TransactionDate,
         bth.ActualCost;
GO
SELECT APPROX_COUNT_DISTINCT(bth.TransactionID)
FROM dbo.bigTransactionHistory AS bth
GROUP BY bth.TransactionDate,
         bth.ActualCost;
GO


--Listing 21-16
SELECT DISTINCT
       bp.NAME,
       
PERCENTILE_CONT(0.5)WITHIN GROUP(ORDER BY bth.ActualCost) OVER (PARTITION BY bp.NAME) AS MedianCont,
       
PERCENTILE_DISC(0.5)WITHIN GROUP(ORDER BY bth.ActualCost) OVER (PARTITION BY bp.NAME) AS MedianDisc
FROM dbo.bigTransactionHistory AS bth
    JOIN dbo.bigProduct AS bp
        ON bp.ProductID = bth.ProductID
WHERE bth.Quantity > 75
ORDER BY bp.Name;
GO
SELECT bp.NAME,
       
APPROX_PERCENTILE_CONT(0.5)WITHIN GROUP(ORDER BY bth.ActualCost) AS MedianCont,
       
APPROX_PERCENTILE_DISC(0.5)WITHIN GROUP(ORDER BY bth.ActualCost) AS MedianDisc
FROM dbo.bigTransactionHistory AS bth
    JOIN dbo.bigProduct AS bp
        ON bp.ProductID = bth.ProductID
WHERE bth.Quantity > 75
GROUP BY bp.NAME
ORDER BY bp.Name;
GO


--Listing 21-17
--Disable deferred compilation to see the old behavior
ALTER DATABASE SCOPED CONFIGURATION SET DEFERRED_COMPILATION_TV = OFF;
GO
DECLARE @HeaderInfo TABLE
(
    SalesOrderID INT,
    SalesOrderNumber NVARCHAR(25)
);
INSERT @HeaderInfo
(
    SalesOrderID,
    SalesOrderNumber
)
SELECT soh.SalesOrderID,
       soh.SalesOrderNumber
FROM Sales.SalesOrderHeader AS soh
WHERE soh.DueDate > '6/1/2014';
SELECT hi.SalesOrderNumber,
       sod.LineTotal
FROM @HeaderInfo AS hi
    JOIN Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = hi.SalesOrderID;
GO
--Enabled deferred compilation
ALTER DATABASE SCOPED CONFIGURATION SET DEFERRED_COMPILATION_TV = ON;
GO
DECLARE @HeaderInfo TABLE
(
    SalesOrderID INT,
    SalesOrderNumber NVARCHAR(25)
);
INSERT @HeaderInfo
(
    SalesOrderID,
    SalesOrderNumber
)
SELECT soh.SalesOrderID,
       soh.SalesOrderNumber
FROM Sales.SalesOrderHeader AS soh
WHERE soh.DueDate > '6/1/2014';
SELECT hi.SalesOrderNumber,
       sod.LineTotal
FROM @HeaderInfo AS hi
    JOIN Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = hi.SalesOrderID;


--Listing 21-18
CREATE OR ALTER FUNCTION dbo.ufnGetProductStandardCost
(
    @ProductID int,
    @OrderDate datetime
)
RETURNS money
AS
-- Returns the standard cost for the product on a specific date.
BEGIN
    DECLARE @StandardCost money;
    SELECT @StandardCost = pch.StandardCost
    FROM Production.Product p
        INNER JOIN Production.ProductCostHistory pch
            ON p.ProductID = pch.ProductID
               AND p.ProductID = @ProductID
               AND @OrderDate
               
BETWEEN pch.StartDate AND COALESCE(pch.EndDate, CONVERT(datetime, '99991231', 112)); -- Make sure we get all the prices!
    RETURN @StandardCost;
END;


--Listing 21-19
SELECT sm.is_inlineable
FROM sys.sql_modules AS sm
    JOIN sys.objects AS o
        ON o.OBJECT_ID = sm.OBJECT_ID
WHERE o.NAME = 'ufnGetProductStandardCost';



--Listing 21-20
ALTER DATABASE SCOPED CONFIGURATION SET TSQL_SCALAR_UDF_INLINING = OFF;
GO
--not inline
SELECT sod.LineTotal,
       dbo.ufnGetProductStandardCost(sod.ProductID, soh.OrderDate)
FROM Sales.SalesOrderDetail AS sod
    JOIN Production.Product AS p
        ON p.ProductID = sod.ProductID
    JOIN Sales.SalesOrderHeader AS soh
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE sod.LineTotal > 1000;
GO 
--Enable scalar inline
ALTER DATABASE SCOPED CONFIGURATION SET TSQL_SCALAR_UDF_INLINING = ON;
GO
--inline
SELECT sod.LineTotal,
       dbo.ufnGetProductStandardCost(sod.ProductID, soh.OrderDate)
FROM Sales.SalesOrderDetail AS sod
    JOIN Production.Product AS p
        ON p.ProductID = sod.ProductID
    JOIN Sales.SalesOrderHeader AS soh
        ON soh.SalesOrderID = sod.SalesOrderID
WHERE sod.LineTotal > 1000;
GO 
