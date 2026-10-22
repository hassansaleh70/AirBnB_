
USE AirbnbEuropeDW;
GO

SET NOCOUNT ON;

-- =========================================================
-- Silver Layer: Airbnb Europe
-- Purpose:
-- 1. Convert source columns to appropriate data types.
-- 2. Standardize room_shared across all source tables.
-- 3. Trim room_type and convert empty strings to NULL.
-- 4. Remove column1, attr_index_norm, and rest_index_norm.
-- 5. Create 20 Silver tables from the corresponding Bronze tables.
-- 6. Stop if any destination table already exists.
-- =========================================================

DECLARE @Tables TABLE
(
    TableName SYSNAME PRIMARY KEY
);

INSERT INTO @Tables (TableName)
VALUES
    ('amsterdam_weekdays'),
    ('amsterdam_weekends'),
    ('athens_weekdays'),
    ('athens_weekends'),
    ('barcelona_weekdays'),
    ('barcelona_weekends'),
    ('berlin_weekdays'),
    ('berlin_weekends'),
    ('budapest_weekdays'),
    ('budapest_weekends'),
    ('lisbon_weekdays'),
    ('lisbon_weekends'),
    ('london_weekdays'),
    ('london_weekends'),
    ('paris_weekdays'),
    ('paris_weekends'),
    ('rome_weekdays'),
    ('rome_weekends'),
    ('vienna_weekdays'),
    ('vienna_weekends');

DECLARE @TableName SYSNAME;
DECLARE @SQL NVARCHAR(MAX);

-- ---------------------------------------------------------
-- Pre-check 1: Ensure all Bronze source tables exist.
-- ---------------------------------------------------------

IF EXISTS
(
    SELECT 1
    FROM @Tables AS t
    WHERE OBJECT_ID(
        QUOTENAME('bronze') + '.' + QUOTENAME(t.TableName),
        'U'
    ) IS NULL
)
BEGIN
    SELECT
        t.TableName AS MissingBronzeTable
    FROM @Tables AS t
    WHERE OBJECT_ID(
        QUOTENAME('bronze') + '.' + QUOTENAME(t.TableName),
        'U'
    ) IS NULL;

    THROW 50001, 'One or more Bronze source tables are missing.', 1;
END;

-- ---------------------------------------------------------
-- Pre-check 2: Stop if any Silver destination already exists.
-- No existing Silver tables will be dropped or overwritten.
-- ---------------------------------------------------------

IF EXISTS
(
    SELECT 1
    FROM @Tables AS t
    WHERE OBJECT_ID(
        QUOTENAME('silver') + '.' + QUOTENAME(t.TableName),
        'U'
    ) IS NOT NULL
)
BEGIN
    SELECT
        t.TableName AS ExistingSilverTable
    FROM @Tables AS t
    WHERE OBJECT_ID(
        QUOTENAME('silver') + '.' + QUOTENAME(t.TableName),
        'U'
    ) IS NOT NULL;

    THROW 50002,
          'At least one Silver destination table already exists. No tables were created.',
          1;
END;

-- ---------------------------------------------------------
-- Create Silver tables.
-- ---------------------------------------------------------

DECLARE TableCursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT TableName
    FROM @Tables
    ORDER BY TableName;

OPEN TableCursor;

FETCH NEXT FROM TableCursor INTO @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = N'
    SELECT
        TRY_CAST([realSum] AS DECIMAL(18,4))
            AS [realSum],

        NULLIF(
            LTRIM(RTRIM([room_type])),
            N''''
        ) AS [room_type],

        CASE
            WHEN LOWER(LTRIM(RTRIM(
                CAST([room_shared] AS NVARCHAR(50))
            ))) IN (N''1'', N''true'')
                THEN CAST(1 AS BIT)

            WHEN LOWER(LTRIM(RTRIM(
                CAST([room_shared] AS NVARCHAR(50))
            ))) IN (N''0'', N''false'')
                THEN CAST(0 AS BIT)

            ELSE TRY_CAST([room_shared] AS BIT)
        END AS [room_shared],

        TRY_CAST([room_private] AS BIT)
            AS [room_private],

        TRY_CAST([person_capacity] AS INT)
            AS [person_capacity],

        TRY_CAST([host_is_superhost] AS BIT)
            AS [host_is_superhost],

        TRY_CAST([multi] AS BIT)
            AS [multi],

        TRY_CAST([biz] AS BIT)
            AS [biz],

        TRY_CAST([cleanliness_rating] AS FLOAT)
            AS [cleanliness_rating],

        TRY_CAST([guest_satisfaction_overall] AS FLOAT)
            AS [guest_satisfaction_overall],

        TRY_CAST([bedrooms] AS TINYINT)
            AS [bedrooms],

        TRY_CAST([dist] AS DECIMAL(18,4))
            AS [dist],

        TRY_CAST([metro_dist] AS DECIMAL(18,4))
            AS [metro_dist],

        TRY_CAST([attr_index] AS DECIMAL(18,4))
            AS [attr_index],

        TRY_CAST([rest_index] AS DECIMAL(18,4))
            AS [rest_index],

        TRY_CAST([lng] AS FLOAT)
            AS [lng],

        TRY_CAST([lat] AS FLOAT)
            AS [lat]

    INTO [silver].' + QUOTENAME(@TableName) + N'
    FROM [bronze].' + QUOTENAME(@TableName) + N';';

    EXEC sys.sp_executesql @SQL;

    PRINT N'Created silver.' + @TableName;

    FETCH NEXT FROM TableCursor INTO @TableName;
END;

CLOSE TableCursor;
DEALLOCATE TableCursor;

PRINT 'Silver table creation completed.';
GO

USE AirbnbEuropeDW;
GO
USE AirbnbEuropeDW;
GO



