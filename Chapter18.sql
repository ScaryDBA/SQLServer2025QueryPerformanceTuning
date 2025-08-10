--Listing 18-1
DECLARE MyCursor CURSOR READ_ONLY FOR
SELECT adt.NAME
FROM Person.AddressType AS adt
WHERE adt.AddressTypeID = 1;



--Listing 18-2
DECLARE MyCursor CURSOR OPTIMISTIC FOR
SELECT adt.NAME
FROM Person.AddressType AS adt
WHERE adt.AddressTypeID = 1;


--Listing 18-3
DECLARE MyCursor CURSOR SCROLL_LOCKS FOR
SELECT adt.NAME
FROM Person.AddressType AS adt
WHERE adt.AddressTypeID = 1;


--Listing 18-4
DECLARE MyCursor CURSOR FAST_FORWARD FOR
SELECT adt.NAME
FROM Person.AddressType AS adt
WHERE adt.AddressTypeID = 1;


--Listing 18-5
DECLARE MyCursor CURSOR STATIC FOR
SELECT adt.NAME
FROM Person.AddressType AS adt
WHERE adt.AddressTypeID = 1;


--Listing 18-6
DECLARE MyCursor CURSOR KEYSET FOR
SELECT adt.NAME
FROM Person.AddressType AS adt
WHERE adt.AddressTypeID = 1;


--Listing 18-7
DECLARE MyCursor CURSOR DYNAMIC FOR
SELECT adt.NAME
FROM Person.AddressType AS adt
WHERE adt.AddressTypeID = 1;


--Listing 18-8
--A table for identifying SalesOrderID values based on iteration
DECLARE @LoopTable TABLE
(
    LoopID INT IDENTITY(1, 1),
    SalesOrderDetailID INT
);
--defining our data set through a query
INSERT INTO @LoopTable
(
    SalesOrderDetailID
)
SELECT sod.SalesOrderDetailID
FROM Sales.SalesOrderDetail AS sod
WHERE sod.OrderQty > 23
ORDER BY sod.SalesOrderDetailID DESC;
DECLARE @MaxRow INT,
        @Count INT,
        @SalesOrderDetailID INT;
--retrieving the limit of the data set
SELECT @MaxRow = MAX(lt.LoopID),
       @Count = 1
FROM @LoopTable AS lt;
--looping through the results
WHILE @Count <= @MaxRow
BEGIN
    SELECT @SalesOrderDetailID = lt.SalesOrderDetailID
    FROM @LoopTable AS lt
    WHERE lt.LoopID = @Count;
    SELECT sod.OrderQty
    FROM Sales.SalesOrderDetail AS sod
    WHERE sod.SalesOrderDetailID = @SalesOrderDetailID;
    SET @Count += 1;
END;




--Listing 18-9
DROP TABLE IF EXISTS dbo.Test1;
GO
CREATE TABLE dbo.Test1
(
    C1 INT,
    C2 CHAR(996)
);
CREATE CLUSTERED INDEX Test1Index ON dbo.Test1 (C1);
INSERT INTO dbo.Test1
VALUES
(1, '1'),
(2, '2');


--Listing 18-10
--powershell, not t-sql
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = 'Server=localhost;Database=AdventureWorks;trusted_connection=false;user=sa;password=*cthulhu1988'

$SqlCommand = New-Object System.Data.SqlClient.SqlCommand
$SqlCommand.CommandText = "SELECT * FROM dbo.Test1;"
$SqlCommand.Connection = $SqlConnection

$SqlConnection.Open()
$Reader = $SqlCommand.ExecuteReader()

while ($Reader.Read()) {
    $C1 = $Reader["C1"]
    $C2 = $Reader["C2"]
    Write-Output "C1 = $C1 and C2 = $C2"
}

$Reader.Close()
$SqlConnection.Close()



--Listing 18-11
SELECT TOP 100000
       IDENTITY(INT, 1, 1) AS n
INTO #Tally
FROM MASTER.dbo.syscolumns AS scl,
     MASTER.dbo.syscolumns AS sc2;
INSERT INTO dbo.Test1
(
    C1,
    C2
)
SELECT n,
       n
FROM #Tally AS t;


SELECT dtl.request_session_id,
       dtl.resource_database_id,
       dtl.resource_associated_entity_id,
       dtl.resource_type,
       dtl.resource_description,
       dtl.request_mode,
       dtl.request_status
FROM sys.dm_tran_locks AS dtl


--Listing 18-12
CREATE OR ALTER PROC dbo.TotalLossCursorBased
AS
DECLARE ScrappedProducts CURSOR FOR
SELECT p.ProductID,
       wo.ScrappedQty,
       p.ListPrice
FROM Production.WorkOrder AS wo
    JOIN Production.ScrapReason AS sr
        ON wo.ScrapReasonID = sr.ScrapReasonID
    JOIN Production.Product AS p
        ON wo.ProductID = p.ProductID;
--Open the cursor to process one product at a time
OPEN ScrappedProducts;
DECLARE @MoneyLostPerProduct MONEY = 0,
        @TotalLoss MONEY = 0;
--Calculate money lost per product by processing one product
--at a time
DECLARE @ProductId INT,
        @UnitsScrapped SMALLINT,
        @ListPrice MONEY;
FETCH NEXT FROM ScrappedProducts
INTO @ProductId,
     @UnitsScrapped,
     @ListPrice;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @MoneyLostPerProduct = @UnitsScrapped * @ListPrice; --Calculate total loss
    SET @TotalLoss = @TotalLoss + @MoneyLostPerProduct;
    FETCH NEXT FROM ScrappedProducts
    INTO @ProductId,
         @UnitsScrapped,
         @ListPrice;
END;
--Determine status
IF (@TotalLoss > 5000)
    SELECT 'We are bankrupt!' AS STATUS;
ELSE
    SELECT 'We are safe!' AS STATUS;
--Close the cursor and release all resources assigned to the cursor
CLOSE ScrappedProducts;
DEALLOCATE ScrappedProducts;
GO


--Listing 18-13
EXEC dbo.TotalLossCursorBased;


--Listing 18-14
CREATE OR ALTER PROC dbo.TotalLoss
AS
SELECT CASE --Determine status based on following computation
           WHEN SUM(MoneyLostPerProduct) > 5000 THEN
               'We are bankrupt!'
           ELSE
               'We are safe!'
       END AS STATUS
FROM
( --Calculate total money lost for all discarded products
    SELECT SUM(wo.ScrappedQty * p.ListPrice) AS MoneyLostPerProduct
    FROM Production.WorkOrder AS wo
        JOIN Production.ScrapReason AS sr
            ON wo.ScrapReasonID = sr.ScrapReasonID
        JOIN Production.Product AS p
            ON wo.ProductID = p.ProductID
    GROUP BY p.ProductID
) AS DiscardedProducts;
GO

EXEC dbo.TotalLoss;
