-- run the video_store.sql file
-- @video_store.sql

-- TASK
-- Overloading in PL/pgSQL doesn't work inside a package. 
-- You overload by defining functions or procedures with the same name and different lists of parameters. 
-- You should use the solution from Lab #9 as your starting point.

-- PostgreSQL implements overloading in the scope of the database and schema, which means the signature of all functions or procedures must be unique in that scope. 
-- You incorporate this DROP statement before creating the procedure because a subsequent lab will introduce overloading.



-- part 1
-- Drop the original contact_insert procedure it it still exists.
DROP PROCEDURE IF EXISTS contact_insert
( IN pv_member_type         VARCHAR(30)
, IN pv_account_number      VARCHAR(10)
, IN pv_credit_card_number  VARCHAR(19)
, IN pv_credit_card_type    VARCHAR(30)
, IN pv_first_name          VARCHAR(20)
, IN pv_middle_name         VARCHAR(20)
, IN pv_last_name           VARCHAR(20)
, IN pv_contact_type        VARCHAR(30)
, IN pv_address_type        VARCHAR(30)
, IN pv_city                VARCHAR(30)
, IN pv_state_province      VARCHAR(30)
, IN pv_postal_code         VARCHAR(20)
, IN pv_street_address      VARCHAR(30)
, IN pv_telephone_type      VARCHAR(30)
, IN pv_country_code        VARCHAR(3)
, IN pv_area_code           VARCHAR(6)
, IN pv_telephone_number    VARCHAR(10)
, IN pv_created_by          INTEGER
, IN pv_last_updated_by     INTEGER);

-- part 2
-- Second drop statement to make script re-runnable.
-- Drops the contact_insert procedure.
DROP PROCEDURE IF EXISTS contact_insert
( IN pv_member_type         VARCHAR(30)
, IN pv_account_number      VARCHAR(10)
, IN pv_credit_card_number  VARCHAR(19)
, IN pv_credit_card_type    VARCHAR(30)
, IN pv_first_name          VARCHAR(20)
, IN pv_middle_name         VARCHAR(20)
, IN pv_last_name           VARCHAR(20)
, IN pv_contact_type        VARCHAR(30)
, IN pv_address_type        VARCHAR(30)
, IN pv_city                VARCHAR(30)
, IN pv_state_province      VARCHAR(30)
, IN pv_postal_code         VARCHAR(20)
, IN pv_street_address      VARCHAR(30)
, IN pv_telephone_type      VARCHAR(30)
, IN pv_country_code        VARCHAR(3)
, IN pv_area_code           VARCHAR(6)
, IN pv_telephone_number    VARCHAR(10)
, IN pv_user_name           VARCHAR(20));

-- part 3.1
-- Create a get_member_id function
-- function returns a primary key for an existing row from the member table or a 0 (zero).

-- Create or replace get_member_id function.
CREATE OR REPLACE
    FUNCTION get_member_id
    ( IN pv_account_number  VARCHAR ) RETURNS INTEGER AS
$$

    -- Required for PL/pgSQL programs.
    DECLARE

        -- Local return variable.
        lv_retval  INTEGER := 0;  -- Default value is 0.

        -- Use a cursor, which will not raise an exception at runtime.
        find_member_id CURSOR 
        ( cv_account_number  VARCHAR ) FOR
        SELECT m.member_id
            FROM   member m
            WHERE  m.account_number = cv_account_number;
    
    BEGIN

        -- Assign a value when a row exists.
        FOR i IN find_member_id(pv_account_number) LOOP
            lv_retval := i.member_id;
        END LOOP;

        -- Return 0 when no row found and the ID # when row found.
        RETURN lv_retval;
    END;

$$ LANGUAGE plpgsql;

-- part 3.2
-- TEST the get_member_id function
SELECT  retval AS "Return Member Value"
FROM   (SELECT get_member_id(m.account_number) AS retval
        FROM   member m
        ORDER BY m.account_number LIMIT 1) x
ORDER BY 1;

-- OUTPUT
-- Return Member Value
-- ---------------------
--                  1001
-- (1 row)


-- part 4.1
-- create a get_lookup_id function
-- function returns a primary keyfor an existing row from the common_lookup table or a 0 (zero). 

-- Create or replace get_member_id function.
CREATE OR REPLACE
    FUNCTION get_lookup_id
    ( IN pv_table_name   VARCHAR
    , IN pv_column_name  VARCHAR
    , IN pv_lookup_type  VARCHAR ) RETURNS INTEGER AS
$$

    -- Required for PL/pgSQL programs.
    DECLARE
        -- Local return variable.
        lv_retval  INTEGER := 0;  -- Default value is 0.

        -- Use a cursor, which will not raise an exception at runtime.
        find_lookup_id CURSOR 
        ( cv_table_name   VARCHAR
        , cv_column_name  VARCHAR
        , cv_lookup_type  VARCHAR ) FOR
            SELECT cl.common_lookup_id
                FROM   common_lookup cl
                WHERE  cl.common_lookup_table = cv_table_name
                AND    cl.common_lookup_column = cv_column_name
                AND    cl.common_lookup_type = cv_lookup_type;

    BEGIN

        -- Assign a value when a row exists.
        FOR i IN find_lookup_id( pv_table_name
                            , pv_column_name
                            , pv_lookup_type ) LOOP
            lv_retval := i.common_lookup_id;
        END LOOP;

        INSERT INTO debug values (concat('[',lv_retval,']',pv_table_name, ',', pv_column_name, ',', pv_lookup_type));

        -- Return 0 when no row found and the ID # when row found.

        RETURN lv_retval;
    END;

$$ LANGUAGE plpgsql;


-- part 4.2
-- TEST the get_lookup_id function
SELECT      DISTINCT
            CASE
                WHEN NOT retval = 0 THEN retval
            END AS "Return Lookup Value"
FROM     (SELECT get_lookup_id('MEMBER', 'MEMBER_TYPE', cl.common_lookup_type) AS retval
            FROM   common_lookup cl) x
WHERE NOT retval = 0
ORDER BY  1;

-- OUTPUT
-- Return Lookup Value
-- ---------------------
--                  1008
--                  1009
-- (2 rows)


-- part 5.1
-- Create a get_system_user_id function
-- function returns a primary key for an existing row or a 0 (zero).
-- Write the find_system_user_id cursor below and incorporate with the solution (HINT: get_cartoon_user_id function logic)

-- Create or replace get_system_user_id function.
CREATE OR REPLACE
    FUNCTION get_system_user_id
    ( IN pv_user_name  VARCHAR ) RETURNS INTEGER AS
$$

    -- Required for PL/pgSQL programs.
    DECLARE

        -- Local return variable.
        lv_retval  INTEGER := 0;  -- Default value is 0.

        -- Use a cursor, which will not raise an exception at runtime.
        find_system_user_id CURSOR 
        ( cv_user_name  VARCHAR ) FOR
            SELECT su.system_user_id
                FROM   system_user su
                WHERE  su.system_user_name = cv_user_name;

    BEGIN 

        -- Assign a value when a row exists.
        FOR i IN find_system_user_id(pv_user_name) LOOP
            lv_retval := i.system_user_id;
        END LOOP;

        -- Return 0 when no row found and the ID # when row found.
        RETURN lv_retval;

    END;

$$ LANGUAGE plpgsql;

-- part 5.2
-- TEST the get_system_user_id function
SELECT  retval AS "Return System Value"
FROM   (SELECT get_system_user_id(su.system_user_name) AS retval
        FROM   system_user su
        WHERE  system_user_name LIKE 'DBA%'	LIMIT 5) x
ORDER BY 1;

-- OUTPUT
-- Return System Value
-- ---------------------
--                  1001
--                  1002
--                  1003
--                  1004
--                  1005
-- (5 rows)


-- part 6.1
-- create the first contact_insert procedure

-- Transaction Management Solution modified from Lab 9.
SELECT 'Create contact_insert procedure' AS "Statement";
CREATE OR REPLACE PROCEDURE contact_insert
( IN pv_member_type         VARCHAR(30)
, IN pv_account_number      VARCHAR(10)
, IN pv_credit_card_number  VARCHAR(19)
, IN pv_credit_card_type    VARCHAR(30)
, IN pv_first_name          VARCHAR(20)
, IN pv_middle_name         VARCHAR(20)
, IN pv_last_name           VARCHAR(20)
, IN pv_contact_type        VARCHAR(30)
, IN pv_address_type        VARCHAR(30)
, IN pv_city                VARCHAR(30)
, IN pv_state_province      VARCHAR(30)
, IN pv_postal_code         VARCHAR(20)
, IN pv_street_address      VARCHAR(30)
, IN pv_telephone_type      VARCHAR(30)
, IN pv_country_code        VARCHAR(3)
, IN pv_area_code           VARCHAR(6)
, IN pv_telephone_number    VARCHAR(10)
, IN pv_system_user_id      INTEGER) AS
$$

DECLARE

    -- Declare type variables.
    lv_member_type       INTEGER;
    lv_credit_card_type  INTEGER;
    lv_contact_type      INTEGER;
    lv_address_type      INTEGER;
    lv_telephone_type    INTEGER;

    -- Local surrogate key variables.
    lv_member_id          INTEGER;
    lv_contact_id         INTEGER;
    lv_address_id         INTEGER;
    lv_street_address_id  INTEGER;

    -- Declare local variable.
    lv_middle_name  VARCHAR(20);

    -- Declare error handling variables.
    err_num  TEXT;
    err_msg  INTEGER;

BEGIN 

    -- Assing a null value to an empty string.
    IF pv_middle_name IS NULL THEN
        lv_middle_name = '';
    END IF;

    -- Replace the character type values with their appropriate
    -- common_lookup_id values by calling the get_lookup_id
    -- function.
    lv_member_type := get_lookup_id('MEMBER','MEMBER_TYPE',pv_member_type);
    lv_credit_card_type := <<<element>>>;
    lv_contact_type := <<<element>>>;
    lv_address_type := <<<element>>>;
    lv_telephone_type := <<<element>>>;

    -- Check for existing member row. Assign value when one exists,
    -- and assign zero when no member row is found.
    lv_member_id := <<<element>>>;

    -- Enclose the insert into member in an if-statement.
    IF lv_member_id = 0 THEN

    -- Insert into the member table when no row is found.
    -- Replace the two subqueries by calling the get_lookup_id 
    -- function for either the pv_member_type or credit_card_type
    -- value and assign it to a local variable.
        INSERT INTO member
        ( member_type
        , account_number
        , credit_card_number
        , credit_card_type
        , created_by
        , last_updated_by )
        VALUES
        ( lv_member_type
        , pv_account_number
        , pv_credit_card_number
        , lv_credit_card_type
        , pv_system_user_id
        , pv_system_user_id )
        RETURNING member_id INTO lv_member_id;
    END IF;
