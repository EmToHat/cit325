-- Run the video file before runing this file.

-- TASK
-- create an event driven contact_t trigger:
-- needs to convert two-part surname (separated by whitespace) in any insert statement into a hyphenated surname and stores it in the last_name column of the contact table w/o raising an exception.
-- needs to prevent the conversion of a hyphanated surname into a two-part surname (separated by whitespace) when someone attempts an update statement, and it raises an exception with that attempt. 


-- Part 1.1: Cleanup
    -- Delete a row from the contact table.
DELETE
FROM   contact
WHERE  last_name LIKE 'Smith_Wyse';

    -- Delete a row from the member table.
DELETE
FROM   member
WHERE  account_number = 'SLC-000040';

-- Part 1.2: Drop Trigger
DROP TRIGGER IF EXISTS CONTACT_T;

-- Part 1.3: Drop Function
DROP FUNCTION IF EXISTS get_member_id;

-- Part 1.4: Create/Replace Function
CREATE OR REPLACE
    FUNCTION get_member_id
    ( IN pv_account_number VARCHAR ) RETURNS INTEGER AS
$$
    -- Required for PL/pgSQL programs
    DECLARE

        -- Local return variable
        lv_retval INTEGER := 0 -- Default Value is zero (0)

        -- Use a cursor, which doesn't raise an exception at runtime.
        find_member_id CURSOR 
        ( cv_account_number VARCHAR ) FOR 
            SELECT m.member_id
                FROM member m 
                WHERE m.account_number = cv_account_number;

-- Part 1.5: Conditionally Insert Row
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

-- Part 1.6: Drop Table and Sequence
DROP TABLE IF EXISTS contact_log;

-- Part 1.7: Create Table
CREATE TABLE contact_log
( contact_log_id  SERIAL
, trigger_name    VARCHAR(30)
, trigger_timing  VARCHAR(6)
, trigger_event   VARCHAR(12)
, trigger_type    VARCHAR(16)
, old_last_name   VARCHAR(30)
, new_last_name   VARCHAR(30));

-- Part 1.8: Drop contact_log_f trigger
DROP FUNCTION IF EXISTS contact_log_f CASCADE;

-- Part 1.9: Create Autonomous Trigger
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

    IF OLD.last_name IS NULL THEN

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

-- Part 2.0: Create Contact Trigger
CREATE TRIGGER CONTACT_T
    BEFORE INSERT OR UPDATE ON contact
    FOR EACH ROW EXECUTE FUNCTION contact_log_f();

-- Test Cases
-- Part 2.1: Insert Statement
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

-- Part 2.2: Verify hyphenation
SELECT last_name
FROM contact 
WHERE last_name like 'Smith_Wyse';

-- Should return the following. 
-- last_name
-- ------------
-- Smith-Wyse
-- (1 row)

-- Part 2.3: Update Statement
UPDATE contact
SET    last_name = 'Smith Wyse'
WHERE  last_name = 'Smith-Wyse';

-- Should return the following.
-- psql:postgres_lab13.sql:289: ERROR:  Attempted to change from hyphenated last_name to two word field.
-- CONTEXT:  PL/pgSQL function contact_log_f() line 39 at RAISE 

-- Part 2.4: Verify contact_log Table
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

-- Part 2.5: Verify contact Table
SELECT c.last_name || ', ' || c.first_name AS full_name
FROM   contact c
WHERE  c.last_name LIKE 'Smith_Wyse';

-- Should return the following.
-- full_name
-- --------------------
-- Smith-Wyse, Samuel
-- (1 row)