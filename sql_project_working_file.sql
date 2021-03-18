-- Question 1
-- We want to understand more about the movies that families are watching. The following 
-- categories are considered family movies: Animation, Children, Classics, Comedy, Family and Music.
-- 
-- Create a query that lists each movie, the film category it is classified in, and the 
-- number of times it has been rented out.
-- 
-- Check Your Solution
-- For this query, you will need 5 tables: Category, Film_Category, Inventory, Rental and 
-- Film. Your solution should have three columns: Film title, Category name and Count of Rentals.
-- 
-- The following table header provides a preview of what the resulting table should look like 
-- if you order by category name followed by the film title.
-- 
-- HINT: One way to solve this is to create a count of movies using aggregations, subqueries 
-- and Window functions.

SELECT 
		f.title film_title,
		c.name category,
		COUNT(r.rental_date) rental_date	
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN film f
ON f.film_id = fc.film_id
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
WHERE c.name = 'Animation' OR c.name = 'Children' OR c.name = 'Classics' OR c.name = 'Comedy' OR
			c.name = 'Family' OR c.name = 'Music'
GROUP BY 1,2
ORDER BY 2,1;


--total rentals of family movies
WITH total_rentals AS (
				SELECT 
					COUNT(rental_date) tot_rentals
				FROM category c
				JOIN film_category fc
				ON c.category_id = fc.category_id
				JOIN film f
				ON f.film_id = fc.film_id
				JOIN inventory i
				ON f.film_id = i.film_id
				JOIN rental r
				ON i.inventory_id = r.inventory_id
				WHERE c.name = 'Animation' OR c.name = 'Children' OR c.name = 'Classics' OR c.name = 'Comedy' OR
							c.name = 'Family' OR c.name = 'Music');



-- What type of movie did families rent the most? The following categories are considered 
-- family movies: Animation, Children, Classics, Comedy, Family and Music.

WITH fam_rentals AS	(
				SELECT 
					c.name category,
					COUNT(r.rental_date) rental_times	
				FROM category c
				JOIN film_category fc
				ON c.category_id = fc.category_id
				JOIN film f
				ON f.film_id = fc.film_id
				JOIN inventory i
				ON f.film_id = i.film_id
				JOIN rental r
				ON i.inventory_id = r.inventory_id
				WHERE c.name = 'Animation' OR c.name = 'Children' OR c.name = 'Classics' OR c.name = 'Comedy' OR
						c.name = 'Family' OR c.name = 'Music'
				GROUP BY 1
				ORDER BY 2 DESC)

SELECT
	category,
	rental_times,
	100 * rental_times / SUM(rental_times) OVER () AS perc
FROM fam_rentals
GROUP BY 1,2
ORDER BY 2 DESC
;




-- Question 2
-- Now we need to know how the length of rental duration of these family-friendly movies 
-- compares to the duration that all movies are rented for. Can you provide a table with the 
-- movie titles and divide them into 4 levels (first_quarter, second_quarter, third_quarter, 
-- and final_quarter) based on the quartiles (25%, 50%, 75%) of the rental duration for movies 
-- across all categories? Make sure to also indicate the category that these family-friendly 
-- movies fall into.
-- 
-- Check Your Solution
-- The data are not very spread out to create a very fun looking solution, but you should see 
-- something like the following if you correctly split your data. You should only need the 
-- category, film_category, and film tables to answer this and the next questions. 
-- 
-- HINT: One way to solve it requires the use of percentiles, Window functions, subqueries or 
-- temporary tables.



SELECT 
		f.title film_title,
		c.name category,
		f.rental_duration,
		NTILE(4) OVER (PARTITION BY f.rental_duration ORDER BY f.title) as standard_quartile
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN film f
ON f.film_id = fc.film_id
;





-- Question 3
-- Finally, provide a table with the family-friendly film category, each of the quartiles, 
-- and the corresponding count of movies within each combination of film category for each 
-- corresponding rental duration category. The resulting table should have three columns:
-- 
-- 		Category
-- 		Rental length category
-- 		Count
-- 
-- Check Your Solution
-- The following table header provides a preview of what your table should look like. The 
-- Count column should be sorted first by Category and then by Rental Duration category.
-- 
-- HINT: One way to solve this question requires the use of Percentiles, Window functions 
-- and Case statements.



WITH t1 AS (
						SELECT 
								f.title film_title,
								c.name category,
								COUNT(r.rental_date) count_rented	
						FROM category c
						JOIN film_category fc
						ON c.category_id = fc.category_id
						JOIN film f
						ON f.film_id = fc.film_id
						JOIN inventory i
						ON f.film_id = i.film_id
						JOIN rental r
						ON i.inventory_id = r.inventory_id
						WHERE c.name = 'Animation' OR c.name = 'Children' OR c.name = 'Classics' OR c.name = 'Comedy' OR
									c.name = 'Family' OR c.name = 'Music'
						GROUP BY 1,2),
						
		t2 AS (
						SELECT 
								f.title film_title,
								c.name category,
								f.rental_duration,
								NTILE(4) OVER (PARTITION BY f.rental_duration ORDER BY f.title) as standard_quartile
						FROM category c
						JOIN film_category fc
						ON c.category_id = fc.category_id
						JOIN film f
						ON f.film_id = fc.film_id)

SELECT 
	t1.category, t2.standard_quartile, t1.count_rented
FROM t1
JOIN t2
ON t1.film_title = t2.film_title
ORDER BY 1,2 
;








--QUESTION SET 2

-- Question 1:
-- We want to find out how the two stores compare in their count of rental orders during every 
-- month for all the years we have data for. Write a query that returns the store ID for the store, 
-- the year and month and the number of rental orders each store has fulfilled for that month. Your 
-- table should include a column for each of the following: year, month, store ID and count of rental 
-- orders fulfilled during that month.
-- 
-- Check Your Solution
-- The following table header provides a preview of what your table should look like. The count of rental 
-- orders is sorted in descending order.
-- 
-- HINT: One way to solve this query is the use of aggregations.

SELECT 
		DATE_PART('month', rental_date) rent_month,
		DATE_PART('year', rental_date) rent_year,
		s.store_id,
		COUNT(*) num_rentals
FROM staff s
JOIN rental r
ON s.staff_id = r.staff_id
GROUP BY 1,2,3
ORDER BY 4 DESC
;

-- Question 1 ADJUSTED:
-- Which store was busier during the summer of 2005 and how much money did they make?

--ADD IN MONEY MADE DURING MONTHS

SELECT 
		DATE_PART('month', rental_date) rent_month,
		DATE_PART('year', rental_date) rent_year,
		s.store_id,
		COUNT(*) num_rentals,
		SUM(p.amount)
FROM staff s
JOIN rental r
ON s.staff_id = r.staff_id
JOIN payment p
ON r.rental_id = p.rental_id
WHERE DATE_PART('month', rental_date) BETWEEN '6' AND '8'
GROUP BY 1,2,3
ORDER BY 1,3
;

-- Question 2
-- We would like to know who were our top 10 paying customers, how many payments they made on a 
-- monthly basis during 2007, and what was the amount of the monthly payments. Can you write a 
-- query to capture the customer name, month and year of payment, and total payment amount for each 
-- month by these top 10 paying customers?
-- 
-- Check your Solution:
-- The following table header provides a preview of what your table should look like. The results are 
-- sorted first by customer name and then for each month. As you can see, total amounts per month are 
-- listed for each customer.
-- 
-- HINT: One way to solve is to use a subquery, limit within the subquery, and use concatenation to 
-- generate the customer name.

WITH  top_customers AS (
						SELECT 
								c.customer_id customer,
								c.first_name first_name,
								c.last_name last_name,
								SUM(p.amount) total_paid
						FROM customer c
						JOIN payment p
						ON c.customer_id = p.customer_id
						GROUP BY 1,2,3
						ORDER BY 4 DESC
						LIMIT 10)

SELECT 
		DATE_TRUNC('month', p.payment_date) AS month,
		top_customers.first_name || ' ' || top_customers.last_name full_name,
		COUNT(p.amount) num_payments,
		SUM(p.amount) total_paid_bymonth,
		SUM(p.amount) / COUNT(p.amount) AS amt_per_payment 
FROM top_customers
JOIN payment p
ON top_customers.customer = p.customer_id
WHERE p.payment_date BETWEEN '2007-01-01' AND '2007-12-31'
GROUP BY 1,2
ORDER BY 2
;

-- WHEN DO THEY RENT (WEEKEND, WEEKDAY) RENTAL LENGTH, CATEGORY, COST PER RENTAL)




-- How much did the top 10 customers from 2007 pay per rental?

WITH  top_customers AS (
						SELECT 
								c.customer_id customer,
								c.first_name first_name,
								c.last_name last_name,
								SUM(p.amount) total_paid
						FROM customer c
						JOIN payment p
						ON c.customer_id = p.customer_id
						GROUP BY 1,2,3
						ORDER BY 4 DESC
						LIMIT 10)

SELECT 
		top_customers.first_name || ' ' || top_customers.last_name full_name,
		COUNT(p.amount) num_payments,
		SUM(p.amount) total_paid_bymonth,
		SUM(p.amount) / COUNT(p.amount) AS amt_per_payment 
FROM top_customers
JOIN payment p
ON top_customers.customer = p.customer_id
WHERE p.payment_date BETWEEN '2007-01-01' AND '2007-12-31'
GROUP BY 1
ORDER BY 4 DESC
;








-- What days of the week are the top 10 customers frim 2007 renting movies?

-- Identifies top 10 customers
WITH  top_customers AS (
						SELECT 
								c.customer_id customer,
								c.first_name first_name,
								c.last_name last_name,
								SUM(p.amount) total_paid
						FROM customer c
						JOIN payment p
						ON c.customer_id = p.customer_id
						GROUP BY 1,2,3
						ORDER BY 4 DESC
						LIMIT 10),

-- Identifies the day of the week, rentals were made						
			 day_of_week AS (
						SELECT
							payment_date,
							CASE WHEN EXTRACT(DOW FROM payment_date) = 0 THEN 'Sunday'
							WHEN EXTRACT(DOW FROM payment_date) = 1 THEN 'Monday'
							WHEN EXTRACT(DOW FROM payment_date) = 2 THEN 'Tuesday'
							WHEN EXTRACT(DOW FROM payment_date) = 3 THEN 'Wednesday'
							WHEN EXTRACT(DOW FROM payment_date) = 4 THEN 'Thursday'
							WHEN EXTRACT(DOW FROM payment_date) = 5 THEN 'Friday'
							WHEN EXTRACT(DOW FROM payment_date) = 6 THEN 'Saturday'
							ELSE 'NULL' END AS dow
						FROM payment),

-- creates table of weekend payment dates
				weekend AS (
					SELECT 
						payment_date,
						dow weekend
					FROM day_of_week
					WHERE dow = 'Friday' OR dow = 'Saturday'),

-- creates table of weekday payment dates
				weekday AS (
					SELECT 
						payment_date,
						dow weekday
					FROM day_of_week
					WHERE dow = 'Sunday' OR dow = 'Tuesday' OR dow = 'Wednesday' OR dow = 'Thursday'),

-- Joins all subqueries
				t1 AS (
					SELECT 
							EXTRACT(DOW FROM p.payment_date),
							weekend,
							weekday,
							top_customers.first_name || ' ' || top_customers.last_name full_name,
							COUNT(weekend) weekend_rentals,
							COUNT(weekday) weekday_rentals
					FROM top_customers
					JOIN payment p
					ON top_customers.customer = p.customer_id
					JOIN day_of_week
					ON day_of_week.payment_date = p.payment_date
					FULL JOIN weekend
					ON day_of_week.payment_date = weekend.payment_date
					FULL JOIN weekday
					ON day_of_week.payment_date = weekday.payment_date
					WHERE p.payment_date BETWEEN '2007-01-01' AND '2007-12-31'
					GROUP BY 1,2,3,4
					ORDER BY 4,1)

-- Adds all rentals of top 10 customers by weekend days and weekdays. Monday has been identified
-- as an outlier in the data set and has been excluded in the aggregations.
SELECT 
	full_name,
	SUM(weekend_rentals) weekend_rentals,
	SUM(weekday_rentals) weekday_rentals
FROM t1
GROUP BY 1
ORDER BY 1 
; 







SELECT 
		EXTRACT(DOW FROM p.payment_date),
		dow,
		top_customers.first_name || ' ' || top_customers.last_name full_name,
		COUNT(dow) num_rents_per_day
FROM top_customers
JOIN payment p
ON top_customers.customer = p.customer_id
JOIN day_of_week
ON day_of_week.payment_date = p.payment_date
WHERE p.payment_date BETWEEN '2007-01-01' AND '2007-12-31'
GROUP BY 1,2,3
ORDER BY 3,1 
; 





--Pulls the Day of the Week from Timestamp
WITH dayofweek AS (
						SELECT
							payment_date,
							CASE WHEN EXTRACT(DOW FROM payment_date) = 0 THEN 'Sunday'
							WHEN EXTRACT(DOW FROM payment_date) = 1 THEN 'Monday'
							WHEN EXTRACT(DOW FROM payment_date) = 2 THEN 'Tuesday'
							WHEN EXTRACT(DOW FROM payment_date) = 3 THEN 'Wednesday'
							WHEN EXTRACT(DOW FROM payment_date) = 4 THEN 'Thursday'
							WHEN EXTRACT(DOW FROM payment_date) = 5 THEN 'Friday'
							WHEN EXTRACT(DOW FROM payment_date) = 6 THEN 'Saturday'
							ELSE 'NULL' END AS days
						FROM payment)
;

-- Question 3
-- Finally, for each of these top 10 paying customers, I would like to find out the 
-- difference across their monthly payments during 2007. Please go ahead and write a 
-- query to compare the payment amounts in each successive month. Repeat this for each 
-- of these 10 paying customers. Also, it will be tremendously helpful if you can identify 
-- the customer name who paid the most difference in terms of payments.
-- 
-- Check your solution:
-- The customer Eleanor Hunt paid the maximum difference of $64.87 during March 2007 from 
-- $22.95 in February of 2007.
-- 
-- HINT: You can build on the previous questions query to add Window functions and 
-- aggregations to get the solution.


WITH  top_customers AS (
						SELECT 
								c.customer_id customer,
								c.first_name || ' ' || c.last_name full_name,
								SUM(p.amount) total_paid
						FROM customer c
						JOIN payment p
						ON c.customer_id = p.customer_id
						GROUP BY 1,2
						ORDER BY 3 DESC
						LIMIT 10),


			t2 AS		
						(SELECT 
							DATE_TRUNC('month', p.payment_date) AS month,
							full_name,
							COUNT(p.amount) num_payments,
							SUM(p.amount) total_paid_bymonth
					FROM top_customers
					JOIN payment p
					ON top_customers.customer = p.customer_id
					WHERE p.payment_date BETWEEN '2007-01-01' AND '2007-12-31'
					GROUP BY 1,2
					ORDER BY 2)

SELECT 
		full_name,
 		LEAD(total_paid_bymonth) OVER (ORDER BY full_name) AS lead,		
		LEAD(total_paid_bymonth) OVER (ORDER BY full_name) - total_paid_bymonth AS lead_difference
FROM t2
ORDER BY 3 DESC
;









