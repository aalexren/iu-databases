-- DROP FUNCTION retrieve_customers(INT, INT);

CREATE OR REPLACE FUNCTION retrieve_customers(start_id INT, stop_id INT)
RETURNS TABLE (
	customer_id INT
)
AS $body$
	BEGIN
		IF (start_id < 0 OR start_id > 600 OR
			stop_id < 0 OR stop_id > 600)
		THEN
			RAISE EXCEPTION 'Parameters are not between 0 and 600';
		END IF;
		IF (stop_id < start_id)
		THEN
			RAISE EXCEPTION 'Stop less than start';
		END IF;
		RETURN QUERY
		SELECT C.customer_id FROM customer AS C
		WHERE C.customer_id >= start_id AND C.customer_id <= stop_id
		ORDER BY C.customer_id ASC;
	END;
$body$
LANGUAGE plpgsql;