-- =============================================
-- Brunon
-- Socha
-- 233861
-- =============================================

-- =============================================
-- Zadanie 1
-- =============================================

CREATE TYPE [dbo].[B1_surname] FROM nvarchar(50) NOT NULL;
GO

ALTER TABLE [233861].[Customer] ALTER COLUMN [LastName] [dbo].[B1_surname];
GO

-- Zakładam, że chodzi o wszystkie tabele, które do teraz miały kolumnę "LastName" - czyli 233861.Customer.

-- =============================================
-- Zadanie 2
-- =============================================

BEGIN TRANSACTION;

UPDATE [233861].[Customer] 
SET Title = 'Ms.'
WHERE FirstName LIKE '%a';

UPDATE [233861].[Customer]
SET Title = 'Mr.'
WHERE FirstName NOT LIKE '%a';

WAITFOR DELAY '00:05:00';

COMMIT;

-- To query zablokuje całą tabelę na 5 minut. Warunki LIKE '%a' oraz NOT LIKE '%a' zaznaczają wszystkie rekordy - a WAITFOR DELAY opóźnia transakcję o 5 minut. Jest to niebezpieczne, ponieważ blokada nie pozwala na wykonywanie zmian na tabeli.

-- =============================================
-- Zadanie 3
-- =============================================

BEGIN TRANSACTION; 

UPDATE [233861].[Customer]
SET FirstName = 'Bruno'
WHERE CustomerID < 20;

INSERT INTO SalesLT.ProductCategory (Name) VALUES
('Test1'),
('Test2'),
('Test3'),
('Test4'),
('Test5'),
('Test6'),
('Test7'),
('Test8'),
('Test9'),
('Test10');

TRUNCATE TABLE SalesLT.ProductCategories233861;

SELECT FirstName FROM [233861].[Customer] WHERE CustomerID < 20;

SELECT * FROM SalesLT.ProductCategory WHERE Name LIKE 'Test%';

SELECT * FROM SalesLT.ProductCategories233861;

ROLLBACK TRANSACTION;

SELECT FirstName FROM [233861].[Customer] WHERE CustomerID < 20;

SELECT * FROM SalesLT.ProductCategory WHERE Name LIKE 'Test%';

SELECT * FROM SalesLT.ProductCategories233861;

-- Pierwszy SELECT zwraca CustomerID oraz kolumnę FirstName wypełnioną "Bruno".
-- Drugi SELECT zwraca wprowadzone w powyższej transakcji rekordy, zaczynające się od "Test".
-- Trzeci SELECT nie zwraca nic.
-- PO ROLLBACKU
-- Pierwszy SELECT zwraca CustomerID oraz FirstName z różnymi imionami.
-- Drugi SELECT nie zwraca nic - w ProductCategory nie ma rekordów zaczynających się od "Test".
-- Trzeci SELECT zwraca wszystkie rekordy z tabeli.
-- Baza danych zachowuje się tak, bo na początku zadeklarowaliśmy, że wykonujemy transakcję - a później kazaliśmy ją wycofać.

-- =============================================
-- Zadanie 4
-- =============================================

BEGIN TRANSACTION; 

UPDATE [233861].[Customer]
SET FirstName = 'Bruno'
WHERE CustomerID < 20;

INSERT INTO SalesLT.ProductCategory (Name) VALUES
('Test1'),
('Test2'),
('Test3'),
('Test4'),
('Test5'),
('Test6'),
('Test7'),
('Test8'),
('Test9'),
('Test10');

TRUNCATE TABLE SalesLT.ProductCategories233861;

WAITFOR DELAY '00:05:0';

SELECT FirstName FROM [233861].[Customer] WHERE CustomerID < 20;

SELECT * FROM SalesLT.ProductCategory WHERE Name LIKE 'Test%';

SELECT * FROM SalesLT.ProductCategories233861;

ROLLBACK TRANSACTION;

-- Drugie query:

SELECT FirstName FROM [233861].[Customer] WHERE CustomerID < 20 WITH (NOLOCK);

SELECT * FROM SalesLT.ProductCategory WHERE Name LIKE 'Test%' WITH (NOLOCK);

SELECT * FROM SalesLT.ProductCategories233861 WITH (NOLOCK);

-- =============================================
-- Zadanie 5
-- =============================================

BEGIN TRY
    INSERT INTO SalesLT.ProductCategories233861 (Name) VALUES
    (1);
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

-- =============================================
-- Zadanie 6
-- =============================================

-- Zmiana ceny z wychwytywaniem błędów - wyrzuci nasz błąd jeśli produkt nie istnieje, lub spróbujemy zmienić cenę na negatywną.

CREATE PROCEDURE SalesLT.UpdateProductPrice
    @ProductID INT, 
    @NewPrice MONEY
AS
BEGIN
    BEGIN TRY
        IF @NewPrice < 0
        BEGIN
            THROW 50001, 'The price should not be negative', 1;
        END
        IF NOT EXISTS (SELECT * FROM SalesLT.Product WHERE ProductID = @ProductID)
        BEGIN
            THROW 50002, 'This product does not exist', 1;
        END

        UPDATE SalesLT.Product
        SET ListPrice = @NewPrice,
        ModifiedDate = GETDATE()
        WHERE ProductID = @ProductID;
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

-- =============================================
-- Zadanie 7
-- =============================================


CREATE PROCEDURE SalesLT.UpdateProductPrice
    @ProductID INT, 
    @NewPrice MONEY
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @NewPrice < 0
        BEGIN
            THROW 50001, 'The price should not be negative', 1;
        END
        IF NOT EXISTS (SELECT * FROM SalesLT.Product WHERE ProductID = @ProductID)
        BEGIN
            THROW 50002, 'This product does not exist', 1;
        END

        UPDATE SalesLT.Product
        SET ListPrice = @NewPrice,
        ModifiedDate = GETDATE()
        WHERE ProductID = @ProductID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO
