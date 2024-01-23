-- Run the video file before runing this file.

-- TASK
-- create an event driven contact_t trigger:
-- needs to convert two-part surname (separated by whitespace) in any insert statement into a hyphenated surname and stores it in the last_name column of the contact table w/o raising an exception.
-- needs to prevent the conversion of a hyphanated surname into a two-part surname (separated by whitespace) when someone attempts an update statement, and it raises an exception with that attempt. 


-- part 1
-- leverage the setpup components while writing the autonomous procedure and call the contact_t trigger. The script should be re-runnable, or idimpotent. 

-- part 1.1 clean up the rows inserted during dev. and testing. Delete the rows from the member and contact tables.
-- Delete a row from contact table.
DELETE
FROM   contact
WHERE  last_name LIKE 'Smith_Wyse';

-- Delete a row from member table.
DELETE
FROM   member
WHERE  account_number = 'SLC-000040';

-- part 1.2 Drop the contact_t trigger with conditions
-- Conditionally drop a trigger.
-- DROP TRIGGER IF EXISTS contact_t;
DO $$ 
BEGIN
    BEGIN
        -- Attempt to drop the trigger
        EXECUTE 'DROP TRIGGER contact_t ON contact';
    EXCEPTION
        WHEN others THEN
        -- Ignore the exception if the trigger doesn't exist
        NULL;
    END;
END $$;

-- part 1.3 Drop the get_member_id function with conditions
-- Conditionally drop a helper function get_member_id.
DROP FUNCTION IF EXISTS get_member_id;

RAISE NOTICE 'Dropped Function: %', 'get_member_id';

-- part 1.4 Create or replace get_member_id function
CREATE OR REPLACE
    FUNCTION get_member_id
    ( IN pv_account_number  VARCHAR ) RETURNS INTEGER AS
$$

    -- required fo PL/pgSQL programs
    DECLARE

        -- Local return variable
        lv_retval INTEGER := 0; -- Default value is 0. 

        -- Use a cursor, which will not raise an exception at runtime.
        find_member_id CURSOR 
        ( cv_account_number VARCHAR ) FOR 
            SELECT m.member_id 
                FROM member m 
                WHERE m.account_number = cv_account_number;

    BEGIN

        -- assign a value when a row exists.
        FOR i IN find_member_id( pv_account_number ) LOOP 
            lv_retval := i.member_id; 
        END LOOP; 

        -- Return 0 when no row found and the ID # when row found.
        RETURN lv_retval;
    END;


RAISE NOTICE 'Created Function: %', 'get_member_id';

$$ LANGUAGE plpgsql;

-- part 1.5 Conditionally insert a row into the insert table. Essential to ensure you only insert one row in the member table. 

-- Conditionally insert row into the member table.
DO
$$
DECLARE
    -- Declare a control variable to avoid duplicate inserts.
    lv_member_id  integer := 0;

BEGIN 
    -- Check for and assign an existing surrogate key value.
    lv_member_id := get_member_id('SLC-000040');

    -- Insert row when there is no prior row.
    IF lv_member_id = 0 THEN 
        -- Insert row intothe member table.
        INSERT 
        INTO member
        ( member_type 
        , account_number
        , credit_card_number
        , credit_card_type
        , created_by
        , last_updated_by )
        VALUES 
        ((SELECT   common_lookup_id
            FROM     common_lookup
            WHERE    common_lookup_table = 'MEMBER'
            AND      common_lookup_column = 'MEMBER_TYPE'
            AND      common_lookup_type = 'INDIVIDUAL')
        ,'SLC-000040'
        ,'6022-2222-3333-4444'
        ,(SELECT   common_lookup_id
            FROM     common_lookup
            WHERE    common_lookup_table = 'MEMBER'
            AND      common_lookup_column = 'CREDIT_CARD_TYPE'
            AND      common_lookup_type = 'DISCOVER_CARD')
        , 1002
        , 1002 );
    END IF;
END;
$$ 
LANGUAGE plpgsql;

-- part 1.6 You should drop and create the contact_log table and contact_log_seq sequence with the following script
-- Conditionally drop a table and sequence.
DROP TABLE IF EXISTS contact_log;

-- Create table contact_log table.
CREATE TABLE contact_log
( contact_log_id  SERIAL
, trigger_name    VARCHAR(30)
, trigger_timing  VARCHAR(6)
, trigger_event   VARCHAR(12)
, trigger_type    VARCHAR(16)
, old_last_name   VARCHAR(30)
, new_last_name   VARCHAR(30));

-- part 1.7 You write an autonomous contact_log_f trigger that writes a row to the contact table. You should note that PostgreSQL doesn't support autonomous transactions and you can only log actions when the trigger completes successfully.
-- Drop function conditionally.
DROP FUNCTION IF EXISTS contact_log_f CASCADE;

-- Create function.
CREATE FUNCTION contact_log_f()
    RETURNS trigger AS
$$ 

DECLARE 
    -- Declare local trigger-scope variables.
    lv_trigger_name   VARCHAR(30) := 'CONTACT_T';
    lv_trigger_event  VARCHAR(12);
    lv_trigger_type   VARCHAR(16) := 'FOR EACH ROW';
    lv_trigger_timing VARCHAR(6) := 'BEFORE';

BEGIN 

    IF old.last_name IS NULL THEN

        -- Replace whitespace with hyphen.
        NEW.last_name = REPLACE(NEW.last_name, ' ', '-');

        -- Assign the trigger type
        lv_trigger_event := 'INSERT';
    
    ELSE

        -- Assign the trigger type
        lv_trigger_event := 'UPDATE';
		
    END IF;

    -- Log event into the contact_log table.
	RAISE NOTICE 'Inserting into contact_log: %, %, %, %, %, %', lv_trigger_name, lv_trigger_timing, lv_trigger_event, lv_trigger_type, OLD.last_name, NEW.last_name;
	
    INSERT INTO contact_log
        (trigger_name, trigger_timing, trigger_event, trigger_type, old_last_name, new_last_name)
    VALUES
        (lv_trigger_name, lv_trigger_timing, lv_trigger_event, lv_trigger_type, OLD.last_name, NEW.last_name);

    -- Raise an exception.
    IF lv_trigger_event = 'UPDATE'  THEN
        
        RAISE NOTICE 'Attempting to update: %', NEW.last_name;
    
		IF NEW.last_name = REPLACE(NEW.last_name, ' ', '-') THEN
        	RAISE EXCEPTION 'Attempted to change from hyphenated last_name to two-word field.';
    
		END IF;
		
    END IF;

    --  Return from function to complete SQL action. */
    RETURN NEW;

END;

$$
LANGUAGE plpgsql;

-- part 1.8 Write an insert and update contact_t trigger. 
-- Create trigger
CREATE TRIGGER contact_t
    BEFORE INSERT OR UPDATE ON contact
    FOR EACH ROW EXECUTE FUNCTION contact_log_f();


-- part 2 TEST CASE
-- part 2.1 Write an insert statement to the contact table with a last_name containing 'Smith Wyse'.

-- Insert into the contact table. 
INSERT 
INTO contact 
( member_id
, contact_type
, last_name
, first_name
, middle_name
, created_by
, last_updated_by )
VALUES 
((SELECT   member_id
    FROM     member
    WHERE    account_number = 'SLC-000040')
,(SELECT   common_lookup_id
    FROM     common_lookup
    WHERE    common_lookup_table = 'MEMBER'
    AND      common_lookup_column = 'MEMBER_TYPE'
    AND      common_lookup_type = 'INDIVIDUAL')
,'Smith Wyse'
,'Samuel'
, NULL
, 1002
, 1002); 

-- Verify that the multiword last name is hyphenated. 
SELECT last_name
FROM contact 
WHERE last_name like 'Smith_Wyse';

-- Should return the following. 
-- last_name
-- ------------
-- Smith-Wyse
-- (1 row)

-- part 2.2 Write an update statement to the contact table with a last_name containing 'Smith Wyse'.
-- Update contact table.
UPDATE contact
SET    last_name = 'Smith Wyse'
WHERE  last_name = 'Smith-Wyse';

-- Should return the following.
-- psql:postgres_lab13.sql:289: ERROR:  Attempted to change from hyphenated last_name to two word field.
-- CONTEXT:  PL/pgSQL function contact_log_f() line 39 at RAISE 

-- part 2.3 Verify the contents of the contact_log table with this query.
-- Verify two rows written to contact_log table.
SELECT trigger_name
,      trigger_timing
,      old_last_name
,      new_last_name
FROM   contact_log;

-- Should return the following.
-- trigger_name | trigger_timing | old_last_name | new_last_name
-- --------------+----------------+---------------+---------------
-- CONTACT_T    | BEFORE         |               | Smith-Wyse
-- (1 row)

-- part 2.4 Verify the contents of the contact table with this query.
-- Query the last name entry of Smith-Wyse after trigger.
SELECT c.last_name || ', ' || c.first_name AS full_name
FROM   contact c
WHERE  c.last_name LIKE 'Smith_Wyse';

-- Should return the following.
-- full_name
-- --------------------
-- Smith-Wyse, Samuel
-- (1 row)