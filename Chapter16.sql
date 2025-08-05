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


--Listing 16-13
ALTER DATABASE AdventureWorks SET READ_COMMITTED_SNAPSHOT ON;


--Listing 16-14
BEGIN TRANSACTION;
SELECT p.Color
FROM Production.Product AS p
WHERE p.ProductID = 711;

--COMMIT


--Listing 16-15
--Run in a separate connection
BEGIN TRANSACTION;
UPDATE Production.Product
SET Color = 'Coyote'
WHERE ProductID = 711;
--test that change
SELECT p.Color
FROM Production.Product AS p
WHERE p.ProductID = 711;


--Listing 16-16
ALTER DATABASE AdventureWorks SET READ_COMMITTED_SNAPSHOT OFF;


--Listing 16-17
DROP TABLE IF EXISTS dbo.MyProduct;
GO
CREATE TABLE dbo.MyProduct
(
    ProductID INT,
    Price MONEY
);
INSERT INTO dbo.MyProduct
VALUES
(1, 15.0),
(2, 22.0),
(3, 9.99);


--Listing 16-18
DECLARE @Price INT;
BEGIN TRAN NormailizePrice;
SELECT @Price = mp.Price
FROM dbo.MyProduct AS mp
WHERE mp.ProductID = 1;
/*Allow transaction 2 to execute*/
WAITFOR DELAY '00:00:10';
IF @Price > 10
    UPDATE dbo.MyProduct
    SET Price = Price - 10
    WHERE ProductID = 1;
COMMIT;
--Transaction 2 from Connection 2
BEGIN TRAN ApplyDiscount;
UPDATE dbo.MyProduct
SET Price = Price * 0.6 --Discount = 40%
WHERE Price > 10;
COMMIT;


--Listing 16-19
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
GO
--Transaction 1 from Connection 1
DECLARE @Price INT;
BEGIN TRAN NormalizePrice;
SELECT @Price = Price
FROM dbo.MyProduct AS mp
WHERE mp.ProductID = 1;
/*Allow transaction 2 to execute*/
WAITFOR DELAY '00:00:10';
IF @Price > 10
    UPDATE dbo.MyProduct
    SET Price = Price - 10
    WHERE ProductID = 1;
COMMIT;
GO
SET TRANSACTION ISOLATION LEVEL READ COMMITTED; --Back to default
GO


--Listing 16-20
DROP TABLE IF EXISTS dbo.MyEmployees;
GO
CREATE TABLE dbo.MyEmployees
(
    EmployeeID INT,
    GroupID INT,
    Salary MONEY
);
CREATE CLUSTERED INDEX i1 ON dbo.MyEmployees (GroupID);
INSERT INTO dbo.MyEmployees
VALUES
(1, 10, 1000),
(2, 10, 1000),
(3, 20, 1000),
(4, 9, 1000);


--Listing 16-21
--Transaction 1 from Connection 1
DECLARE @Fund MONEY = 100,
        @Bonus MONEY,
        @NumberOfEmployees INT;
BEGIN TRAN PayBonus;
SELECT @NumberOfEmployees = COUNT(*)
FROM dbo.MyEmployees
WHERE GroupID = 10;
/*Allow transaction 2 to execute*/
WAITFOR DELAY '00:00:10';
IF @NumberOfEmployees > 0
BEGIN
    SET @Bonus = @Fund / @NumberOfEmployees;
    UPDATE dbo.MyEmployees
    SET Salary = Salary + @Bonus
    WHERE GroupID = 10;
    PRINT 'Fund balance =
' + CAST((@Fund - (@@ROWCOUNT * @Bonus)) AS VARCHAR(6)) + '   $';
END;
COMMIT;
--Transaction 2 from Connect 2
BEGIN TRAN NewEmployee;
INSERT INTO MyEmployees
VALUES
(5, 10, 1000);
COMMIT;


--Listing 16-22
ALTER DATABASE AdventureWorks SET ACCELERATED_DATABASE_RECOVERY = ON;
ALTER DATABASE AdventureWorks SET OPTIMIZED_LOCKING = ON;



--Listing 16-23
BEGIN TRAN;
DELETE Production.ProductCostHistory
WHERE StandardCost < 50;
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


ALTER DATABASE AdventureWorks SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE AdventureWorks SET OPTIMIZED_LOCKING = OFF;
--ALTER DATABASE AdventureWorks SET ACCELERATED_DATABASE_RECOVERY = OFF;
ALTER DATABASE AdventureWorks SET READ_COMMITTED_SNAPSHOT OFF;
ALTER DATABASE AdventureWorks SET MULTI_USER;


BEGIN TRAN;
DELETE Production.ProductCostHistory
WHERE StandardCost < 50;
ROLLBACK;
GO 50



--Listing 16-24

ALTER DATABASE AdventureWorks SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE AdventureWorks SET OPTIMIZED_LOCKING = OFF;
ALTER DATABASE AdventureWorks SET READ_COMMITTED_SNAPSHOT OFF;
ALTER DATABASE AdventureWorks SET MULTI_USER;

ALTER DATABASE AdventureWorks SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE AdventureWorks SET OPTIMIZED_LOCKING = ON;
ALTER DATABASE AdventureWorks SET READ_COMMITTED_SNAPSHOT ON;
ALTER DATABASE AdventureWorks SET MULTI_USER;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED

--Setup
DROP TABLE IF EXISTS dbo.LAQTest;
GO
CREATE TABLE dbo.LAQTest
(
    LAQID INT,
    LAQValue VARCHAR(25)
);
GO
INSERT INTO dbo.LAQTest
(
    LAQID,
    LAQValue
)
VALUES
(1, 'Value 1'),
(2, 'Value 2'),
(3, 'Value 3');

--Run from 1st connection
BEGIN TRAN
UPDATE dbo.LAQTest
SET LAQValue = 'Value 1a'
WHERE LAQID = 1;
--rollback

--Run from 2nd connection
BEGIN TRAN
UPDATE dbo.LAQTest
SET LAQValue = 'Value 2a'
WHERE LAQID = 2;



SELECT dtl.request_session_id,
       dtl.resource_database_id,
       dtl.resource_associated_entity_id,
       dtl.resource_type,
       dtl.resource_description,
       dtl.request_mode,
       dtl.request_status
FROM sys.dm_tran_locks AS dtl
WHERE dtl.request_session_id = @@SPID;

--Listing 16-25
ALTER DATABASE AdventureWorks SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE AdventureWorks SET OPTIMIZED_LOCKING = OFF;
ALTER DATABASE AdventureWorks SET READ_COMMITTED_SNAPSHOT OFF;
ALTER DATABASE AdventureWorks SET MULTI_USER;




--Listing 16-26
DROP TABLE IF EXISTS dbo.LockTest;
GO
CREATE TABLE dbo.LockTest
(
    C1 INT,
    C2 DATETIME
);
INSERT INTO dbo.LockTest
VALUES
(1, GETDATE());
CREATE NONCLUSTERED INDEX iTest ON dbo.LockTest (C1);


--Listing 16-27
BEGIN TRAN LockBehavior;
UPDATE dbo.LockTest WITH (REPEATABLEREAD) --Hold all acquired locks
SET C2 = GETDATE()
WHERE C1 = 1;
--Observe lock behavior from another connection
WAITFOR DELAY '00:00:10';
COMMIT;


--Listing 16-28
ALTER INDEX TestIndex
ON dbo.LockTest
SET (ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = OFF);


--Listing 16-29
CREATE CLUSTERED INDEX iTest ON dbo.LockTest (C1) WITH DROP_EXISTING;


--Listing 16-30
SELECT der.blocking_session_id AS BlockingSessionID,
       dtl.request_session_id AS WaitingSessionID,
       dowt.resource_description AS ResourceDesc,
       deib.event_info AS BlockingTsql,
       dest.text AS WaitingTsql,
       der.wait_type AS WaitType,
       dtl.request_type AS WaitingRequestType,
       dowt.wait_duration_ms AS WaitDuration,
       DB_NAME(dtl.resource_database_id) AS DatabaseName,
       dtl.resource_associated_entity_id AS WaitingAssociatedEntity,
       dtl.resource_type AS WaitingResourceType
FROM sys.dm_tran_locks AS dtl
    JOIN sys.dm_os_waiting_tasks AS dowt
        ON dtl.lock_owner_address = dowt.resource_address
    JOIN sys.dm_exec_requests AS der
        ON der.session_id = dtl.request_session_id
    CROSS APPLY sys.dm_exec_sql_text(der.sql_handle) AS dest
    CROSS APPLY sys.dm_exec_input_buffer(der.blocking_session_id, 0) AS deib;


--Listing 16-31
DROP TABLE IF EXISTS dbo.BlockTest;
GO
CREATE TABLE dbo.BlockTest
(
    C1 INT,
    C2 INT,
    C3 DATETIME
);
INSERT INTO dbo.BlockTest
VALUES
(11, 12, GETDATE()),
(21, 22, GETDATE());


--Listing 16-32
--First connection, executed first
BEGIN TRAN User1;
UPDATE dbo.BlockTest
SET C3 = GETDATE();
--Second connection, executed second
BEGIN TRAN User2;
SELECT C2
FROM dbo.BlockTest
WHERE C1 = 11;
COMMIT;

--Listing 16-33
EXEC sp_configure 'show advanced option', '1';
RECONFIGURE;
EXEC sp_configure 'blocked process threshold', 5;
RECONFIGURE;


--Listing 16-34
CREATE EVENT SESSION BlockedProcess
ON SERVER
    ADD EVENT sqlserver.blocked_process_report;

