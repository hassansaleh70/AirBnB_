USE AirbnbEuropeDW;
GO

IF OBJECT_ID('silver.airbnb_master', 'U') IS NOT NULL
    DROP TABLE silver.airbnb_master;
GO

SELECT
    N'Amsterdam' AS city,
    N'Weekday' AS day_type,
    realSum,
    room_type,
    room_shared,
    room_private,
    person_capacity,
    host_is_superhost,
    multi,
    biz,
    cleanliness_rating,
    guest_satisfaction_overall,
    bedrooms,
    dist,
    metro_dist,
    attr_index,
    rest_index,
    lng,
    lat
INTO silver.airbnb_master
FROM silver.amsterdam_weekdays

UNION ALL

SELECT
    N'Amsterdam', N'Weekend',
    realSum, room_type, room_shared, room_private,
    person_capacity, host_is_superhost, multi, biz,
    cleanliness_rating, guest_satisfaction_overall,
    bedrooms, dist, metro_dist, attr_index, rest_index,
    lng, lat
FROM silver.amsterdam_weekends

UNION ALL

SELECT
    N'Athens', N'Weekday',
    realSum, room_type, room_shared, room_private,
    person_capacity, host_is_superhost, multi, biz,
    cleanliness_rating, guest_satisfaction_overall,
    bedrooms, dist, metro_dist, attr_index, rest_index,
    lng, lat
FROM silver.athens_weekdays

UNION ALL

SELECT
    N'Athens', N'Weekend',
    realSum, room_type, room_shared, room_private,
    person_capacity, host_is_superhost, multi, biz,
    cleanliness_rating, guest_satisfaction_overall,
    bedrooms, dist, metro_dist, attr_index, rest_index,
    lng, lat
FROM silver.athens_weekends

UNION ALL

SELECT
    N'Barcelona', N'Weekday',
    realSum, room_type, room_shared, room_private,
    person_capacity, host_is_superhost, multi, biz,
    cleanliness_rating, guest_satisfaction_overall,
    bedrooms, dist, metro_dist, attr_index, rest_index,
    lng, lat
FROM silver.barcelona_weekdays

UNION ALL

SELECT
    N'Barcelona', N'Weekend',
    realSum, room_type, room_shared, room_private,
    person_capacity, host_is_superhost, multi, biz,
    cleanliness_rating, guest_satisfaction_overall,
    bedrooms, dist, metro_dist, attr_index, rest_index,
    lng, lat
FROM silver.barcelona_weekends

UNION ALL

SELECT
    N'Berlin', N'Weekday',
    realSum, room_type, room_shared, room_private,
    person_capacity, host_is_superhost, multi, biz,
    cleanliness_rating, guest_satisfaction_overall,
    bedrooms, dist, metro_dist, attr_index, rest_index,
    lng, lat
FROM silver.berlin_weekdays

UNION ALL

SELECT
    N'Berlin', N'Weekend',
    realSum, room_type, room_shared, room_private,
    person_capacity, host_is_superhost, multi, biz,
    cleanliness_rating, guest_satisfaction_overall,
    bedrooms, dist, metro_dist, attr_index, rest_index,
    lng, lat
FROM silver.berlin_weekends

UNION ALL

SELECT
    N'Budapest', N'Weekday',
    realSum, room_type, room_shared, room_private,
    person_capacity, host_is_superhost, multi, biz,
    cleanliness_rating, guest_satisfaction_overall,
    bedrooms, dist, metro_dist, attr_index, rest_index,
    lng, lat
FROM silver.budapest_weekdays

UNION ALL

SELECT
    N'Budapest', N'Weekend',
    realSum, room_type, room_shared, room_private,
    person_capacity, host_is_superhost, multi, biz,
    cleanliness_rating, guest_satisfaction_overall,
    bedrooms, dist, metro_dist, attr_index, rest_index,
    lng, lat
FROM silver.budapest_weekends

UNION ALL

SELECT
    N'Lisbon', N'Weekday',
    realSum, room_type, room_shared, room_private,
    person_capacity, host_is_superhost, multi, biz,
    cleanliness_rating, guest_satisfaction_overall,
    bedrooms, dist, metro_dist, attr_index, rest_index,
    lng, lat
FROM silver.lisbon_weekdays

UNION ALL

SELECT
    N'Lisbon', N'Weekend',
    realSum, room_type, room_shared, room_private,
    person_capacity, host_is_superhost, multi, biz,
    cleanliness_rating, guest_satisfaction_overall,
    bedrooms, dist, metro_dist, attr_index, rest_index,
    lng, lat
FROM silver.lisbon_weekends

UNION ALL

SELECT
    N'London', N'Weekday',
    realSum, room_type, room_shared, room_private,
    person_capacity, host_is_superhost, multi, biz,
    cleanliness_rating, guest_satisfaction_overall,
    bedrooms, dist, metro_dist, attr_index, rest_index,
    lng, lat
FROM silver.london_weekdays

UNION ALL

SELECT
    N'London', N'Weekend',
    realSum, room_type, room_shared, room_private,
    person_capacity, host_is_superhost, multi, biz,
    cleanliness_rating, guest_satisfaction_overall,
    bedrooms, dist, metro_dist, attr_index, rest_index,
    lng, lat
FROM silver.london_weekends

UNION ALL

SELECT
    N'Paris', N'Weekday',
    realSum, room_type, room_shared, room_private,
    person_capacity, host_is_superhost, multi, biz,
    cleanliness_rating, guest_satisfaction_overall,
    bedrooms, dist, metro_dist, attr_index, rest_index,
    lng, lat
FROM silver.paris_weekdays

UNION ALL

SELECT
    N'Paris', N'Weekend',
    realSum, room_type, room_shared, room_private,
    person_capacity, host_is_superhost, multi, biz,
    cleanliness_rating, guest_satisfaction_overall,
    bedrooms, dist, metro_dist, attr_index, rest_index,
    lng, lat
FROM silver.paris_weekends

UNION ALL

SELECT
    N'Rome', N'Weekday',
    realSum, room_type, room_shared, room_private,
    person_capacity, host_is_superhost, multi, biz,
    cleanliness_rating, guest_satisfaction_overall,
    bedrooms, dist, metro_dist, attr_index, rest_index,
    lng, lat
FROM silver.rome_weekdays

UNION ALL

SELECT
    N'Rome', N'Weekend',
    realSum, room_type, room_shared, room_private,
    person_capacity, host_is_superhost, multi, biz,
    cleanliness_rating, guest_satisfaction_overall,
    bedrooms, dist, metro_dist, attr_index, rest_index,
    lng, lat
FROM silver.rome_weekends

UNION ALL

SELECT
    N'Vienna', N'Weekday',
    realSum, room_type, room_shared, room_private,
    person_capacity, host_is_superhost, multi, biz,
    cleanliness_rating, guest_satisfaction_overall,
    bedrooms, dist, metro_dist, attr_index, rest_index,
    lng, lat
FROM silver.vienna_weekdays

UNION ALL

SELECT
    N'Vienna', N'Weekend',
    realSum, room_type, room_shared, room_private,
    person_capacity, host_is_superhost, multi, biz,
    cleanliness_rating, guest_satisfaction_overall,
    bedrooms, dist, metro_dist, attr_index, rest_index,
    lng, lat
FROM silver.vienna_weekends;
GO


-- Verify total rows
SELECT COUNT_BIG(*) AS TotalRows
FROM silver.airbnb_master;

-- Verify rows by city and day type
SELECT
    city,
    day_type,
    COUNT_BIG(*) AS TotalRows
FROM silver.airbnb_master
GROUP BY city, day_type
ORDER BY city, day_type;


-- check if exist null value or logical erorr
USE AirbnbEuropeDW;
GO

SELECT
    COUNT_BIG(*) AS TotalRows,

    SUM(CASE
        WHEN realSum IS NULL THEN 1
        ELSE 0
    END) AS NullPrices,

    SUM(CASE
        WHEN realSum < 0 THEN 1
        ELSE 0
    END) AS NegativePrices,

    SUM(CASE
        WHEN city IS NULL OR LTRIM(RTRIM(city)) = ''
        THEN 1 ELSE 0
    END) AS MissingCities,

    SUM(CASE
        WHEN day_type NOT IN ('Weekday', 'Weekend')
             OR day_type IS NULL
        THEN 1 ELSE 0
    END) AS InvalidDayTypes,

    SUM(CASE
        WHEN lat IS NULL OR lat NOT BETWEEN -90 AND 90
        THEN 1 ELSE 0
    END) AS InvalidLatitude,

    SUM(CASE
        WHEN lng IS NULL OR lng NOT BETWEEN -180 AND 180
        THEN 1 ELSE 0
    END) AS InvalidLongitude

FROM silver.airbnb_master;
GO


-- type of bedrooms
SELECT
    MIN(realSum) AS MinPrice,
    MAX(realSum) AS MaxPrice,

    MIN(person_capacity) AS MinCapacity,
    MAX(person_capacity) AS MaxCapacity,

    MIN(cleanliness_rating) AS MinCleanlinessRating,
    MAX(cleanliness_rating) AS MaxCleanlinessRating,

    MIN(guest_satisfaction_overall) AS MinGuestSatisfaction,
    MAX(guest_satisfaction_overall) AS MaxGuestSatisfaction,

    MIN(bedrooms) AS MinBedrooms,
    MAX(bedrooms) AS MaxBedrooms

FROM silver.airbnb_master;
GO

