-- Task
/*
* Write a getgetConquistador 
* function that accepts a 2-character string 
* and returns a table of a record type.
*/


-- part 1 
/* 
* Create a sample avenger table 
* and populate it with values
*/
-- Drop table unconditionally.
DROP TABLE avenger;

-- Create avenger table.
CREATE TABLE avenger
( avenger_id      NUMBER
, first_name      VARCHAR(30)
, last_name       VARCHAR(30)
, character_name  VARCHAR(30)
, species         VARCHAR(30));

-- Drop sequence unconditionally.
DROP SEQUENCE avenger_seq;

-- Create a sequence starting with 1001.
CREATE SEQUENCE avenger_seq START WITH 1001;

-- Insert 6-rows of data.
INSERT INTO avenger
( avenger_id, first_name, last_name, character_name, species )
VALUES
(avenger_seq.NEXTVAL,'Anthony','Stark','Iron Man','Terran');

INSERT INTO avenger
( avenger_id, first_name, last_name, character_name, species )
VALUES 
(avenger_seq.NEXTVAL,'Thor','Odinson','God of Thunder','Asgardian');

INSERT INTO avenger
( avenger_id, first_name, last_name, character_name, species )
VALUES
(avenger_seq.NEXTVAL,'Steven','Rogers','Captain America','Terran');

INSERT INTO avenger
( avenger_id, first_name, last_name, character_name, species )
VALUES
(avenger_seq.NEXTVAL,'Bruce','Banner','Hulk','Terran');

INSERT INTO avenger
( avenger_id, first_name, last_name, character_name, species )
VALUES
(avenger_seq.NEXTVAL,'Clinton','Barton','Hackeye','Terran');

INSERT INTO avenger
( avenger_id, first_name, last_name, character_name, species )
VALUES
(avenger_seq.NEXTVAL,'Natasha','Romanoff','Black Widow','Terran');



-- part 2 
/*
* Create a User-Defined Type (UDT) as the 
* avenger_struct object type qualifed below, 
* and another ADT of the avenger_struct object type.
*/

-- Drop the dependent before the dependency.
DROP TYPE avenger_table;
DROP TYPE avenger_struct;

-- Create a record structure.
CREATE OR REPLACE
  TYPE avenger_struct IS OBJECT
  ( first_name      VARCHAR(30)
  , last_name       VARCHAR(30)
  , character_name  VARCHAR(30));
/

-- Create an avenger table.
CREATE OR REPLACE
  TYPE avenger_table IS TABLE OF avenger_struct;
/



-- part 3 
/*
* Develop a parameterized getAvenger function that accepts 
* a 2-character variable length string and returns an avenger_table 
* (as defined above).
*/
-- Drop the funciton conditionally.
DROP FUNCTION getAvenger;

-- Create the function.
CREATE OR REPLACE
  FUNCTION getAvenger (pv_species IN VARCHAR) RETURN avenger_table IS
  
  -- Declare a return variable. 
  lv_retval  AVENGER_TABLE := avenger_table();

  -- Declare a dynamic cursor.
  CURSOR get_avenger
  ( cv_species  VARCHAR2 ) IS
    SELECT a.first_name
    ,      a.last_name
    ,      a.character_name
    FROM   avenger a
    WHERE  a.species = cv_species;
  
  -- Local procedure to add to the song. 
  PROCEDURE ADD
  ( pv_input  AVENGER_STRUCT ) IS
  BEGIN
    lv_retval.EXTEND;
    lv_retval(lv_retval.COUNT) := pv_input;
  END ADD;
  
BEGIN
  -- Read through the cursor and assign to the UDT table.
  FOR i IN get_avenger(pv_species) LOOP
    add(avenger_struct( i.first_name
                      , i.last_name
                      , i.character_name ));
  END LOOP;
  
  -- Return collection.
  RETURN lv_retval;
END;
/



-- part 4 
/*
* Test your preparation version with the following code.
*/
COL first_name      FORMAT A10
COL last_name       FORMAT A10
COL character_name  FORMAT A20

SELECT * FROM TABLE(getAvenger('Asgardian'));

/*
* It should display the following
*/

/*
    FIRST_NAME  LAST_NAME   CHARACTER_NAME
    ---------   ---------   --------------
    Thor        Odinson     God of Thunder
*/



-- part 5
/*
* Create a view.
*/
CREATE OR REPLACE
  VIEW avenger_asgardian AS
  SELECT * FROM TABLE(getAvenger('Asgardian')); 
/
COL first_name      FORMAT A10
COL last_name       FORMAT A10
COL character_name  FORMAT A20

SELECT * FROM avenger_asgardian;

/*
* It should display the following
*/

/*
    FIRST_NAME  LAST_NAME   CHARACTER_NAME
    ---------   ---------   --------------
    Thor        Odinson     God of Thunder
*/
