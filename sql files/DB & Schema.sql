IF DB_ID('AirbnbEuropeDW') IS NULL
    CREATE DATABASE AirbnbEuropeDW;
GO

-- 2. Use the database
USE AirbnbEuropeDW;
GO

-- 3. Create the Bronze schema  
IF NOT EXISTS (
    SELECT 1 FROM sys.schemas WHERE name = 'bronze'
)
    EXEC('CREATE SCHEMA bronze');
GO

-- 4. Create the Silver schema 
IF NOT EXISTS (
    SELECT 1 FROM sys.schemas WHERE name = 'silver'
)
    EXEC('CREATE SCHEMA silver');
GO

-- 5. Create the Gold schema 
IF NOT EXISTS (
    SELECT 1 FROM sys.schemas WHERE name = 'gold'
)
    EXEC('CREATE SCHEMA gold');
GO
