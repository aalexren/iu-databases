-- IMPORTANT INDEX
DROP INDEX IF EXISTS index_rental_rental_id_staff_id_last_update;
CREATE INDEX IF NOT EXISTS index_rental_rental_id_staff_id_last_update
ON rental 
USING btree(last_update, rental_id, customer_id, staff_id);

-- IMPORTANT INDEX FOR BIGGER DATA
DROP INDEX IF EXISTS index_customer_customer_id;
CREATE INDEX IF NOT EXISTS index_customer_customer_id
ON customer
USING hash(customer_id) WHERE active=1;

EXPLAIN ANALYZE --, COSTS, VERBOSE, BUFFERS, FORMAT JSON)
SELECT r1.staff_id, p1.payment_date
FROM rental r1, payment p1
WHERE r1.rental_id = p1.rental_id AND
NOT EXISTS (
	SELECT 1 FROM rental r2, customer c 
	WHERE r2.customer_id = c.customer_id AND 
	active = 1 AND r2.last_update > r1.last_update
);