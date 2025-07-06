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


--Listing 10-3
CREATE NONCLUSTERED INDEX IX_Test
ON Sales.SalesOrderHeader (OrderDate ASC);



--Listing 10-4
CREATE NONCLUSTERED INDEX IX_Test
ON Sales.SalesOrderHeader (
                              SalesPersonID,
                              OrderDate ASC
                          )
WITH DROP_EXISTING;


--Listing 10-5
DROP INDEX IX_Test ON Sales.SalesOrderHeader;






