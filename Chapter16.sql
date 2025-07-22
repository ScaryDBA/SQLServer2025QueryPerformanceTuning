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





