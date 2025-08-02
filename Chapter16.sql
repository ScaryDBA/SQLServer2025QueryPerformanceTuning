--Listing 16-1
DROP TABLE IF EXISTS dbo.ProductTest;
GO
CREATE TABLE dbo.ProductTest
(
    ProductID INT
        CONSTRAINT ValueEqualsOne CHECK (ProductID = 1)
);
GO
--All ProductIDs are added into ProductTest as a logical unit of work
INSERT INTO dbo.ProductTest
SELECT p.ProductID
FROM Production.Product AS p;
GO
SELECT pt.ProductID
FROM dbo.ProductTest AS pt; --Returns 0 rows


--Listing 16-2
BEGIN TRAN;
--Start:  Logical unit of work
--First:
INSERT INTO dbo.ProductTest
SELECT p.ProductID
FROM Production.Product AS p;
--Second:
INSERT INTO dbo.ProductTest
VALUES
(1);
COMMIT; --End:   Logical unit of work
GO


--Listing 16-3
SET XACT_ABORT ON;
GO
BEGIN TRAN;
--Start:  Logical unit of work
--First:
INSERT INTO dbo.ProductTest
SELECT p.ProductID
FROM Production.Product AS p;
--Second:
INSERT INTO dbo.ProductTest
VALUES
(1  );
COMMIT;
--End:   Logical unit of work GO
SET XACT_ABORT OFF;
GO


--Listing 16-4
BEGIN TRY
    BEGIN TRAN;
    --Start: Logical unit of work
    First:
    INSERT INTO dbo.ProductTest
    SELECT p.ProductID
    FROM Production.Product AS p;
    Second:
    INSERT INTO dbo.ProductTest
    (
        ProductID
    )
    VALUES
    (1  );
    COMMIT; --End: Logical unit of work
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT 'An error occurred';
    RETURN;
END CATCH;


--Listing 16-5
DROP TABLE IF EXISTS dbo.LockTest;
CREATE TABLE dbo.LockTest
(
    C1 INT
);
INSERT INTO dbo.LockTest
VALUES
(1);
GO
BEGIN TRAN;
DELETE dbo.LockTest
WHERE C1 = 1;
SELECT dtl.request_session_id,
       dtl.resource_database_id,
       dtl.resource_associated_entity_id,
       dtl.resource_type,
       dtl.resource_description,
       dtl.request_mode,
       dtl.request_status
FROM sys.dm_tran_locks AS dtl
WHERE dtl.request_session_id = @@SPID;
ROLLBACK;


--Listing 16-6
SELECT OBJECT_NAME(1476200309),
       DB_NAME(5);


--Listing 16-7
CREATE CLUSTERED INDEX TestIndex ON dbo.LockTest (C1);



--Listing 16-8
BEGIN TRAN;
DELETE dbo.LockTest
WHERE C1 = 1;
SELECT dtl.request_session_id,
       dtl.resource_database_id,
       dtl.resource_associated_entity_id,
       dtl.resource_type,
       dtl.resource_description,
       dtl.request_mode,
       dtl.request_status
FROM sys.dm_tran_locks AS dtl
WHERE dtl.request_session_id = @@SPID;
ROLLBACK;


--Listing 16-9
ALTER TABLE schema.table
SET (LOCK_ESCALATION = DISABLE);


--Listing from Table 16-1
--Connection 1
BEGIN TRANSACTION LockTran2;
--Retain an  (S) lock on the resource
SELECT *
FROM Sales.Currency AS c WITH (REPEATABLEREAD)
WHERE c.CurrencyCode = 'EUR';
--Allow DMVs to be executed before second step of
-- UPDATE statement is executed by transaction LockTran1
WAITFOR DELAY '00:00:10';
COMMIT;


--Connection 2
BEGIN TRANSACTION LockTran1;
UPDATE Sales.Currency
SET Name = 'Euro'
WHERE CurrencyCode = 'EUR';
-- NOTE: We're not committing yet



--Connection 3
SELECT dtl.request_session_id,
       dtl.resource_database_id,
       dtl.resource_associated_entity_id,
       dtl.resource_type,
       dtl.resource_description,
       dtl.request_mode,
       dtl.request_status
FROM sys.dm_tran_locks AS dtl
ORDER BY dtl.request_session_id;
--wait 10 seconds
SELECT dtl.request_session_id,
       dtl.resource_database_id,
       dtl.resource_associated_entity_id,
       dtl.resource_type,
       dtl.resource_description,
       dtl.request_mode,
       dtl.request_status
FROM sys.dm_tran_locks AS dtl
ORDER BY dtl.request_session_id;
COMMIT;



--Listing 16-10
BEGIN TRAN;
DELETE Sales.Currency
WHERE CurrencyCode = 'ALL';
SELECT tl.request_session_id,
       tl.resource_database_id,
       tl.resource_associated_entity_id,
       tl.resource_type,
       tl.resource_description,
       tl.request_mode,
       tl.request_status
FROM sys.dm_tran_locks AS tl;
ROLLBACK TRAN;



--Listing 16-11
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


--Listing 16-12
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


