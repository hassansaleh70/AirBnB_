
-- 1. Create the database 
USE AirbnbEuropeDW;
GO

-- 1. Check the number of Bronze tables
SELECT COUNT(*) AS BronzeTables
FROM sys.tables
WHERE schema_id = SCHEMA_ID('bronze')
  AND name <> 'load_log';


-- 2. Check the number of columns in each table
SELECT
    t.name AS TableName,
    COUNT(c.column_id) AS ColumnCount
FROM sys.tables t
JOIN sys.columns c
    ON t.object_id = c.object_id
WHERE t.schema_id = SCHEMA_ID('bronze')
  AND t.name <> 'load_log'
GROUP BY t.name
ORDER BY t.name;


-- 3. Check the total number of rows
SELECT
    SUM(p.rows) AS TotalRows
FROM sys.tables t
JOIN sys.partitions p
    ON t.object_id = p.object_id
WHERE t.schema_id = SCHEMA_ID('bronze')
  AND p.index_id IN (0, 1)
  AND t.name <> 'load_log';

 -- 4. check datatype ,MaxLength , NumericPrecision 
 -- NumericScale and IsNullable for all column 
USE AirbnbEuropeDW;
GO

SELECT
    TABLE_SCHEMA AS SchemaName,
    TABLE_NAME AS TableName,
    COLUMN_NAME AS ColumnName,
    DATA_TYPE AS DataType,
    CHARACTER_MAXIMUM_LENGTH AS MaxLength,
    NUMERIC_PRECISION AS NumericPrecision,
    NUMERIC_SCALE AS NumericScale,
    IS_NULLABLE AS IsNullable
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bronze'
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;



-- 5. Check Logical Errors in Bronze Data
-- Using WHILE Loop and Dynamic SQL


USE AirbnbEuropeDW;
GO

DECLARE @Tables TABLE (
    ID INT IDENTITY(1,1),
    TableName NVARCHAR(128)
);

-- Automatically retrieve all tables from the bronze schema
INSERT INTO @Tables (TableName)
SELECT TABLE_NAME
FROM [AirbnbEuropeDW].INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'bronze'
  AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

DECLARE @Counter INT = 1;
DECLARE @MaxID INT;
DECLARE @TableName NVARCHAR(128);
DECLARE @SQL NVARCHAR(MAX);
DECLARE @RoomSharedType NVARCHAR(128);

SELECT @MaxID = MAX(ID)
FROM @Tables;

WHILE @Counter <= @MaxID
BEGIN
    SELECT @TableName = TableName
    FROM @Tables
    WHERE ID = @Counter;

    PRINT '=====================================================';
    PRINT 'Table: ' + @TableName;
    PRINT '=====================================================';


    -- =====================================================
    -- Data Type Validation
    -- Problem: Some tables store room_shared as NVARCHAR,
    -- while other tables store it as BIT.
    -- Solution: Detect the data type and handle both
    -- representations safely in the validation query.
    -- =====================================================

    SELECT @RoomSharedType = DATA_TYPE
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'bronze'
      AND TABLE_NAME = @TableName
      AND COLUMN_NAME = 'room_shared';

    IF @RoomSharedType = 'nvarchar'
    BEGIN
        PRINT 'WARNING: room_shared is NVARCHAR in this table.';
        PRINT 'Solution: Validate textual Boolean values safely.';
    END
    ELSE IF @RoomSharedType = 'bit'
    BEGIN
        PRINT 'INFO: room_shared is BIT in this table.';
    END
    ELSE
    BEGIN
        PRINT 'WARNING: Unexpected data type for room_shared.';
    END;


    -- =====================================================
    -- 5.1. Check Invalid Capacity, Bedrooms, and Coordinates
    -- =====================================================

    SET @SQL = N'
    SELECT *
    FROM [AirbnbEuropeDW].[bronze].' + QUOTENAME(@TableName) + N'
    WHERE
           [person_capacity] <= 0
        OR [bedrooms] < 0
        OR [lat] NOT BETWEEN -90 AND 90
        OR [lng] NOT BETWEEN -180 AND 180;';

    PRINT '4.1. Invalid Capacity, Bedrooms, and Coordinates';

    EXEC sys.sp_executesql @SQL;


    -- =====================================================
    -- 5.2. Check Logical Errors in Numeric Columns
    -- =====================================================

    SET @SQL = N'
    SELECT *
    FROM [AirbnbEuropeDW].[bronze].' + QUOTENAME(@TableName) + N'
    WHERE
           [realSum] <= 0
        OR [person_capacity] <= 0
        OR [bedrooms] < 0
        OR [cleanliness_rating] NOT BETWEEN 0 AND 10
        OR [guest_satisfaction_overall] NOT BETWEEN 0 AND 100
        OR [dist] < 0
        OR [metro_dist] < 0
        OR [attr_index] < 0
        OR [attr_index_norm] < 0
        OR [rest_index] < 0
        OR [rest_index_norm] < 0;';

    PRINT '4.2. Logical Errors in Numeric Columns';

    EXEC sys.sp_executesql @SQL;


    -- =====================================================
    -- 5.3. Check Missing Values in Important Columns
    -- =====================================================

    SET @SQL = N'
    SELECT *
    FROM [AirbnbEuropeDW].[bronze].' + QUOTENAME(@TableName) + N'
    WHERE
           [realSum] IS NULL
        OR [room_type] IS NULL
        OR [person_capacity] IS NULL
        OR [bedrooms] IS NULL
        OR [cleanliness_rating] IS NULL
        OR [guest_satisfaction_overall] IS NULL
        OR [lat] IS NULL
        OR [lng] IS NULL;';

    PRINT '4.3. Missing Values in Important Columns';

    EXEC sys.sp_executesql @SQL;


    -- =====================================================
    -- 5.4. Check Unexpected Categorical and Boolean Values
    --
    -- Problem:
    -- room_shared may be NVARCHAR ('True'/'False')
    -- or BIT (0/1), depending on the table.
    --
    -- Solution:
    -- Convert Boolean columns to NVARCHAR before checking.
    -- This avoids conversion errors when comparing text
    -- values with numeric values.
    -- =====================================================

    SET @SQL = N'
    SELECT *
    FROM [AirbnbEuropeDW].[bronze].' + QUOTENAME(@TableName) + N'
    WHERE
           (
               [room_type] IS NOT NULL
               AND LTRIM(RTRIM([room_type])) NOT IN (
                   ''Entire home/apt'',
                   ''Private room'',
                   ''Shared room''
               )
           )

        OR (
               [room_shared] IS NOT NULL
               AND LTRIM(RTRIM(
                   CAST([room_shared] AS NVARCHAR(50))
               )) NOT IN (
                   ''0'', ''1'', ''True'', ''False''
               )
           )

        OR (
               [room_private] IS NOT NULL
               AND CAST([room_private] AS NVARCHAR(50))
                   NOT IN (''0'', ''1'')
           )

        OR (
               [host_is_superhost] IS NOT NULL
               AND CAST([host_is_superhost] AS NVARCHAR(50))
                   NOT IN (''0'', ''1'')
           )

        OR (
               [multi] IS NOT NULL
               AND CAST([multi] AS NVARCHAR(50))
                   NOT IN (''0'', ''1'')
           )

        OR (
               [biz] IS NOT NULL
               AND CAST([biz] AS NVARCHAR(50))
                   NOT IN (''0'', ''1'')
           );';

    PRINT '4.4. Unexpected Categorical and Boolean Values';

    EXEC sys.sp_executesql @SQL;


    SET @Counter += 1;
END;


-- 6. Check the actual number of rows in each table
SELECT 'amsterdam_weekdays' AS TableName,
       COUNT(*) AS TotalRows
FROM bronze.amsterdam_weekdays

UNION ALL
SELECT 'amsterdam_weekends', COUNT(*)
FROM bronze.amsterdam_weekends

UNION ALL
SELECT 'athens_weekdays', COUNT(*)
FROM bronze.athens_weekdays

UNION ALL
SELECT 'athens_weekends', COUNT(*)
FROM bronze.athens_weekends

UNION ALL
SELECT 'barcelona_weekdays', COUNT(*)
FROM bronze.barcelona_weekdays

UNION ALL
SELECT 'barcelona_weekends', COUNT(*)
FROM bronze.barcelona_weekends

UNION ALL
SELECT 'berlin_weekdays', COUNT(*)
FROM bronze.berlin_weekdays

UNION ALL
SELECT 'berlin_weekends', COUNT(*)
FROM bronze.berlin_weekends

UNION ALL
SELECT 'budapest_weekdays', COUNT(*)
FROM bronze.budapest_weekdays

UNION ALL
SELECT 'budapest_weekends', COUNT(*)
FROM bronze.budapest_weekends

UNION ALL
SELECT 'lisbon_weekdays', COUNT(*)
FROM bronze.lisbon_weekdays

UNION ALL
SELECT 'lisbon_weekends', COUNT(*)
FROM bronze.lisbon_weekends

UNION ALL
SELECT 'london_weekdays', COUNT(*)
FROM bronze.london_weekdays

UNION ALL
SELECT 'london_weekends', COUNT(*)
FROM bronze.london_weekends

UNION ALL
SELECT 'paris_weekdays', COUNT(*)
FROM bronze.paris_weekdays

UNION ALL
SELECT 'paris_weekends', COUNT(*)
FROM bronze.paris_weekends

UNION ALL
SELECT 'rome_weekdays', COUNT(*)
FROM bronze.rome_weekdays

UNION ALL
SELECT 'rome_weekends', COUNT(*)
FROM bronze.rome_weekends

UNION ALL
SELECT 'vienna_weekdays', COUNT(*)
FROM bronze.vienna_weekdays

UNION ALL
SELECT 'vienna_weekends', COUNT(*)
FROM bronze.vienna_weekends

ORDER BY TableName;


-- 7. Check NULL values in a sample table
SELECT COUNT(*) AS NullRows
FROM bronze.amsterdam_weekdays
WHERE column1 IS NULL
   


USE AirbnbEuropeDW;
GO

-- =====================================================
-- 8. Check Duplicate Records in Bronze Data
-- Purpose: Detect completely duplicated rows
-- Scope: All tables in the bronze schema
-- Note: This script only reads data and does not modify tables.
-- =====================================================

DECLARE @Tables TABLE (
    ID INT IDENTITY(1,1),
    TableName NVARCHAR(128)
);

-- Automatically retrieve all tables from the bronze schema
INSERT INTO @Tables (TableName)
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'bronze'
  AND TABLE_TYPE = 'BASE TABLE';

DECLARE @Counter INT = 1;
DECLARE @MaxID INT;
DECLARE @TableName NVARCHAR(128);
DECLARE @SQL NVARCHAR(MAX);

SELECT @MaxID = MAX(ID)
FROM @Tables;

WHILE @Counter <= ISNULL(@MaxID, 0)
BEGIN
    SELECT @TableName = TableName
    FROM @Tables
    WHERE ID = @Counter;

    PRINT '=====================================================';
    PRINT 'Table: ' + @TableName;
    PRINT '=====================================================';

    -- Check for completely duplicated rows
    SET @SQL = N'
    SELECT
        *,
        COUNT(*) AS DuplicateCount
    FROM [bronze].' + QUOTENAME(@TableName) + N'
    GROUP BY
        [column1],
        [realSum],
        [room_type],
        [room_shared],
        [room_private],
        [person_capacity],
        [host_is_superhost],
        [multi],
        [biz],
        [cleanliness_rating],
        [guest_satisfaction_overall],
        [bedrooms],
        [dist],
        [metro_dist],
        [attr_index],
        [attr_index_norm],
        [rest_index],
        [rest_index_norm],
        [lng],
        [lat]
    HAVING COUNT(*) > 1;';

    EXEC sp_executesql @SQL;

    SET @Counter += 1;
END;

