-- Function: f_rm_view_dependente(text)

-- DROP FUNCTION f_rm_view_dependente(text);

CREATE OR REPLACE FUNCTION f_rm_view_dependente(text)
  RETURNS text AS

$$
DECLARE
cTableName ALIAS FOR $1;
cViewName TEXT;
cCursor REFCURSOR;

BEGIN 
	CREATE TABLE IF NOT EXISTS backup_view (
	id BIGSERIAL,
	code TEXT,
	relation TEXT);
	
	OPEN cCursor FOR 
		SELECT distinct v.oid::regclass AS view
		FROM pg_depend AS d      -- objects that depend on the table
		   JOIN pg_rewrite AS r  -- rules depending on the table
		      ON r.oid = d.objid
		   JOIN pg_class AS v    -- views for the rules
		      ON v.oid = r.ev_class
		WHERE v.relkind = 'v'    -- only interested in views
		  -- dependency must be a rule depending on a relation
		  AND d.classid = 'pg_rewrite'::regclass
		  AND d.refclassid = 'pg_class'::regclass
		  AND d.deptype = 'n'    -- normal dependency
		  AND d.refobjid = cTableName::regclass;    -- nome da tabela que possue dependencias

	LOOP
		FETCH cCursor INTO cViewName;
		EXIT WHEN NOT FOUND;

		INSERT INTO backup_view(code,relation)
		select 'CREATE OR REPLACE VIEW ' || cViewName || ' AS '  
		|| pg_get_viewdef(cViewName, true) AS code,
		cViewName AS relation;
		
		EXECUTE 'DROP VIEW '||cViewName;
		RAISE INFO '%', RPAD(cViewName,100,'.')||'[OK]';
	END LOOP;
		RETURN RPAD('',93,'.')||'[CONCLUIDO]';
END;
$$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION f_rm_view_dependente(text)
  OWNER TO "JURIDICO";
