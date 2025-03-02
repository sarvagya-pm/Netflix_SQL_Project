-- " 15 business problems that needs to be resolved: "
SELECT * FROM netflix_db.netflix;
 
-- 1. Count the number of Movies vs TV Shows

select type, count(*) as total_content
from netflix 
group by type;

-- 2. Find the most common rating for movies and TV shows

WITH RatingCounts AS ( 
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS ranking
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE 
type = "Movie"
AND
release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix

SELECT country, COUNT(*) AS total_content
FROM (
    SELECT SUBSTRING_INDEX(country, ',', 1) AS country FROM netflix
    UNION ALL
    SELECT SUBSTRING_INDEX(country, ',', -1) AS country FROM netflix
) AS split_countries
WHERE country IS NOT NULL AND country <> ''
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the longest movie

SELECT 
	*
FROM netflix
WHERE 
type = 'Movie'
AND 
duration = (SELECT MAX(duration) FROM netflix);

-- 6. Find content added in the last 5 years 

SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM netflix
WHERE director LIKE "%Rajiv Chilaka%";

-- 8. List all TV shows with more than 5 seasons

SELECT * FROM netflix
WHERE type = 'TV Show'
AND duration > '5 Seasons';

-- 9. Count the number of content items in each genre

SELECT TRIM(genre) AS genre, COUNT(*) AS content_count
FROM (
    SELECT 
        SUBSTRING_INDEX(listed_in, ',', 1) AS genre FROM netflix
    UNION ALL
    SELECT 
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', 2), ',', -1)) AS genre FROM netflix
    UNION ALL
    SELECT 
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', 3), ',', -1)) AS genre FROM netflix
) AS genre_list
WHERE genre IS NOT NULL AND genre <> ''
GROUP BY genre
ORDER BY content_count DESC;

-- 10.Find each year and the average numbers of content release in India on netflix. Return top 5 year with highest avg content release!

SELECT release_year, COUNT(*) / COUNT(DISTINCT date_added) AS avg_content_per_day
FROM netflix
WHERE country LIKE '%India%'
GROUP BY release_year
ORDER BY avg_content_per_day DESC
LIMIT 5;

-- 11. List all movies that are documentaries

SELECT title
FROM netflix
WHERE type = 'Movie' 
AND listed_in LIKE '%Documentaries%';

-- 12. Find all content without a director

SELECT * FROM netflix
WHERE director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT title, release_year, country 
FROM netflix
WHERE type = 'Movie' 
AND casts LIKE '%Salman Khan%' 
AND release_year >= YEAR(CURDATE()) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(casts, ',', n.n), ',', -1)) AS actor,
    COUNT(*) AS movie_count
FROM netflix
JOIN (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL 
    SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL 
    SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
) n ON CHAR_LENGTH(casts) - CHAR_LENGTH(REPLACE(casts, ',', '')) >= n.n - 1
WHERE type = 'Movie' AND country = 'India'
GROUP BY actor
ORDER BY movie_count DESC
LIMIT 10;

-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. 
-- Label content containing these keywords as 'Bad' and all other content as 'Good'. 
-- Count how many items fall into each category. 

SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2;
