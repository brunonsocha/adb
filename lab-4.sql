-- =============================================
-- Brunon
-- Socha
-- 233861
-- =============================================

-- =============================================
-- Zadanie 1
-- =============================================

DECLARE @ProductInfo nvarchar(max) =
N'[
  { "ProductID": 705, "NewPrice": 14.99 },
  { "ProductID": 706, "NewPrice":  9.99 },
  { "ProductID": 707, "NewPrice": 1999.99 },
  { "ProductID": 708, "NewPrice": 1299.99 },
  { "ProductID": 709, "NewPrice":  899.99 }
]';
GO
EXEC sys.sp_set_session_context
     @key   = N'ProductInfo',
     @value = @ProductInfo;
GO
CREATE VIEW dbo.v_PriceDifference
AS
SELECT
    p.ProductID,
    p.Name,
    p.ListPrice      AS CurrentPrice,
    j.NewPrice       AS PlannedPrice,
    j.NewPrice - p.ListPrice AS Diff
FROM SalesLT.Product p
JOIN OPENJSON(CAST(SESSION_CONTEXT(N'ProductInfo') AS nvarchar(max)))
WITH (
    ProductID int           '$.ProductID',
    NewPrice  decimal(19,4) '$.NewPrice'
) j
ON j.ProductID = p.ProductID;
GO
-- =============================================
-- Zadanie 2
-- =============================================

CREATE SCHEMA Student_1;
GO

CREATE VIEW Student_1.TheBestCustomers
AS
SELECT TOP (10)
    c.CustomerID,
    c.FirstName,
    c.LastName,
    SUM(soh.TotalDue) AS TotalSales,
    COUNT(*)          AS OrdersCount
FROM [233861].[Customer] c
JOIN SalesLT.SalesOrderHeader soh
    ON soh.CustomerID = c.CustomerID
GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName
ORDER BY
    TotalSales DESC,
    OrdersCount DESC;
GO

-- Klienci, którzy najwięcej wydają, i najwięcej kupują, raczej są dobrymi klientami

-- =============================================
-- Zadanie 3
-- =============================================

CREATE FUNCTION Student_1.ufn_ProductsJsonByCategory
(
    @CategoryName NVARCHAR(50)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @json NVARCHAR(MAX);

    SELECT @json =
    (
        SELECT
            p.ProductID,
            p.Name           AS ProductName,
            pc.Name          AS CategoryName,
            p.ProductNumber,
            p.Color,
            p.Size,
            p.Weight,
            p.ListPrice,
            p.StandardCost
        FROM SalesLT.Product p
        JOIN SalesLT.ProductCategory pc
            ON pc.ProductCategoryID = p.ProductCategoryID
        WHERE pc.Name = @CategoryName
        ORDER BY p.ListPrice DESC, p.ProductID
        FOR JSON PATH, ROOT('Products')
    );

    RETURN @json;
END;
GO


-- =============================================
-- Zadanie 4
-- =============================================

CREATE FUNCTION Student_1.ufn_IsPriceHigherThanCurrent
(
    @ProductJson nvarchar(max)
)
RETURNS bit
AS
BEGIN
    DECLARE @ProductID int =
        TRY_CONVERT(int, JSON_VALUE(@ProductJson, '$.ProductID'));

    DECLARE @NewPrice decimal(19,4) =
        TRY_CONVERT(decimal(19,4), JSON_VALUE(@ProductJson, '$.NewPrice'));

    DECLARE @CurrentPrice decimal(19,4);

    SELECT @CurrentPrice = p.ListPrice
    FROM SalesLT.Product p
    WHERE p.ProductID = @ProductID;
    IF @NewPrice = @CurrentPrice
        RETURN NULL;
    IF @NewPrice > @CurrentPrice
        RETURN 1;

    RETURN 0;
END;
GO

-- Zwróci NULL.

-- =============================================
-- Zadanie 5
-- =============================================

CREATE FUNCTION Student_1.ufn_CheckPricesFromJson
(
    @ProductsJson NVARCHAR(MAX)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        j.ProductID,
        j.NewPrice,
        Student_1.ufn_IsPriceHigherThanCurrent(
            CONCAT(
                '{"ProductID":', j.ProductID,
                ',"NewPrice":', j.NewPrice,
                '}'
            )
        ) AS IsHigherThanCurrent
    FROM OPENJSON(@ProductsJson)
    WITH
    (
        ProductID int           '$.ProductID',
        NewPrice  decimal(19,4) '$.NewPrice'
    ) j
);
GO


-- =============================================
-- Zadanie 6
-- =============================================

-- =============================================
-- Zadanie 7
-- =============================================

-- =============================================
-- Zadanie 8
-- =============================================

-- =============================================
-- Zadanie 9
-- =============================================
