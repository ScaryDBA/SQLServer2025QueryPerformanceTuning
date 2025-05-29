--Listing 6-1
ALTER DATABASE AdventureWorks SET QUERY_STORE = ON;



--Listing 6-2
SELECT qsq.query_id,
       qsq.object_id,
       qsqt.query_sql_text,
          qsp.plan_id,
       CAST(qsp.query_plan AS XML) AS QueryPlan
FROM sys.query_store_query AS qsq
    JOIN sys.query_store_query_text AS qsqt
        ON qsq.query_text_id = qsqt.query_text_id
    JOIN sys.query_store_plan AS qsp
        ON qsp.query_id = qsq.query_id
WHERE qsq.object_id = OBJECT_ID('dbo.ProductTransactionHistoryByReference');



--Listing 6-3
CREATE OR ALTER PROC dbo.ProductTransactionHistoryByReference
(@ReferenceOrderID int)
AS
BEGIN
    SELECT p.Name,
           p.ProductNumber,
           th.ReferenceOrderID
    FROM Production.Product AS p
        JOIN Production.TransactionHistory AS th
            ON th.ProductID = p.ProductID
    WHERE th.ReferenceOrderID = @ReferenceOrderID;
END;



--Listing 6-4
SELECT a.AddressID,
       a.AddressLine1
FROM Person.Address AS a
WHERE a.AddressID = 72;






