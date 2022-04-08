-- The company is preparing its campaign for next Halloween, 
-- so the list of movies that have not been rented yet by the clients is needed, 
-- whose rating is R or PG-13 and its category is Horror or Sci-fi
EXPLAIN SELECT RES.film_id, title FROM (
	SELECT flms_not_rented.film_id
	FROM film_category AS FLM_CAT, category AS CAT,
		(SELECT FLM.film_id FROM film AS FLM
		EXCEPT
		(
		SELECT DISTINCT INVT.film_id
		FROM inventory AS INVT LEFT JOIN 
		rental AS RNT ON INVT.inventory_id = RNT.inventory_id
		)) AS flms_not_rented
	WHERE FLM_CAT.film_id = flms_not_rented.film_id
	AND FLM_CAT.category_id = CAT.category_id
	AND (CAT.name = 'Horror' OR CAT.name = 'Sci-Fi')
) AS RES, film
WHERE film.film_id = RES.film_id AND (film.rating = 'R' OR film.rating = 'PG-13');

-- The company has decided to reward the best stores in each of the cities, 
-- so it is necessary to have a list of the stores that have made a greater 
-- number of sales in term of money during the last month recorded.
EXPLAIN
SELECT store_id, city, MAX(amount) FROM
	(
	SELECT staff.store_id, SUM(amount) as amount, city
	FROM staff, address, city, store,
		(
		SELECT * 
		FROM payment 
		WHERE payment_date >=
			(
				SELECT MAX(payment_date)
				FROM payment
			) - INTERVAL '1 month'
		) as payment
	WHERE 	payment.staff_id = staff.staff_id
		AND staff.store_id = store.store_id
		AND store.address_id = address.address_id
		AND address.city_id = city.city_id
	GROUP BY staff.store_id, city.city, staff.staff_id
	) AS res
GROUP BY res.store_id, res.city;



