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



