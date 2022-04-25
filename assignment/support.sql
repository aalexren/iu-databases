-- Function: detete all user indexes
CREATE OR REPLACE FUNCTION drop_all_indexes() RETURNS TABLE ("order" INT, "name" TEXT) AS $$
DECLARE i RECORD; cnt INTEGER;
BEGIN 
    cnt = 0;
    FOR i IN ( SELECT indexname FROM get_user_indexes())
    LOOP 
        EXECUTE format('DROP INDEX IF EXISTS %I CASCADE;', i.indexname);
        "order" := cnt;
        "name" := i.indexname;
        RETURN NEXT;
        cnt = cnt + 1;    
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Function: return all user indexes
CREATE OR REPLACE FUNCTION get_user_indexes() RETURNS TABLE ("tablename" NAME, "indexname" NAME, "indexdef" TEXT) AS $$
BEGIN 
    RETURN QUERY
    SELECT pg_i.tablename,  pg_i.indexname,  pg_i.indexdef
    FROM pg_indexes pg_i
    WHERE schemaname = 'public'
        AND pg_i.tablename !~~ 'pg%'
        AND pg_i.indexname !~~ '%_pkey'
        AND pg_i.indexname !~~ 'idx_%'
        AND pg_i.indexname !~~ '%_idx';
END;
$$ LANGUAGE plpgsql;


--* Print existing users indexes:
SELECT row_number() OVER w  AS num, *
FROM get_user_indexes() i
WINDOW w AS (ORDER BY i.tablename, i.indexname)
ORDER BY i.tablename, i.indexname;

--! Drop existing users indexes:
SELECT format('Dropped: %s)  %s', "order", "name" )
FROM drop_all_indexes()
ORDER BY "order";