-- IMPORTANT INDEX
-- DROP INDEX IF EXISTS idx_rental_rental_id_staff_id_last_update;
-- CREATE INDEX IF NOT EXISTS idx_rental_rental_id_staff_id_last_update
-- ON rental 
-- USING btree(last_update, rental_id, customer_id, staff_id);

-- DROP INDEX IF EXISTS idx_payment_rental_id_payment_date;
-- -- CREATE INDEX IF NOT EXISTS idx_payment_rental_id_payment_date
-- -- ON payment
-- -- USING btree(rental_id) WHERE rental_id <= 16049;

-- DROP INDEX IF EXISTS idx_customer_customer_id;
-- -- CREATE INDEX IF NOT EXISTS idx_customer_customer_id
-- -- ON customer
-- -- USING btree(customer_id) INCLUDE (active) WHERE active=1;

-- EXPLAIN ANALYZE 
-- SELECT r1.staff_id, p1.payment_date
-- FROM rental r1, payment p1
-- WHERE r1.rental_id = p1.rental_id AND
-- NOT EXISTS (
-- 	SELECT 1 FROM rental r2, customer c 
-- 	WHERE r2.customer_id = c.customer_id AND 
-- 	active = 1 AND r2.last_update > r1.last_update
-- );


-- IMPORTANT INDEX
DROP INDEX IF EXISTS film_film_id_idx;
CREATE INDEX IF NOT EXISTS film_film_id_idx 
ON film USING hash(film_id)
WHERE rating ='PG-13' OR rating='NC-17';

-- IMPORTANT INDEX
DROP INDEX IF EXISTS idx_customer_first_name_customer_id;
CREATE INDEX IF NOT EXISTS idx_customer_first_name_customer_id 
ON customer USING btree(first_name DESC NULLS FIRST);

-- DROP INDEX IF EXISTS idx_customer_customer_id;
-- CREATE INDEX IF NOT EXISTS idx_customer_customer_id 
-- ON customer USING btree(customer_id, first_name DESC NULLS FIRST);

-- DROP INDEX IF EXISTS idx_actor_first_name;
-- CREATE INDEX IF NOT EXISTS idx_customer_first_name
-- ON actor USING btree(first_name ASC NULLS FIRST) INCLUDE (actor_id);

-- IMPORTANT INDEX
DROP INDEX IF EXISTS idx_payment_rental_id;
CREATE INDEX IF NOT EXISTS idx_payment_rental_id
ON payment USING hash(rental_id);

-- IMPORTANT INDEX
DROP INDEX IF EXISTS idx_rental_inventory_id;
CREATE INDEX IF NOT EXISTS idx_rental_inventory_id
ON rental USING hash(inventory_id);

-- IMPORTANT INDEX
DROP INDEX IF EXISTS idx_inventory_film_id;
CREATE INDEX IF NOT EXISTS idx_inventory_film_id
ON inventory USING btree(film_id, inventory_id, store_id, last_update);

-- IMPORTANT INDEX
DROP INDEX IF EXISTS idx_rental_customer_id;
CREATE INDEX IF NOT EXISTS idx_rental_customer_id
ON rental USING hash(customer_id);

-- IMPORTANT INDEX
DROP INDEX IF EXISTS idx_film_actor_film_id_actor_id;
CREATE INDEX IF NOT EXISTS idx_film_actor_film_id_actor_id
ON film_actor USING btree(film_id, actor_id);

-- DROP INDEX IF EXISTS idx_film_actor_actor_id;
-- CREATE INDEX IF NOT EXISTS idx_film_actor_actor_id
-- ON film_actor USING hash(actor_id);

-- DROP INDEX IF EXISTS idx_rental_rental_id_inventory_id;
-- CREATE INDEX IF NOT EXISTS idx_rental_rental_id_inventory_id
-- ON rental USING btree(rental_id, inventory_id);

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