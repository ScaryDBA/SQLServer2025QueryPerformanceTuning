--Listing 11-1
SELECT p.Name,
       AVG(sod.LineTotal)
FROM Sales.SalesOrderDetail AS sod
    JOIN Production.Product AS p
        ON sod.ProductID = p.ProductID
WHERE sod.ProductID = 776
GROUP BY sod.CarrierTrackingNumber,
         p.Name
HAVING MAX(sod.OrderQty) > 1
ORDER BY MIN(sod.LineTotal);



--Listing 11-2
SELECT *
FROM Sales.SalesOrderDetail AS sod
WHERE sod.ProductID = 793;



--Listing 11-3
SELECT *
FROM Sales.SalesOrderDetail AS sod WITH (INDEX(IX_SalesOrderDetail_ProductID))
WHERE sod.ProductID = 793;


--Listing 11-4
SELECT NationalIDNumber,
       JobTitle,
       HireDate
FROM HumanResources.Employee AS E
WHERE E.NationalIDNumber = '693168613';


--Listing 11-5
DBCC SHOW_STATISTICS('HumanResources.Employee', 'AK_Employee_NationalIDNumber') WITH DENSITY_VECTOR;


--Listing 11-6
CREATE UNIQUE NONCLUSTERED INDEX AK_Employee_NationalIDNumber
ON [HumanResources].[Employee] (
                                   NationalIDNumber ASC,
                                   JobTitle,
                                   HireDate
                               )
WITH DROP_EXISTING;


--Listing 11-7
CREATE UNIQUE NONCLUSTERED INDEX AK_Employee_NationalIDNumber
ON [HumanResources].[Employee] (NationalIDNumber ASC)
INCLUDE (
            JobTitle,
            HireDate
        )
WITH DROP_EXISTING;


--Listing 11-8
CREATE UNIQUE NONCLUSTERED INDEX AK_Employee_NationalIDNumber
ON [HumanResources].[Employee] (NationalIDNumber ASC)
INCLUDE (
            JobTitle,
            HireDate
        )
WITH DROP_EXISTING;



--Listing 11-9
SELECT NationalIDNumber,
       E.BusinessEntityID
FROM HumanResources.Employee AS E
WHERE E.NationalIDNumber = '693168613';




--Listing 11-10
SELECT poh.PurchaseOrderID,
       poh.VendorID,
       poh.OrderDate
FROM Purchasing.PurchaseOrderHeader AS poh
WHERE VendorID = 1636
      AND poh.OrderDate = '2014/6/24';


--Listing 11-11
CREATE NONCLUSTERED INDEX IX_TEST
ON Purchasing.PurchaseOrderHeader (OrderDate);









