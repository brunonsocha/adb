-- =============================================
-- Brunon
-- Socha
-- 233861
-- =============================================

-- =============================================
-- Zadanie 1
-- =============================================

-- https://github.com/BrunonSocha/adb

-- =============================================
-- Zadanie 2
-- =============================================

ALTER TABLE [233861].[Customer] 

ADD 

    SysStartTime DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL DEFAULT SYSUTCDATETIME(),

    SysEndTime DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL DEFAULT CAST('9999-12-31 23:59:59.9999999' AS DATETIME2),

    PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime);



ALTER TABLE [233861].[Customer] 

SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [233861].Customer_History));

-- =============================================
-- Zadanie 3
-- =============================================


UPDATE [233861].[Customer] SET LastName = 'Socha' WHERE CustomerID < 50;
GO;
INSERT INTO [233861].[Customer] (NameStyle, FirstName, LastName, PasswordHash, PasswordSalt) 
VALUES 
    (0, 'Charles', 'Bukowski', HASHBYTES('SHA2_512', 'Haslo'), 'Sol'),
    (0, 'Jane', 'Bukowski', HASHBYTES('SHA2_512', 'Haslo'), 'Sol'),
    (0, 'James', 'Bukowski', HASHBYTES('SHA2_512', 'Haslo'), 'Sol'),
    (0, 'Kate', 'Bukowski', HASHBYTES('SHA2_512', 'Haslo'), 'Sol'),
    (0, 'Elizabeth', 'Bukowski', HASHBYTES('SHA2_512', 'Haslo'), 'Sol');
GO

UPDATE [233861].[Customer] SET LastName = 'Rosolowski' WHERE CustomerID = 5;
GO

UPDATE [233861].[Customer] SET LastName = 'Kempinski' WHERE CustomerID = 5;
GO

-- =============================================
-- Zadanie 4
-- =============================================

SELECT * FROM [233861].[Customer] 
FOR SYSTEM_TIME ALL
WHERE CustomerID = 5;

-- =============================================
-- Zadanie 5
-- =============================================

SELECT * FROM [233861].[Customer] 
FOR SYSTEM_TIME AS OF '2025-12-20 22:00:00';

-- =============================================
-- Zadanie 6
-- =============================================
CREATE XML SCHEMA COLLECTION [SalesLT].[LabSchema] AS 
'<?xml version="1.0" encoding="UTF-8"?>
<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <xsd:element name="Info">
        <xsd:complexType>
            <xsd:sequence>
                <xsd:element name="Weight" type="xsd:string"/>
                <xsd:element name="Color" type="xsd:string"/>
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
</xsd:schema>';
GO

CREATE TABLE [SalesLT].[ProductAttribute] (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    Details XML([SalesLT].[LabSchema]), 
    CONSTRAINT FK_Product FOREIGN KEY (ProductID) REFERENCES [SalesLT].[Product](ProductID)
);
GO

-- =============================================
-- Zadanie 7
-- =============================================

INSERT INTO [SalesLT].[ProductAttribute] (ProductID, Details)
VALUES 
    (710, '<Info><Weight>15kg</Weight><Color>blue</Color></Info>'),
    (711, '<Info><Weight>15kg</Weight><Color>white</Color></Info>'),
    (712, '<Info><Weight>15kg</Weight><Color>yellow</Color></Info>'),
    (713, '<Info><Weight>15kg</Weight><Color>white</Color></Info>'),
    (714, '<Info><Weight>15kg</Weight><Color>blue</Color></Info>');
GO


-- =============================================
-- Zadanie 8
-- =============================================

UPDATE [SalesLT].[ProductAttribute]
SET Details.modify('
    replace value of (/Info/Color)[1]
    with "Blue"
');
GO


-- =============================================
-- Zadanie 9
-- =============================================

DECLARE @jsonC NVARCHAR(MAX) = '{"Product": "RAM"}';

SET @jsonC = JSON_MODIFY(@jsonC, '$.Product', 233861);

SELECT @jsonC AS jsonRes;
