--Practice Quizzes

-- Let's start with creating a table that provides the following details: 
-- actor's first and last name combined as full_name, film title, film description and 
-- length of the movie.
-- 
-- How many rows are there in the table?

SELECT 
	a.first_name first_name,
	a.last_name last_name,
	a.first_name || ' ' || a.last_name AS full_name,
	f.title film_title,
	f.description film_description,
	f.length film_length 
FROM actor a
JOIN film_actor fa
ON a.actor_id = fa.actor_id
JOIN film f
ON fa.film_id = f.film_id
;


-- Write a query that creates a list of actors and movies where the 
-- movie length was more than 60 minutes. How many rows are there in this query result?

SELECT 
	a.first_name || ' ' || a.last_name AS full_name,
	f.title film_title,
	f.length film_length 
FROM actor a
JOIN film_actor fa
ON a.actor_id = fa.actor_id
JOIN film f
ON fa.film_id = f.film_id
WHERE f.length > 60
;


-- Write a query that captures the actor id, full name of the actor, 
-- and counts the number of movies each actor has made. (HINT: Think about 
-- whether you should group by actor id or the full name of the actor.) Identify 
-- the actor who has made the maximum number movies.

SELECT 
	a.actor_id,
	a.first_name || ' ' || a.last_name AS full_name,
	COUNT(f.title) num_movies
FROM actor a
JOIN film_actor fa
ON a.actor_id = fa.actor_id
JOIN film f
ON fa.film_id = f.film_id
GROUP BY 1
ORDER BY num_movies DESC
;


-- Write a query that displays a table with 4 columns: actor's full name, film title, 
-- length of movie, and a column name "filmlen_groups" that classifies movies based on 
-- their length. Filmlen_groups should include 4 categories: 1 hour or less, Between 1-2 hours, 
-- Between 2-3 hours, More than 3 hours.
-- 
-- Match the filmlen_groups with the movie titles in your result dataset.


SELECT 
	a.first_name || ' ' || a.last_name AS full_name,
	f.title film_title,
	f.length film_length,
	CASE WHEN f.length <= 60 THEN '1 hour or less' 
				WHEN f.length > 60 AND f.length <= 120 THEN 'Between 1-2 hours'
				WHEN f.length > 120 AND f.length <= 180 THEN 'Between 2-3 hours'
				ELSE 'More than 3 hours' END AS filmlen_groups
FROM actor a
JOIN film_actor fa
ON a.actor_id = fa.actor_id
JOIN film f
ON fa.film_id = f.film_id
;


-- Now, we bring in the advanced SQL query concepts! Revise the query you wrote 
-- above to create a count of movies in each of the 4 filmlen_groups: 1 hour or less, 
-- Between 1-2 hours, Between 2-3 hours, More than 3 hours.
-- 
-- Match the count of movies in each filmlen_group.

SELECT
	DISTINCT(filmlen_groups),
	COUNT(film_title) OVER (PARTITION BY filmlen_groups) count_num_movies
FROM
	(SELECT 
		f.title film_title,
		f.length film_length,
		CASE WHEN f.length <= 60 THEN '1 hour or less' 
					WHEN f.length > 60 AND f.length <= 120 THEN 'Between 1-2 hours'
					WHEN f.length > 120 AND f.length <= 180 THEN 'Between 2-3 hours'
					ELSE 'More than 3 hours' END AS filmlen_groups
	FROM actor a
	JOIN film_actor fa
	ON a.actor_id = fa.actor_id
	JOIN film f
	ON fa.film_id = f.film_id
	GROUP BY 1,2) t1
;


