-- part 1

DROP TABLE conquistador;

CREATE TABLE conquistador
( conquistador_id NUMERIC
, conquistador VARCHAR2(30)
, actual_name VARCHAR2(30)
, nationality VARCHAR2(30)
, lang VARCHAR2(2));

DROP SEQUENCE conquistador_seq;

CREATE SEQUENCE conquistador_seq START WITH 1001;

INSERT INTO conquistador
( conquistador_id, conquistador, actual_name, nationality, lang )
VALUES
(conquistador_seq.NEXTVAL,'Juan de Fuca','Ioánnis Fokás','Greek','el');

INSERT INTO conquistador
( conquistador_id, conquistador, actual_name, nationality, lang )
VALUES 
(conquistador_seq.NEXTVAL,'Nicolás de Federmán','Nikolaus Federmann','German','de');

INSERT INTO conquistador
( conquistador_id, conquistador, actual_name, nationality, lang )
VALUES
(conquistador_seq.NEXTVAL,'Sebastián Caboto','Sebastiano Caboto','Venetian','it');

INSERT INTO conquistador
( conquistador_id, conquistador, actual_name, nationality, lang )
VALUES
(conquistador_seq.NEXTVAL,'Jorge de la Espira','Georg von Speyer','German','de');

INSERT INTO conquistador
( conquistador_id, conquistador, actual_name, nationality, lang )
VALUES
(conquistador_seq.NEXTVAL,'Eusebio Francisco Kino','Eusebius Franz Kühn','Italian','it');

INSERT INTO conquistador
( conquistador_id, conquistador, actual_name, nationality, lang )
VALUES
(conquistador_seq.NEXTVAL,'Wenceslao Linck','Wenceslaus Linck','Bohemian','cs');

INSERT INTO conquistador
( conquistador_id, conquistador, actual_name, nationality, lang )
VALUES
(conquistador_seq.NEXTVAL,'Fernando Consag','Ferdinand Konšcak','Croatian','sr');

INSERT INTO conquistador
( conquistador_id, conquistador, actual_name, nationality, lang )
VALUES
(conquistador_seq.NEXTVAL,'Américo Vespucio','Amerigo Vespucci','Italian','it');

INSERT INTO conquistador
( conquistador_id, conquistador, actual_name, nationality, lang )
VALUES
(conquistador_seq.NEXTVAL,'Alejo García','Aleixo Garcia','Portuguese','pt');



-- part 2
DROP TYPE conquistador_table;
DROP TYPE conquistador_struct;

CREATE OR REPLACE
	TYPE conquistador_struct IS OBJECT
	( conquistador VARCHAR2(30)
	, actual_name VARCHAR2(30)
	, nationality VARCHAR2(30)	
	);
/



-- part 3
CREATE OR REPLACE
	TYPE conquistador_table IS TABLE OF conquistador_struct;
/



-- part 4
DROP FUNCTION getConquistador;

CREATE OR REPLACE
	FUNCTION getConquistador (pv_lang IN VARCHAR2) RETURN conquistador_table IS
	lv_retval CONQUISTADOR_TABLE := conquistador_table();
	
	CURSOR get_conquistador
	( cv_lang VARCHAR2 ) IS
		SELECT c.conquistador,
			c.actual_name,
			c.nationality
		FROM conquistador c
		WHERE c.lang = cv_lang;
	
	PROCEDURE ADD
	( pv_input CONQUISTADOR_STRUCT ) IS
	BEGIN
		lv_retval.EXTEND;
		lv_retval(lv_retval.COUNT) := pv_input;
	END ADD;

BEGIN
	FOR i IN get_conquistador(pv_lang) LOOP
		add(conquistador_struct(i.conquistador, i.actual_name, i.nationality));
	END LOOP;

	RETURN lv_retval;
END;
/



-- TEST CASE 1
COL conquistador FORMAT A21
COL acutal_name FORMAT A21
COL nationality FORMAT A21

SELECT * FROM TABLE(getConquistador('de'));



-- TEST CASE 2
CREATE OR REPLACE
	VIEW conquistador_de AS
	SELECT * FROM TABLE(getConquistador('de'));


COL conquistador FORMAT A21
COL acutal_name FORMAT A21
COL nationality FORMAT A21

SELECT * FROM TABLE(getConquistador('de'));
