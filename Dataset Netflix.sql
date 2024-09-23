--Netflix Project

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

select COUNT(*)
from netflix;

-- 1.Count the Number of Movies vs TV Shows
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;


-- 2.Find the Most Common Rating for Movies and TV Shows
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
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

-- 3.List All Movies Released in a Specific Year (e.g., 2020)
SELECT * 
FROM netflix
WHERE release_year = 2020;


-- 4.Find the Top 5 Countries with the Most Content on Netflix
SELECT 
		UNNEST(STRING_TO_ARRAY(country, ',')) as New_country,
		COUNT(show_id)as Totral_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
-- SELECT 
-- 		UNNEST(STRING_TO_ARRAY(country, ',')) as New_country --for seperate the data
-- FROM netflix

-- 5. Identify the Longest Movie
SELECT *
FROM netflix
WHERE 
		type = 'Movie'
		AND
		duration =(SELECT MAX(duration)FROM netflix)


-- 6.Find Content Added in the Last 5 Years
SELECT 
		*,
		TO_DATE(date_added,'Month DD, YYYY') --Convert the date function
FROM netflix
WHERE 
		TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL  '5 years';

SELECT  CURRENT_DATE - INTERVAL  '5 years'

-- 7. Find all the Shows/Movie Directed by 'Rajiv Chilaka'
SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

-- 8. List all the TV Shows more than five seasons
SELECT 
		*
FROM netflix
WHERE 
		type='TV Show'
		AND
		SPLIT_PART(duration, ' ',1)::numeric > 5 --split part to convert the season and numeric to convert the data

--9.Count the Number of Content Items in Each Genre
SELECT 
		UNNEST(STRING_TO_ARRAY(listed_in,',')) as Genre,
		COUNT(show_id) as Total_Content
FROM netflix
GROUP BY 1;

--10.Find each year and the average numbers of content 
--release in India on netflix.

SELECT 
		EXTRACT (YEAR FROM TO_DATE(date_added, 'MONTH DD,YYYY'))as Year,
		COUNT(*),
		ROUND(
		COUNT(*)::numeric/(
		SELECT 
				COUNT (*) 
		FROM netflix 
		WHERE country = 'India')::numeric*100,2) as Average
FROM netflix
WHERE country = 'India'
GROUP BY 1

--11.List All Movies that are Documentaries
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

--12. Find All Content Without a Director
SELECT *
FROM netflix
WHERE director is NULL;

--13. Find How Many Movies Actor 'Salman Khan' 
--Appeared in the Last 10 Years

SELECT *
FROM netflix
WHERE  casts LIKE '%Salman Khan%'
		AND
		release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


--14.Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

SELECT 
		UNNEST(STRING_TO_ARRAY(title,',')) as Actor,
		COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;


--15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

WITH new_table
AS
(
SELECT 	
		*,
		CASE
		WHEN 
			description ILIKE '%kill%' 
			OR 
			description ILIKE '%violence%' THEN 'Bad_Content'
			ELSE 'Good_Content'
		END category
FROM netflix
)
SELECT 
		category,
		COUNT(*) as Total_content
FROM new_table
GROUP BY 1



SELECT *
FROM netflix
WHERE 
		description ILIKE '%kill%'  
		OR
		description ILIKE '%violence%'  