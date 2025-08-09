--Listing 17-1
SET DEADLOCK_PRIORITY LOW;


--Listing 17-2
DBCC TRACEON (1222, -1);


--Listing 17-3
DECLARE @path NVARCHAR(260);
--to retrieve the local path of system_health files 
SELECT @path = dosdlc.path
FROM sys.dm_os_server_diagnostics_log_configurations AS dosdlc;

SELECT @path = @path + N'system_health_*';

WITH fxd
AS (SELECT CAST(fx.event_data AS XML) AS Event_Data
    FROM sys.fn_xe_file_target_read_file(@path, NULL, NULL, NULL) AS fx )
SELECT dl.deadlockgraph
FROM
(
    SELECT dl.query('.') AS deadlockgraph
    FROM fxd
        CROSS APPLY event_data.nodes('(/event/data/value/deadlock)') AS d(dl)
) AS dl;



--Listing 17-4
--Run from connection 1
BEGIN TRANSACTION PODSecond;
UPDATE Purchasing.PurchaseOrderHeader
SET Freight = Freight * 0.9 --9% discount on shipping
WHERE PurchaseOrderID = 1255;

--Run from connection 2
BEGIN TRANSACTION PODFirst;
UPDATE Purchasing.PurchaseOrderDetail
SET OrderQty = 2
WHERE ProductID = 448
      AND PurchaseOrderID = 1255;

--Run from connection 1
UPDATE Purchasing.PurchaseOrderDetail
SET OrderQty = 4
WHERE ProductID = 448
      AND PurchaseOrderID = 1255;


--Listing 17-5
SELECT OBJECT_NAME(object_id)
FROM sys.partitions
WHERE hobt_id = 72057594050969600;


--Listing 17-6
DECLARE @retry AS TINYINT = 1,
        @retrymax AS TINYINT = 2,
        @retrycount AS TINYINT = 0;
WHILE @retry = 1 AND @retrycount <= @retrymax
BEGIN
    SET @retry = 0;
    BEGIN TRY
        UPDATE HumanResources.Employee
        SET LoginID = '54321'
        WHERE BusinessEntityID = 100;
    END TRY
    BEGIN CATCH
        IF (ERROR_NUMBER() = 1205)
        BEGIN
            SET @retrycount = @retrycount + 1;
            SET @retry = 1;
        END;
    END CATCH;
END;




