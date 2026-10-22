

SELECT COUNT(*) AS TotalListings
FROM silver.airbnb_scraped;

SELECT city, COUNT(*) AS ListingsCount
FROM silver.airbnb_scraped
GROUP BY city
ORDER BY city;

--------------------



SELECT TOP (10)
    Name,
    city,
    Price,
    Superhost,
    is_fav,
    Rating,
    Reviews,
    URL
FROM silver.airbnb_scraped
ORDER BY city, Rating DESC;

