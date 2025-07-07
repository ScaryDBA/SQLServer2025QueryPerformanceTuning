--Listing 10-1
SELECT A.PostalCode
FROM Person.ADDRESS AS A
WHERE A.StateProvinceID = 42;
--GO 50


--Listing 10-2
CREATE NONCLUSTERED INDEX IX_Address_StateProvinceID
ON Person.ADDRESS (StateProvinceID ASC)
INCLUDE (PostalCode)
WITH (DROP_EXISTING = ON);


--Listing 10-3
CREATE NONCLUSTERED INDEX IX_Address_StateProvinceID
ON Person.ADDRESS (StateProvinceID ASC)
WITH (DROP_EXISTING = ON);


--Listing 10-4
SELECT soh.SalesPersonID,
       soh.OrderDate
FROM Sales.SalesOrderHeader AS soh
WHERE soh.SalesPersonID = 276
      AND soh.OrderDate
      BETWEEN '4/1/2013' AND '7/1/2013';
GO 50


--Listing 10-5
CREATE NONCLUSTERED INDEX IX_Test
ON Sales.SalesOrderHeader (OrderDate ASC);



--Listing 10-6
CREATE NONCLUSTERED INDEX IX_Test
ON Sales.SalesOrderHeader (
                              SalesPersonID,
                              OrderDate ASC
                          )
WITH DROP_EXISTING;


--Listing 10-7
DROP INDEX IX_Test ON Sales.SalesOrderHeader;



--Listing 10-8
SELECT poh.PurchaseOrderID,
       poh.RevisionNumber
FROM Purchasing.PurchaseOrderHeader AS poh
WHERE poh.EmployeeID = 261
      AND poh.VendorID = 1500;


--Listing 10-9
SELECT soh.PurchaseOrderNumber,
       soh.OrderDate,
       soh.ShipDate,
       soh.SalesPersonID
FROM Sales.SalesOrderHeader AS soh
WHERE PurchaseOrderNumber LIKE 'PO5%'
      AND soh.SalesPersonID IS NOT NULL;
GO 50


---Listing 10-10
CREATE NONCLUSTERED INDEX IX_Test
ON Sales.SalesOrderHeader (
                              PurchaseOrderNumber,
                              SalesPersonID
                          )
INCLUDE (
            OrderDate,
            ShipDate
        );
--WITH (DROP_EXISTING=ON);


--Listing 10-11
CREATE NONCLUSTERED INDEX IX_Test
ON Sales.SalesOrderHeader (
                              PurchaseOrderNumber,
                              SalesPersonID
                          )
INCLUDE (
            OrderDate,
            ShipDate
        )
WHERE PurchaseOrderNumber IS NOT NULL
      AND SalesPersonID IS NOT NULL
WITH (DROP_EXISTING = ON);


--Listing 10-12
DROP INDEX IX_Test ON Sales.SalesOrderHeader;


--Listing 10-13
--SET STATISTICS IO ON;
SELECT p.[Name] AS ProductName,
       SUM(pod.OrderQty) AS OrderOty,
       SUM(pod.ReceivedQty) AS ReceivedOty,
       SUM(pod.RejectedQty) AS RejectedOty
FROM Purchasing.PurchaseOrderDetail AS pod
    JOIN Production.Product AS p
        ON p.ProductID = pod.ProductID
GROUP BY p.[Name];
GO 50
SELECT p.[Name] AS ProductName,
       SUM(pod.OrderQty) AS OrderOty,
       SUM(pod.ReceivedQty) AS ReceivedOty,
       SUM(pod.RejectedQty) AS RejectedOty
FROM Purchasing.PurchaseOrderDetail AS pod
    JOIN Production.Product AS p
        ON p.ProductID = pod.ProductID
GROUP BY p.[Name]
HAVING (SUM(pod.RejectedQty) / SUM(pod.ReceivedQty)) > .08;
GO 50
SELECT p.[Name] AS ProductName,
       SUM(pod.OrderQty) AS OrderQty,
       SUM(pod.ReceivedQty) AS ReceivedQty,
       SUM(pod.RejectedQty) AS RejectedQty
FROM Purchasing.PurchaseOrderDetail AS pod
    JOIN Production.Product AS p
        ON p.ProductID = pod.ProductID
WHERE p.[Name] LIKE 'Chain%'
GROUP BY p.[Name];
--SET STATISTICS IO OFF
GO 50



--Listing 10-14
CREATE OR ALTER VIEW Purchasing.IndexedView
WITH SCHEMABINDING
AS
SELECT pod.ProductID,
       SUM(pod.OrderQty) AS OrderQty,
       SUM(pod.ReceivedQty) AS ReceivedQty,
       SUM(pod.RejectedQty) AS RejectedQty,
       COUNT_BIG(*) AS COUNT
FROM Purchasing.PurchaseOrderDetail AS pod
GROUP BY pod.ProductID;
GO
CREATE UNIQUE CLUSTERED INDEX iv ON Purchasing.IndexedView (ProductID);


--Listing 10-15
DROP VIEW Purchasing.IndexedView;


--Listing 10-16
CREATE NONCLUSTERED INDEX IX_Test
ON Person.ADDRESS (
                      City ASC,
                      PostalCode ASC
                  );


--Listing 10-17
CREATE NONCLUSTERED INDEX IX_CompRow_Test
ON Person.ADDRESS (
                      City,
                      PostalCode
                  )
WITH (DATA_COMPRESSION = ROW);
CREATE NONCLUSTERED INDEX IX_CompPage_Test
ON Person.ADDRESS (
                      City,
                      PostalCode
                  )
WITH (DATA_COMPRESSION = PAGE);



--Listing 10-18
SELECT i.NAME,
       i.type_desc,
       s.page_count,
       s.record_count,
       s.index_level,
       s.compressed_page_count
FROM sys.indexes AS i
    
JOIN sys.dm_db_index_physical_stats(DB_ID(N'AdventureWorks'), 
OBJECT_ID(N'Person.Address'), NULL, NULL, 'DETAILED') AS s
        ON i.index_id = s.index_id
WHERE i.OBJECT_ID = OBJECT_ID(N'Person.Address');



--Listing 10-19
DROP INDEX IX_Test ON Person.ADDRESS;
DROP INDEX IX_CompRow_Test ON Person.ADDRESS;
DROP INDEX IX_CompPage_Test ON Person.ADDRESS;



--Listing 10-20
CREATE NONCLUSTERED INDEX IX_Test
ON Person.ADDRESS (
                      City ASC,
                      PostalCode DESC
                  );




--Listing 10-21
BEGIN TRAN
CREATE NONCLUSTERED INDEX IX_Test
ON Person.Address(City);
ROLLBACK TRAN


--Listing 10-22
CREATE NONCLUSTERED INDEX IX_Resumable
ON Person.ADDRESS (
                      City ASC,
                      PostalCode DESC
                  )
WITH (RESUMABLE = ON, ONLINE = ON);



--Listing 10-23
SELECT o.NAME AS ObjectName,
       i.NAME AS IndexName,
       iro.sql_text,
       iro.state_desc,
       iro.start_time,
       iro.last_pause_time,
       iro.total_execution_time,
       iro.percent_complete
FROM sys.index_resumable_operations AS iro
    JOIN sys.indexes AS i
        ON i.OBJECT_ID = iro.OBJECT_ID
           AND i.index_id = iro.index_id
    JOIN sys.objects AS o
        ON o.OBJECT_ID = i.OBJECT_ID;




--Listing 10-24
ALTER INDEX IX_Resumable ON Person.ADDRESS PAUSE;



--Listing 10-25
ALTER INDEX IX_Resumable ON Person.ADDRESS RESUME;
ALTER INDEX IX_Resumable ON Person.ADDRESS ABORT;
















