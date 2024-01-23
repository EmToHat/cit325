-- part 1
DROP TABLE IF EXISTS conquistador;

CREATE TABLE conquistador
( conquistador_id SERIAL 
, conquistador VARCHAR(30)
, actual_name VARCHAR(30)
, nationality VARCHAR(30)
, lang VARCHAR(2));


INSERT INTO conquistador
( conquistador
, actual_name
, nationality
, lang )
VALUES
 ('Juan de Fuca','Ioánnis Fokás','Greek','el')
,('Nicolás de Federmán','Nikolaus Federmann','German','de')
,('Sebastián Caboto','Sebastiano Caboto','Venetian','it')
,('Jorge de la Espira','Georg von Speyer','German','de')
,('Eusebio Francisco Kino','Eusebius Franz Kühn','Italian','it')
,('Wenceslao Linck','Wenceslaus Linck','Bohemian','cs')
,('Fernando Consag','Ferdinand Konšcak','Croatian','sr')
,('Américo Vespucio','Amerigo Vespucci','Italian','it')
,('Alejo García','Aleixo Garcia','Portuguese','pt');



-- part 2
DROP TYPE IF EXISTS conquistador_struct;

CREATE TYPE conquistador_struct AS
( conquistador VARCHAR(30)
, actual_name VARCHAR(30)
, nationality VARCHAR(30));



-- part 3
DROP FUNCTION IF EXISTS getConquistador;

CREATE FUNCTION getConquistador ( IN lang_in VARCHAR(2))
    RETURNS SETOF conquistador_struct AS
$$
BEGIN 
    RETURN QUERY
    SELECT conquistador, actual_name, nationality
    FROM conquistador
    WHERE lang = lang_in;
END;
$$ LANGUAGE plpgsql;



-- TEST CASE 1
SELECT * FROM getConquistador('de');



-- TEST CASE 2
CREATE OR REPLACE
    VIEW conquistador_de AS
    SELECT * FROM getConquistador('de');

SELECT * FROM conquistador_de;