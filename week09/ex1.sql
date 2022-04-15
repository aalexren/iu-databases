-- DROP FUNCTION retrieve_addresses;

CREATE OR REPLACE FUNCTION retrieve_addresses()
RETURNS TABLE (
	address_id INT,
	address VARCHAR
)
AS $body$
	BEGIN 
	RETURN QUERY 
		SELECT address.address_id, address.address
		FROM address
		WHERE address.address LIKE '%11%' AND address.city_id BETWEEN 400 AND 600
		ORDER BY address.address_id DESC;
	END;
$body$
LANGUAGE plpgsql;