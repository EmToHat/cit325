-- part 1
-- create a sample grandma and tweetie_bird tables

-- Conditionally drop grandma table and grandma_s sequence.
BEGIN
    FOR i IN (SELECT object_name
                ,      object_type
                FROM   user_objects
                WHERE  object_name IN ('GRANDMA','GRANDMA_SEQ')) LOOP
        IF i.object_type = 'TABLE' THEN
        -- Use the cascade constraints to drop the dependent constraint.
        EXECUTE IMMEDIATE 'DROP TABLE '||i.object_name||' CASCADE CONSTRAINTS';
        ELSE
        EXECUTE IMMEDIATE 'DROP SEQUENCE '||i.object_name;
        END IF;
    END LOOP;
END;
/

-- Create the table.
CREATE TABLE GRANDMA
( grandma_id     NUMBER       CONSTRAINT grandma_nn1 NOT NULL
, grandma_house  VARCHAR2(30) CONSTRAINT grandma_nn2 NOT NULL
, CONSTRAINT grandma_pk       PRIMARY KEY (grandma_id)
);

-- Create the sequence.
CREATE SEQUENCE grandma_seq;

-- Conditionally drop a table and sequence.
BEGIN
    FOR i IN (SELECT object_name
                ,      object_type
                FROM   user_objects
                WHERE  object_name IN ('TWEETIE_BIRD','TWEETIE_BIRD_SEQ')) LOOP
        IF i.object_type = 'TABLE' THEN
        EXECUTE IMMEDIATE 'DROP TABLE '||i.object_name||' CASCADE CONSTRAINTS';
        ELSE
        EXECUTE IMMEDIATE 'DROP SEQUENCE '||i.object_name;
        END IF;
    END LOOP;
END;
/

-- Create the table with primary and foreign key out-of-line constraints.
CREATE TABLE TWEETIE_BIRD
( tweetie_bird_id     NUMBER        CONSTRAINT tweetie_bird_nn1 NOT NULL
, tweetie_bird_house  VARCHAR2(30)  CONSTRAINT tweetie_bird_nn2 NOT NULL
, grandma_id          NUMBER        CONSTRAINT tweetie_bird_nn3 NOT NULL
, CONSTRAINT tweetie_bird_pk        PRIMARY KEY (tweetie_bird_id)
, CONSTRAINT tweetie_bird_fk        FOREIGN KEY (grandma_id)
REFERENCES GRANDMA (GRANDMA_ID)
);

-- Create sequence.
CREATE SEQUENCE tweetie_bird_seq;


-- part 2
-- Create sample grandma_log table

-- Conditionally drop a table and sequence.
BEGIN
    FOR i IN (SELECT object_name
            ,      object_type
            FROM   user_objects
            WHERE  object_name IN ('GRANDMA_LOG','GRANDMA_LOG_SEQ')) LOOP
    IF i.object_type = 'TABLE' THEN
        EXECUTE IMMEDIATE 'DROP TABLE '||i.object_name||' CASCADE CONSTRAINTS';
    ELSE
        EXECUTE IMMEDIATE 'DROP SEQUENCE '||i.object_name;
    END IF;
    END LOOP;
END;
/

-- Create a log table.
CREATE TABLE grandma_log
( grandma_log_id     NUMBER
, trigger_name       VARCHAR2(30)
, trigger_timing     VARCHAR2(6)
, trigger_event      VARCHAR2(6)
, trigger_type       VARCHAR2(12)
, old_grandma_house  VARCHAR2(30)
, new_grandma_house  VARCHAR2(30));

-- Create log sequence.
CREATE SEQUENCE grandma_log_seq;


-- part 3
-- create a sample grandma_dml_t trigger

CREATE OR REPLACE TRIGGER grandma_dml_t
BEFORE INSERT OR UPDATE OR DELETE ON grandma
FOR EACH ROW
DECLARE
    -- Declare local trigger-scope variables
    lv_sequence_id    NUMBER := grandma_log_seq.NEXTVAL;
    lv_trigger_name   VARCHAR2(30) := 'GRANDMA_INSERT_T';
    lv_trigger_event  VARCHAR2(6);
    lv_trigger_type   VARCHAR2(12) := 'FOR EACH ROW';
    lv_trigger_timing VARCHAR2(6) := 'BEFORE';
BEGIN

    -- Check the event type
    IF INSERTING THEN
        lv_trigger_event := 'INSERT';
    ELSIF UPDATING THEN
        lv_trigger_event := 'UPDATE';
    ELSIF DELETING THEN
        lv_trigger_event := 'DELETE';
    END IF;

    -- Log event into the grandma_log table
    INSERT INTO grandma_log
    ( grandma_log_id
    , trigger_name
    , trigger_event
    , trigger_type
    , trigger_timing
    , old_grandma_house
    , new_grandma_house )
    VALUES
    ( lv_sequence_id
    , lv_trigger_name
    , lv_trigger_event
    , lv_trigger_type
    , lv_trigger_timing
    , :old.grandma_house
    , :new.grandma_house );
END grandma_insert_t;
/


-- part 4
-- Create insert, update and delete test cases for the grandma_dml_t trigger

-- Test case for insert statement.
INSERT INTO grandma
( grandma_id
, grandma_house )
VALUES
( grandma_seq.nextval
,'Red' );

-- Test case for update statement.
UPDATE grandma
SET    grandma_house = 'Yellow'
WHERE  grandma_house = 'Red';

-- Test case for delete statement
DELETE 
FROM   grandma
WHERE  grandma_house = 'Yellow';


-- part 5
-- Query the grandma_log trigger to see the before and after event state of the grandma table values

COL trigger_name      FORMAT A16
COL old_grandma_house FORMAT A12
COL new_grandma_house FORMAT A12
SELECT   trigger_name
,        trigger_timing
,        trigger_event
,        trigger_type
,        old_grandma_house
,        new_grandma_house
FROM grandma_log;

-- should return this output
-- TRIGGER_NAME     TRIGGE TRIGGE TRIGGER_TYPE OLD_GRANDMA_ NEW_GRANDMA_
-- ---------------- ------ ------ ------------ ------------ ------------
-- GRANDMA_INSERT_T BEFORE INSERT FOR EACH ROW              Red
-- GRANDMA_INSERT_T BEFORE UPDATE FOR EACH ROW Red          Yellow
-- GRANDMA_INSERT_T BEFORE DELETE FOR EACH ROW Yellow


-- part 6
-- Remove the INSERT statement from the trigger and put it in an autonomous write_grandma_log procedure

CREATE OR REPLACE 
    PROCEDURE write_grandma_log
    ( pv_trigger_name       VARCHAR2
    , pv_trigger_event      VARCHAR2
    , pv_trigger_type       VARCHAR2
    , pv_trigger_timing     VARCHAR2
    , pv_old_grandma_house  VARCHAR2
    , pv_new_grandma_house  VARCHAR2 ) IS

-- the precompiler directive to autonomous
    PRAGMA autonomous_transaction;

BEGIN

    -- Log event into the grandma_log table.
    INSERT INTO grandma_log
    ( grandma_log_id
    , trigger_name
    , trigger_event
    , trigger_type
    , trigger_timing
    , old_grandma_house
    , new_grandma_house )
    VALUES
    ( grandma_log_seq.nextval
    , pv_trigger_name
    , pv_trigger_event
    , pv_trigger_type
    , pv_trigger_timing
    , pv_old_grandma_house
    , pv_new_grandma_house );

    -- Commit the transaction.
    COMMIT;

EXCEPTION
    WHEN others THEN
        ROLLBACK;

END write_grandma_log;
/


-- part 7
-- Rewrite the sample grandma_dml_t trigger. Specifically, remove the INSERT statement and replace it with a call to the write_grandma_log procedure.

CREATE OR REPLACE TRIGGER grandma_dml_t
    BEFORE INSERT OR UPDATE OR DELETE ON grandma
    FOR EACH ROW
DECLARE
    
    -- Declare local trigger-scope variables
    lv_trigger_name   VARCHAR2(30) := 'GRANDMA_INSERT_T';
    lv_trigger_event  VARCHAR2(6);
    lv_trigger_type   VARCHAR2(12) := 'FOR EACH ROW';
    lv_trigger_timing VARCHAR2(6) := 'BEFORE';

BEGIN
    -- check the event type
    IF INSERTING THEN   
        lv_trigger_event := 'INSERT';
    ELSIF UPDATING THEN
        lv_trigger_event := 'UPDATE';
    ELSIF DELETING THEN
        lv_trigger_event := 'DELETE';
    END IF;

    -- Log event into the grandma_log table. 
    write_grandma_log(
        pv_trigger_name        => lv_trigger_name
        , pv_trigger_event     => lv_trigger_event
        , pv_trigger_type      => lv_trigger_type
        , pv_trigger_timing    => lv_trigger_timing
        , pv_old_grandma_house => :old.grandma_house
        , pv_new_grandma_house => :new.grandma_house
    );

END grandma_dml_t;
/


-- part 8
-- create insert, update, and delete test cases for the grandma_dml_t trigger.

-- Test case for insert statement
INSERT INTO grandma
( grandma_id
, grandma_house )
VALUES 
( grandma_seq.nextval
, 'Blue' );

-- Test case for update statement
UPDATE grandma
SET grandma_house = 'Green'
WHERE grandma_house = 'Blue';

-- Test case for delete statement
DELETE 
FROM grandma
WHERE grandma_house = 'Green';


-- part 9 
-- Query the grandma_log trigger to see the before and after event of the grandma table values.

COL trigger_name      FORMAT A16
COL old_grandma_house FORMAT A12
COL new_grandma_house FORMAT A12
SELECT   trigger_name
,        trigger_timing
,        trigger_event
,        trigger_type
,        old_grandma_house
,        new_grandma_house
FROM grandma_log;


-- Should return this output
-- TRIGGER_NAME     TRIGGE TRIGGE TRIGGER_TYPE OLD_GRANDMA_ NEW_GRANDMA_
-- ---------------- ------ ------ ------------ ------------ ------------
-- GRANDMA_INSERT_T BEFORE INSERT FOR EACH ROW              Red
-- GRANDMA_INSERT_T BEFORE UPDATE FOR EACH ROW Red          Yellow
-- GRANDMA_INSERT_T BEFORE DELETE FOR EACH ROW Yellow
-- GRANDMA_INSERT_T BEFORE INSERT FOR EACH ROW              Blue
-- GRANDMA_INSERT_T BEFORE UPDATE FOR EACH ROW Blue         Green
-- GRANDMA_INSERT_T BEFORE DELETE FOR EACH ROW Green