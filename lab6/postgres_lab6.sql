-- TASK
-- Write a cast_strings function that converts a 
-- list of 20 character variable length strings 
-- into a record structure with number, date, 
-- and string members

-- part 1
-- Implement the verify_date function as follows.

CREATE FUNCTION verify_date
    ( IN pv_date_in  VARCHAR(10)) RETURNS BOOLEAN AS
    $$

    DECLARE
    -- Local return variable.
    lv_retval  BOOLEAN := FALSE;

    BEGIN

    -- Check for a YYYY-MM-DD or YYYY-MM-DD string.
    IF REGEXP_MATCH(pv_date_in,'^[0-9]{2,4}-[0-9]{2,2}-[0-9]{2,2}$') IS NOT NULL THEN

        -- Case statement checks for 28 or 29, 30, or 31 day month.
        CASE 

            -- Valid 31 day month date value.
            WHEN (LENGTH(pv_date_in) = 10 AND
                    SUBSTRING(pv_date_in,6,2) IN ('01','03','05','07','08','10','12') AND

                    TO_NUMBER(SUBSTRING(pv_date_in,9,2),'99') BETWEEN 1 AND 31) OR
                    
                    (LENGTH(pv_date_in) = 8 AND

                    SUBSTRING(pv_date_in,4,2) IN ('01','03','05','07','08','10','12') AND

                    TO_NUMBER(SUBSTRING(pv_date_in,7,2),'99') BETWEEN 1 AND 31) THEN 

                lv_retval := true;

            -- Valid 30 day month date value. 
            WHEN (LENGTH(pv_date_in) = 10 AND
                    SUBSTRING(pv_date_in,6,2) IN ('04','06','09','11') AND
                    
                    TO_NUMBER(SUBSTRING(pv_date_in,9,2),'99') BETWEEN 1 AND 30) OR
                    
                    (LENGTH(pv_date_in) = 8 AND
                    
                    SUBSTRING(pv_date_in,4,2) IN ('04','06','09','11') AND
                    
                    TO_NUMBER(SUBSTRING(pv_date_in,7,2),'99') BETWEEN 1 AND 30) THEN 

                lv_retval := true;

            -- Valid 28 or 29 day month date value for February.
            WHEN (LENGTH(pv_date_in) = 10 AND SUBSTRING(pv_date_in,6,2) = '02') OR

                    (LENGTH(pv_date_in) =  8 AND SUBSTRING(pv_date_in,4,2) = '02') THEN

                    -- Verify 2-digit or 4-digit year.
                    IF (LENGTH(pv_date_in) = 10 AND
                        MOD(TO_NUMBER(SUBSTRING(pv_date_in,1,4),'9999'),4) = 0) OR
                        (LENGTH(pv_date_in) =  8 AND
                        MOD(TO_NUMBER(CONCAT('20',SUBSTRING(pv_date_in,1,2)),'9999'),4) = 0) THEN

                        IF TO_NUMBER(SUBSTRING(pv_date_in,(LENGTH(pv_date_in) -1),2),'99')

                                BETWEEN 1 AND 29 THEN

                            lv_retval := true;

                        END IF;
                    
                    ELSE -- Not a leap year.

                        IF TO_NUMBER(SUBSTRING(pv_date_in,(LENGTH(pv_date_in) -1),2),'99')

                            BETWEEN 1 AND 28 THEN 

                                lv_retval := true;
                        
                        -- The condition does not require evaluation because the default
                        -- return value is false; however, it is provided to show you
                        -- what happens when a leap year is not found and the day is
                        -- outside the range of 1 to 28.

                        -- ELSE
                        --  RAISE NOTICE '[% %]','Not a non-leap year day:',
                        --                       SUBSTRING(pv_date_in,(LENGTH(pv_date_in) - 1),2);

                        END IF;

                    END IF;

                ELSE

                    NULL;

                END CASE; 

            END IF;

            -- Return date.
            RETURN lv_retval;

        END;

$$ LANGUAGE plpgsql;


-- part 2
-- Test the implementation of the 
-- verify_date function 
-- (HINT: You should note how you verify a 
-- Boolean return from the verify_date function 
-- with a literal lowercase 't'.):

DO
$$

DECLARE

    -- Test set values.
    lv_test_case  VARCHAR[] := ARRAY['2022-01-15','2022-01-32','22-02-29','2022-02-29','2024-02-29'];

BEGIN

    -- Test the set of values.
    FOR i IN 1..ARRAY_LENGTH(lv_test_case,1) LOOP

        IF verify_date(lv_test_case[i]) = 't' THEN
  	  
            RAISE NOTICE '[%][%]','True. ',lv_test_case[i];
        
        ELSE
  	  
            RAISE NOTICE '[%][%]','False.',lv_test_case[i];
    
        END IF;

    END LOOP;

END;
$$;


-- should print to the console
-- psql:postgres_lab6.sql:86: NOTICE:  [True. ][2022-01-15]
-- psql:postgres_lab6.sql:86: NOTICE:  [False.][2022-01-32]
-- psql:postgres_lab6.sql:86: NOTICE:  [False.][22-02-29]
-- psql:postgres_lab6.sql:86: NOTICE:  [False.][2022-02-29]
-- psql:postgres_lab6.sql:86: NOTICE:  [True. ][2024-02-29]


-- part 3
-- Create a structure with the name struct that contains the following
    -- An xnumber member with the NUMBER data type.
    -- An xdate member with the DATE data type.
    -- An xstring member with the VARCHAR(20) data type.

CREATE TYPE struct AS
( xnumber NUMERIC
, xdate DATE
, xstring VARCHAR(20) );


-- part 4
-- create cast_strings function that accepts a single parameter of a varchar[]; and returns a struct structure.
    -- HINT choose between LIKE, COMPARE TO, and REGEXP_MATCH comparison approaches. 
    -- HINT You must evaluate for a string, date, and number in a specific order.

CREATE OR REPLACE
    FUNCTION cast_strings
    ( pv_list  VARCHAR[] ) RETURNS struct AS
    $$

    DECLARE

        -- Declare a UDT and initialize an empty struct variable.
        lv_retval struct;
    
    BEGIN 

        -- Loop through list of values to find only the numbers.
        FOR i IN 1..ARRAY_LENGTH(pv_list,1) LOOP 
            
            CASE

                -- Implement WHEN clause that checks that the xnumber member is null and that
                -- the pv_list element contains only digits; and assign the pv_list element to
                -- the lv_retval's xnumber member.

                WHEN pv_list[i] SIMILAR TO '^[0-9]+$' THEN
                        lv_retval.xnumber := pv_list[i];

                -- Implement WHEN clause that checks that the xdate member is null and that
                -- the pv_list element is a valid date; and assign the pv_list element to
                -- the lv_retval's xdate member.

                WHEN pv_list[i] SIMILAR TO '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' AND verify_date(pv_list[i]) THEN
                        lv_retval.xdate := TO_DATE(pv_list[i],'%y-%m-%d');

                -- Implement WHEN clause that checks that the xstring member is null and that
                -- the pv_list element contains only alphanumeric values; and assign the pv_list
                -- element to the lv_retval's xstring member.

                WHEN pv_list[i] SIMILAR TO '[0-9A-Za-z\-\,\]*' THEN
                        lv_retval.xstring := pv_list[i];

                ELSE

            END CASE;

        END LOOP;
    
        -- Print the results.
        RETURN lv_retval;
    
    END;

$$ LANGUAGE plpgsql;


-- part 5 TEST CASE #1
-- Write an anonymous block program that tests cast_string function.
-- needs to have an instance of the tre ADT:
-- A literal date of '16-APR-2018'
-- A literal string of 'Day after ...'
-- A literal number of '1040'

DO
$$
DECLARE
    -- Define a list.
    lv_list  VARCHAR[] := ARRAY['2018-04-16','Day after ...','1040'];

    -- Declare a structure.
    lv_struct  struct; 

BEGIN

    -- Assign a parsed value set to get a value structure.
    lv_struct := cast_strings(lv_list);

    -- Print the values of the compound struct variable.
    RAISE NOTICE '[%]',lv_struct.xstring;
    RAISE NOTICE '[%]',TO_CHAR(lv_struct.xdate,'DD-MON-YYYY');
    RAISE NOTICE '[%]',lv_struct.xnumber;

END;
$$;

-- part 5.2
-- Use the following DO-block to test the cast_strings function to test sparsely indexed lists.

DO
$$

DECLARE

    lv_list    VARCHAR(11)[] := ARRAY['86','1944-04-25','Happy'];
    lv_struct  STRUCT;

BEGIN

    -- Pass the array of strings and return a record type.
    lv_struct := cast_strings(lv_list);

    -- Print the elements returned.
    RAISE NOTICE '[%]', lv_struct.xnumber;
    RAISE NOTICE '[%]', lv_struct.xdate;
    RAISE NOTICE '[%]', lv_struct.xstring;

END;
$$;

-- The test should return
-- psql:verify_pg.SQL:263: NOTICE:  [86]
-- psql:verify_pg.SQL:263: NOTICE:  [1944-04-25]
-- psql:verify_pg.SQL:263: NOTICE:  [Happy]


-- part 6
-- Use the following query to test the cast_strings function.

WITH get_struct AS
    (SELECT cast_strings(ARRAY['99','2015-06-14','Agent 99']) AS mystruct)
    SELECT (mystruct).xnumber
    ,      (mystruct).xdate
    ,      (mystruct).xstring
FROM    get_struct;

-- The query should return the following:
--  xnumber |   xdate    | xstring
-- ---------+------------+----------
--      99 | 2015-06-14 | Agent 99
-- (1 ROW)
        