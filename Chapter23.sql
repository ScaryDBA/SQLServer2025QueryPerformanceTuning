--Listing 23-1
CREATE NONCLUSTERED INDEX AK_Product_Name
ON Production.Product (NAME ASC)
WITH (DROP_EXISTING = ON);



--Listing 23-2
SELECT DISTINCT
       (p.NAME)
FROM Production.Product AS p;


--Listing 23-3
CREATE UNIQUE NONCLUSTERED INDEX AK_Product_Name
ON Production.Product (NAME ASC)
WITH (DROP_EXISTING = ON);


--Listing 23-4
DROP TABLE IF EXISTS dbo.Test1;
GO
CREATE TABLE dbo.Test1
(
    C1 INT,
    C2 INT CHECK (C2
                  BETWEEN 10 AND 20
                 )
);
INSERT INTO dbo.Test1
VALUES
(11, 12);
GO
DROP TABLE IF EXISTS dbo.Test2;
GO
CREATE TABLE dbo.Test2
(
    C1 INT,
    C2 INT
);
INSERT INTO dbo.Test2
VALUES
(101, 102);


--Listing 23-5
