-- IMPORTANT INDEX
CREATE INDEX IF NOT EXISTS index_rental_rental_id_staff_id_last_update
ON rental 
USING btree(last_update, rental_id, customer_id, staff_id);

-- IMPORTANT INDEX FOR BIGGER DATA
CREATE INDEX IF NOT EXISTS index_customer_customer_id
ON customer
USING hash(customer_id) WHERE active=1;

-- IMPORTANT INDEX
CREATE INDEX IF NOT EXISTS index_film_all
ON film USING btree(rental_rate ASC NULLS FIRST, release_year ASC NULLS FIRST) INCLUDE (title);

-- IMPORTANT INDEX
CREATE INDEX IF NOT EXISTS index_film_all_2
ON film USING btree(release_year ASC NULLS FIRST, rental_rate ASC NULLS FIRST) INCLUDE (title);

-- IMPORTANT INDEX FOR BIGGER DATA
CREATE INDEX IF NOT EXISTS index_film_film_id 
ON film USING btree(film_id) INCLUDE (title, release_year)
WHERE rating = 'PG-13' OR rating = 'NC-17';

-- IMPORTANT INDEX
CREATE INDEX IF NOT EXISTS index_customer_first_name_customer_id 
ON customer USING hash(first_name);

-- IMPORTANT INDEX
CREATE INDEX IF NOT EXISTS index_payment_rental_id
ON payment USING hash(rental_id);

-- IMPORTANT INDEX
CREATE INDEX IF NOT EXISTS index_inventory_film_id
ON inventory USING btree(film_id, inventory_id);

-- IMPORTANT INDEX
CREATE INDEX IF NOT EXISTS index_rental_all
ON rental USING btree(inventory_id, customer_id, rental_id);

-- IMPORTANT INDEX
CREATE INDEX IF NOT EXISTS index_rental_all_2
ON rental USING btree(customer_id, inventory_id);

-- IMPORTANT INDEX
CREATE INDEX IF NOT EXISTS index_film_actor_film_id_actor_id
ON film_actor USING btree(film_id, actor_id);