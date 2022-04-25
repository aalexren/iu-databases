-- IMPORTANT INDEX FOR BIGGER DATA
DROP INDEX IF EXISTS index_film_film_id;
CREATE INDEX IF NOT EXISTS index_film_film_id 
ON film USING btree(film_id) INCLUDE (title, release_year)
WHERE rating = 'PG-13' OR rating = 'NC-17';

-- IMPORTANT INDEX
DROP INDEX IF EXISTS index_customer_first_name_customer_id;
CREATE INDEX IF NOT EXISTS index_customer_first_name_customer_id 
ON customer USING hash(first_name);

-- IMPORTANT INDEX
DROP INDEX IF EXISTS index_payment_rental_id;
CREATE INDEX IF NOT EXISTS index_payment_rental_id
ON payment USING hash(rental_id);

-- IMPORTANT INDEX
DROP INDEX IF EXISTS index_inventory_film_id;
CREATE INDEX IF NOT EXISTS index_inventory_film_id
ON inventory USING btree(film_id, inventory_id);

-- IMPORTANT INDEX
DROP INDEX IF EXISTS index_rental_all;
CREATE INDEX IF NOT EXISTS index_rental_all
ON rental USING btree(inventory_id, customer_id, rental_id);

-- IMPORTANT INDEX
DROP INDEX IF EXISTS index_rental_all_2;
CREATE INDEX IF NOT EXISTS index_rental_all_2
ON rental USING btree(customer_id, inventory_id);

-- IMPORTANT INDEX
DROP INDEX IF EXISTS index_film_actor_film_id_actor_id;
CREATE INDEX IF NOT EXISTS index_film_actor_film_id_actor_id
ON film_actor USING btree(film_id, actor_id);

-- -- , COSTS, VERBOSE, BUFFERS, FORMAT JSON)
EXPLAIN ANALYZE
SELECT f.title, f.release_year,
	(
	SELECT SUM(p.amount)
	FROM payment p, rental r1, inventory i1 
	WHERE p.rental_id = r1.rental_id AND r1.inventory_id = i1.inventory_id
									 AND i1.film_id = f.film_id
	)
FROM film f
WHERE NOT EXISTS (
	SELECT c.first_name, COUNT(*)
	FROM customer c, rental r2, inventory i1, film f1, film_actor fa, actor a
	WHERE c.customer_id = r2.customer_id AND r2.inventory_id = i1.inventory_id AND
	i1.film_id = f1.film_id AND f1.rating IN ('PG-13','NC-17') AND f1.film_id =
	fa.film_id AND f1.film_id = f.film_id AND fa.actor_id = a.actor_id AND
	a.first_name = c.first_name GROUP BY c.first_name HAVING COUNT(*) > 2);