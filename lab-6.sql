-- =============================================
-- Brunon
-- Socha
-- 233861
-- =============================================

-- =============================================
-- Zadanie 1
-- =============================================

CREATE PROCEDURE SalesLT.CreateCustomer
    @FirstName NVARCHAR(50),
    @LastName [dbo].[B1_surname],
    @EmailAddress NVARCHAR(50), 
    @CompanyName NVARCHAR(128) = NULL,
    @Phone NVARCHAR(25) = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
        IF @FirstName IS NULL OR @LastName IS NULL OR @EmailAddress IS NULL
        BEGIN
            THROW 50001, 'FirstName, LastName and EmailAddress fields cannot be null.', 1;
        END

        IF EXISTS (SELECT * FROM [233861].[Customer] WHERE EmailAddress = @EmailAddress)
        BEGIN
            THROW 50002, 'There already exist a customer with this email.', 1;
        END

        INSERT INTO [233861].[Customer] (FirstName, LastName, CompanyName, EmailAddress, Phone, PasswordHash, PasswordSalt, ModifiedDate, rowguid) VALUES (
        @FirstName,
        @LastName,
        @CompanyName,
        @EmailAddress,
        @Phone,
        'x',
        'x',
        GETDATE(),
        NEWID()
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END
    END CATCH
END;

-- =============================================
-- Zadanie 2
-- =============================================

CREATE PROCEDURE SalesLT.SearchCustomers
    @CustomerID INT = NULL,
    @FirstName NVARCHAR(50) = NULL,
    @LastName [dbo].[B1_surname] = NULL,
    @EmailAddress NVARCHAR(50) = NULL
AS
BEGIN
    SELECT * FROM [233861].[Customer]
    WHERE
    (CustomerID = @CustomerID OR @CustomerID IS NULL)
    AND
    (FirstName = @FirstName OR @FirstName IS NULL)
    AND
    (LastName = @LastName OR @LastName IS NULL)
    AND
    (EmailAddress = @EmailAddress OR @EmailAddress IS NULL);
END;
GO

-- =============================================
-- Zadanie 3
-- =============================================

-- W moim przypadku w bazie danych miałem już GetCustomerOrderHistory - (nie wiem dlaczego) - więc użyłem ALTER PROCEDURE (...) zamiast CREATE PROCEDURE.

CREATE PROCEDURE SalesLT.GetCustomerOrderHistory
    @CustomerID INT
AS
BEGIN
    SELECT p.Name AS ProductName, h.OrderDate, d.OrderQty, d.LineTotal AS Price
    FROM SalesLT.SalesOrderHeader AS h 
    INNER JOIN SalesLT.SalesOrderDetail AS d
    ON h.SalesOrderID = d.SalesOrderID 
    INNER JOIN SalesLT.Product AS p 
    ON d.ProductID = p.ProductID;
END;
GO

-- =============================================
-- Zadanie 4
-- =============================================

CREATE FUNCTION SalesLT.CustomerExists (
    @EmailAddress NVARCHAR(50)
) 
RETURNS BIT
AS
BEGIN
    DECLARE @Res BIT = 0;
    IF EXISTS (SELECT * FROM [233861].[Customer] WHERE EmailAddress = @EmailAddress)
    BEGIN
        SET @Res = 1;
    END
    RETURN @Res;
END;
GO


ALTER PROCEDURE SalesLT.CreateCustomer
    @FirstName NVARCHAR(50),
    @LastName [dbo].[B1_surname],
    @EmailAddress NVARCHAR(50), 
    @CompanyName NVARCHAR(128) = NULL,
    @Phone NVARCHAR(25) = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
        IF @FirstName IS NULL OR @LastName IS NULL OR @EmailAddress IS NULL
        BEGIN
            THROW 50001, 'FirstName, LastName and EmailAddress fields cannot be null.', 1;
        END

        IF SalesLT.CustomerExists(@EmailAddress) = 1
        BEGIN
            THROW 50002, 'There already exist a customer with this email.', 1;
        END

        INSERT INTO [233861].[Customer] (FirstName, LastName, CompanyName, EmailAddress, Phone, PasswordHash, PasswordSalt, ModifiedDate, rowguid) VALUES (
        @FirstName,
        @LastName,
        @CompanyName,
        @EmailAddress,
        @Phone,
        'x',
        'x',
        GETDATE(),
        NEWID()
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END
    END CATCH
END;

-- =============================================
-- Zadanie 5
-- =============================================

CREATE PROCEDURE SalesLT.UpdateCustomerData
    @EmailAddress NVARCHAR(50),
    @FirstName NVARCHAR(50),
    @LastName [dbo].[B1_surname],
    @CompanyName NVARCHAR(128),
    @Phone NVARCHAR(25) = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            IF SalesLT.CustomerExists(@EmailAddress) = 0
            BEGIN 
                THROW 50001, 'User with such an email does not exist', 1;
            END
            UPDATE [233861].[Customer]
            SET 
            FirstName = @FirstName,
            LastName = @LastName,
            CompanyName = @CompanyName,
            Phone = @Phone,
            ModifiedDate = GETDATE()
            WHERE EmailAddress = @EmailAddress;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END
    END CATCH
END;
GO


-- =============================================
-- Zadanie 6
-- =============================================

-- Pominąłem któreś zadanie? Nie widzę nigdzie w bazie danych tabeli ProductInventory

CREATE TABLE SalesLT.ProductInventory (
    ProductID INT PRIMARY KEY,
    Quantity INT NOT NULL DEFAULT 0,
    CONSTRAINT FK_PI_Product FOREIGN KEY (ProductID) REFERENCES SalesLT.Product (ProductID)
);
GO

CREATE PROCEDURE SalesLT.AddNewProduct
    @Name NVARCHAR(50),
    @ProductNumber NVARCHAR(50),
    @ProductCategoryID INT,
    @ListPrice MONEY,
    @Quantity INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            IF @ListPrice <= 0
            BEGIN
                THROW 50001, 'Price cannot be zero or less.', 1;
            END

            IF @Quantity < 0
            BEGIN
                THROW 50002, 'Quantity cannot be negative', 1;
            END

            INSERT INTO SalesLT.Product (
                Name,
                ProductNumber,
                StandardCost,
                ListPrice,
                ProductCategoryID,
                SellStartDate,
                rowguid,
                ModifiedDate
            )
            VALUES (
                @Name,
                @ProductNumber,
                0,
                @ListPrice,
                @ProductCategoryID,
                GETDATE(),
                NEWID(),
                GETDATE()
            );

            DECLARE @NewProductID INT = SCOPE_IDENTITY();

            INSERT INTO SalesLT.ProductInventory(ProductID, Quantity)
            VALUES (
                @NewProductID,
                @Quantity
            );

            COMMIT TRANSACTION;

        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
            BEGIN
                ROLLBACK TRANSACTION;
            END
        END CATCH
END;
GO

-- =============================================
-- Zadanie 7
-- =============================================

CREATE PROCEDURE Student_1.DiscountPrice
AS
BEGIN
    SELECT ProductID, Name, ListPrice AS OldPrice, (ListPrice - (ListPrice * 0.01)) AS NewPrice FROM #TopProducts;
END;
GO

CREATE TABLE #TopProducts (
    ProductID INT PRIMARY KEY,
    Name NVARCHAR(50),
    ListPrice MONEY
);

INSERT INTO #TopProducts (ProductID, Name, ListPrice) SELECT TOP 25 ProductID, Name, ListPrice
FROM SalesLT.Product
ORDER BY ListPrice DESC;

DECLARE @Summary TABLE (
    ProductID INT,
    Name NVARCHAR(50),
    OldPrice MONEY,
    NewPrice MONEY
);

INSERT INTO @Summary EXEC Student_1.DiscountPrice;

SELECT * FROM @Summary;
DROP TABLE #TopProducts;
GO

