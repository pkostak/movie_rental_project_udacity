-- SLIDE 1

-- What type of movie did families rent the most? The following categories are considered 
-- family movies: Animation, Children, Classics, Comedy, Family and Music.

-- Counts number of times categories were rented
WITH fam_rentals AS (
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
	rental_times times_rented,
	100 * rental_times / SUM(rental_times) OVER () AS percent_family_rentals
FROM fam_rentals
GROUP BY 1,2
ORDER BY 2 DESC
;


-- SLIDE 2

-- Which Store Had the Most Rentals During the Summer of 2005 and What Were Their Total Sales?

SELECT 
	DATE_PART('month', rental_date) rent_month,
	s.store_id,
	COUNT(*) num_rentals,
	SUM(p.amount) total_sales
FROM staff s
JOIN rental r
ON s.staff_id = r.staff_id
JOIN payment p
ON r.rental_id = p.rental_id
WHERE DATE_PART('month', rental_date) BETWEEN '6' AND '8'
GROUP BY 1,2
ORDER BY 1,2
;



-- SLIDE 3

-- How Much did the Top 10 Customers from 2007 Spend Per Rental?

-- Identifies top 10 customers
WITH top_customers AS (
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
	SUM(p.amount) total_paid,
	SUM(p.amount) / COUNT(p.amount) AS amt_per_payment 
FROM top_customers
JOIN payment p
ON top_customers.customer = p.customer_id
WHERE p.payment_date BETWEEN '2007-01-01' AND '2007-12-31'
GROUP BY 1
ORDER BY 4 DESC
;



-- SLIDE 4

-- Weekend vs Weekday Rental Comparison of the top 10 customers from 2007

-- Identifies top 10 customers
WITH top_customers AS (
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