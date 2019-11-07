-- Function: f_cr_view_dependente(text)

-- DROP FUNCTION f_cr_view_dependente(text);

CREATE OR REPLACE FUNCTION f_cr_view_dependente(text)
  RETURNS text AS

$$
DECLARE
cTableName ALIAS FOR $1;

nBackupIde NUMERIC;
cViewCode TEXT;
cViewName TEXT;
cCursor REFCURSOR;

BEGIN 

	OPEN cCursor FOR 
	SELECT id,code, relation FROM backup_view;
	LOOP
		FETCH cCursor INTO nBackupIde,cViewCode,cViewName;
		EXIT WHEN NOT FOUND;

		EXECUTE cViewCode;
		DELETE FROM backup_view WHERE id = nBackupIde;
		RAISE INFO '%', RPAD(cViewName,100,'.')||'[OK]';

	END LOOP;

	RETURN'[CONCLUIDO]';
END;
$$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION f_cr_view_dependente(text)
  OWNER TO "JURIDICO";
