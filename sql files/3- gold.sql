USE AirbnbEuropeDW;
GO

IF SCHEMA_ID('gold') IS NULL
    EXEC('CREATE SCHEMA gold');
GO

-- 1. City Dimension
CREATE TABLE gold.DimCity (
    CityKey INT IDENTITY(1,1) PRIMARY KEY,
    CityName NVARCHAR(50) NOT NULL UNIQUE
);
GO

-- 2. Room Type Dimension
CREATE TABLE gold.DimRoomType (
    RoomTypeKey INT IDENTITY(1,1) PRIMARY KEY,
    RoomType NVARCHAR(100) NOT NULL UNIQUE
);
GO

-- 3. Day Type Dimension
CREATE TABLE gold.DimDayType (
    DayTypeKey INT IDENTITY(1,1) PRIMARY KEY,
    DayType NVARCHAR(20) NOT NULL UNIQUE
);
GO

-- 4. Listing Profile Dimension
CREATE TABLE gold.DimListingProfile (
    ListingProfileKey INT IDENTITY(1,1) PRIMARY KEY,
    RoomShared BIT NULL,
    RoomPrivate BIT NULL,
    PersonCapacity INT NULL,
    HostIsSuperhost BIT NULL,
    Multi BIT NULL,
    Biz BIT NULL,
    CleanlinessRating FLOAT NULL,
    GuestSatisfactionOverall FLOAT NULL,
    Bedrooms TINYINT NULL
);
GO



----------------
-- Populate City Dimension
INSERT INTO gold.DimCity (CityName)
SELECT DISTINCT city
FROM silver.airbnb_master
WHERE city IS NOT NULL;
GO

-- Populate Room Type Dimension
INSERT INTO gold.DimRoomType (RoomType)
SELECT DISTINCT COALESCE(room_type, N'Unknown')
FROM silver.airbnb_master;
GO

-- Populate Day Type Dimension
INSERT INTO gold.DimDayType (DayType)
SELECT DISTINCT day_type
FROM silver.airbnb_master
WHERE day_type IS NOT NULL;
GO

-- Populate Listing Profile Dimension
INSERT INTO gold.DimListingProfile (
    RoomShared,
    RoomPrivate,
    PersonCapacity,
    HostIsSuperhost,
    Multi,
    Biz,
    CleanlinessRating,
    GuestSatisfactionOverall,
    Bedrooms
)
SELECT DISTINCT
    room_shared,
    room_private,
    person_capacity,
    host_is_superhost,
    multi,
    biz,
    cleanliness_rating,
    guest_satisfaction_overall,
    bedrooms
FROM silver.airbnb_master;
GO



----------------
SELECT 'DimCity' AS TableName, COUNT(*) AS TotalRows
FROM gold.DimCity

UNION ALL

SELECT 'DimRoomType', COUNT(*)
FROM gold.DimRoomType

UNION ALL

SELECT 'DimDayType', COUNT(*)
FROM gold.DimDayType

UNION ALL

SELECT 'DimListingProfile', COUNT(*)
FROM gold.DimListingProfile;






----------------
USE AirbnbEuropeDW;
GO

CREATE TABLE gold.FactAirbnb (
    FactKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    CityKey INT NOT NULL,
    RoomTypeKey INT NOT NULL,
    DayTypeKey INT NOT NULL,
    ListingProfileKey INT NOT NULL,

    RealSum DECIMAL(18,4) NULL,
    Dist DECIMAL(18,4) NULL,
    MetroDist DECIMAL(18,4) NULL,
    AttrIndex DECIMAL(18,4) NULL,
    RestIndex DECIMAL(18,4) NULL,

    Longitude FLOAT NULL,
    Latitude FLOAT NULL,

    CONSTRAINT FK_FactAirbnb_DimCity
        FOREIGN KEY (CityKey)
        REFERENCES gold.DimCity(CityKey),

    CONSTRAINT FK_FactAirbnb_DimRoomType
        FOREIGN KEY (RoomTypeKey)
        REFERENCES gold.DimRoomType(RoomTypeKey),

    CONSTRAINT FK_FactAirbnb_DimDayType
        FOREIGN KEY (DayTypeKey)
        REFERENCES gold.DimDayType(DayTypeKey),

    CONSTRAINT FK_FactAirbnb_DimListingProfile
        FOREIGN KEY (ListingProfileKey)
        REFERENCES gold.DimListingProfile(ListingProfileKey)
);
GO




------------------------
INSERT INTO gold.FactAirbnb (
    CityKey,
    RoomTypeKey,
    DayTypeKey,
    ListingProfileKey,
    RealSum,
    Dist,
    MetroDist,
    AttrIndex,
    RestIndex,
    Longitude,
    Latitude
)
SELECT
    c.CityKey,
    r.RoomTypeKey,
    d.DayTypeKey,
    p.ListingProfileKey,
    s.realSum,
    s.dist,
    s.metro_dist,
    s.attr_index,
    s.rest_index,
    s.lng,
    s.lat
FROM silver.airbnb_master AS s

INNER JOIN gold.DimCity AS c
    ON c.CityName = s.city

INNER JOIN gold.DimRoomType AS r
    ON r.RoomType = COALESCE(s.room_type, N'Unknown')

INNER JOIN gold.DimDayType AS d
    ON d.DayType = s.day_type

INNER JOIN gold.DimListingProfile AS p
    ON (p.RoomShared = s.room_shared
        OR (p.RoomShared IS NULL AND s.room_shared IS NULL))
    AND (p.RoomPrivate = s.room_private
        OR (p.RoomPrivate IS NULL AND s.room_private IS NULL))
    AND (p.PersonCapacity = s.person_capacity
        OR (p.PersonCapacity IS NULL AND s.person_capacity IS NULL))
    AND (p.HostIsSuperhost = s.host_is_superhost
        OR (p.HostIsSuperhost IS NULL AND s.host_is_superhost IS NULL))
    AND (p.Multi = s.multi
        OR (p.Multi IS NULL AND s.multi IS NULL))
    AND (p.Biz = s.biz
        OR (p.Biz IS NULL AND s.biz IS NULL))
    AND (p.CleanlinessRating = s.cleanliness_rating
        OR (p.CleanlinessRating IS NULL AND s.cleanliness_rating IS NULL))
    AND (p.GuestSatisfactionOverall = s.guest_satisfaction_overall
        OR (p.GuestSatisfactionOverall IS NULL AND s.guest_satisfaction_overall IS NULL))
    AND (p.Bedrooms = s.bedrooms
        OR (p.Bedrooms IS NULL AND s.bedrooms IS NULL));
GO




-----------------
SELECT COUNT(*) AS FactRows
FROM gold.FactAirbnb;

-------------
USE AirbnbEuropeDW;
GO

-- 1. Compare row counts
SELECT
    (SELECT COUNT(*) FROM silver.airbnb_master) AS SilverRows,
    (SELECT COUNT(*) FROM gold.FactAirbnb) AS FactRows;

-- 2. Check foreign key relationships
SELECT
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS FactTable,
    OBJECT_NAME(fk.referenced_object_id) AS DimensionTable
FROM sys.foreign_keys AS fk
WHERE fk.parent_object_id = OBJECT_ID('gold.FactAirbnb');

-- 3. Check fact table distribution
SELECT
    c.CityName,
    d.DayType,
    COUNT(*) AS TotalListings,
    AVG(f.RealSum) AS AveragePrice
FROM gold.FactAirbnb AS f
JOIN gold.DimCity AS c
    ON f.CityKey = c.CityKey
JOIN gold.DimDayType AS d
    ON f.DayTypeKey = d.DayTypeKey
GROUP BY
    c.CityName,
    d.DayType
ORDER BY
    c.CityName,
    d.DayType;



-----------------
USE AirbnbEuropeDW;
GO

SELECT
    (SELECT COUNT(*) FROM silver.airbnb_master) AS SilverRows,
    (SELECT COUNT(*) FROM gold.FactAirbnb) AS FactRows,
    (SELECT COUNT(*) FROM gold.DimCity) AS Cities,
    (SELECT COUNT(*) FROM gold.DimRoomType) AS RoomTypes,
    (SELECT COUNT(*) FROM gold.DimDayType) AS DayTypes,
    (SELECT COUNT(*) FROM gold.DimListingProfile) AS ListingProfiles;
GO

DBCC CHECKCONSTRAINTS ('gold.FactAirbnb');
GO