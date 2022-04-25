-- IMPORTANT INDEX
DROP INDEX IF EXISTS index_film_all;
CREATE INDEX IF NOT EXISTS index_film_all
ON film USING btree(rental_rate ASC NULLS FIRST, release_year ASC NULLS FIRST) INCLUDE (title);

-- IMPORTANT INDEX
DROP INDEX IF EXISTS index_film_all_2;
CREATE INDEX IF NOT EXISTS index_film_all_2
ON film USING btree(release_year ASC NULLS FIRST, rental_rate ASC NULLS FIRST) INCLUDE (title);

EXPLAIN ANALYZE --, COSTS, VERBOSE, BUFFERS, FORMAT JSON)
SELECT title, release_year
FROM film f1
WHERE f1.rental_rate > (
	SELECT AVG(f2.rental_rate) 
	FROM film f2 
	WHERE f1.release_year = f2.release_year
)