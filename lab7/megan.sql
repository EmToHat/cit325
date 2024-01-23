/* Create conquistador table. */
CREATE TABLE conquistador
(conquistador_id NUMBER
, conquistador VARCHAR(30)
, actual_name VARCHAR(30)
, nationality VARCHAR(30)
, lang VARCHAR(2));

/* Drop sequence unconditionally. */
DROP SEQUENCE conquistador_seq;

/* Create a sequence starting with 1001. */
CREATE SEQUENCE conquistador_seq START WITH 1001;

/* Insert 9-rows of data. */
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

/* Drop the dependent before the dependency. */
DROP TYPE conquistador_table;
DROP TYPE conquistador_struct;

/* Create a record structure. */
CREATE OR REPLACE
  TYPE conquistador_struct IS OBJECT
  ( conquistador VARCHAR(30)
  , actual_name VARCHAR(30)
  , nationality VARCHAR(30));
/
/* Create an avenger table. */
CREATE OR REPLACE
  TYPE conquistador_table IS TABLE OF conquistador_struct;
/

/* Drop the function conditionally. */
DROP FUNCTION getConquistador;

/* Create the function. */
CREATE OR REPLACE
FUNCTION getConquistador(pv_lang IN VARCHAR) RETURN conquistador_table IS
lv_retval CONQUISTADOR_TABLE := conquistador_table();

/* Declare a dynamic cursor. */
CURSOR get_conquistador
(cv_lang  VARCHAR2) IS
SELECT c.conquistador
,   c.actual_name
,   c.nationality
FROM conquistador c
WHERE c.lang = cv_lang;
 
/* Local procedure to add to the song. */
PROCEDURE ADD
(pv_input CONQUISTADOR_STRUCT) IS
BEGIN
lv_retval.EXTEND;
lv_retval(lv_retval.COUNT) := pv_input;
END ADD;
 
BEGIN
  /* Read through the cursor and assign to the UDT table. */
  FOR i IN get_conquistador(pv_lang) LOOP
    add(conquistador_struct(i.conquistador
, i.actual_name
, i.nationality));
  END LOOP;
 
  /* Return collection. */
  RETURN lv_retval;
END;
/

-- Test 1
COL conquistador  FORMAT A21
COL actual_name   FORMAT A21
COL nationality   FORMAT A12

SELECT * FROM TABLE(getConquistador('de'));

-- Test 2
CREATE OR REPLACE
  VIEW conquistador_de AS
  SELECT * FROM TABLE(getConquistador('de'));
/
COL conquistador  FORMAT A21
COL actual_name   FORMAT A21
COL nationality   FORMAT A12

SELECT * FROM conquistador_de;
