-- part 1 
CREATE OR REPLACE
  FUNCTION verify_date
  ( pv_date_in VARCHAR2) RETURN BOOLEAN IS 

  lv_date_in VARCHAR2(11);

  lv_date BOOLEAN := FALSE;

BEGIN 
  lv_date_in := UPPER( pv_date_in );

IF REGEXP_LIKE(lv_date_in,'^[0-9]{2,2}-[ADFJMNOS][ACEOPU][BCGLNPRTVY]-([0-9]{2,2}|[0-9]{4,4})$') THEN
    CASE 
      WHEN SUBSTR(lv_date_in,4,3) IN ('JAN','MAR','MAY','JUL','AUG','OCT','DEC') AND
          TO_NUMBER(SUBSTR(pv_date_in,1,2)) BETWEEN 1 AND 31 THEN
        
        lv_date := TRUE;

      WHEN SUBSTR(lv_date_in,4,3) IN ('APR','JUN','SEP','NOV') AND
          TO_NUMBER(SUBSTR(pv_date_in,1,2)) BETWEEN 1 AND 30 THEN
        
        lv_date := TRUE;

      WHEN SUBSTR(lv_date_in,4,3) = 'FEB' THEN

        IF (LENGTH(pv_date_in) = 9 AND MOD(TO_NUMBER(SUBSTR(pv_date_in,8,2)) + 2000,4) = 0 OR
            LENGTH(pv_date_in) = 11 AND MOD(TO_NUMBER(SUBSTR(pv_date_in,8,4)),4) = 0) AND
            TO_NUMBER(SUBSTR(pv_date_in,1,2)) BETWEEN 1 AND 29 THEN
        
          lv_date := TRUE;

        ELSE
          IF TO_NUMBER(SUBSTR(pv_date_in,1,2)) BETWEEN 1 AND 28 THEN

            lv_date := TRUE;
          END IF;
        END IF;
      ELSE
        NULL;
    END CASE;
END IF;

RETURN lv_date;

EXCEPTION 
  WHEN VALUE_ERROR THEN 
    RETURN lv_date;
END;
/



-- part 2
DECLARE
  TYPE test_case IS TABLE OF VARCHAR2(11);

  lv_test_case TEST_CASE := test_case('15-JAN-2022', '32-JAN-2022', '29-FEB-2022', '29-FEB-2024');
BEGIN 
  FOR i IN 1..lv_test_case.COUNT LOOP 
    IF verify_date(lv_test_case(i)) THEN 
      DBMS_OUTPUT.PUT_LINE('True.');
    ELSE
      DBMS_OUTPUT.PUT_LINE('False.');
    END IF;
  END LOOP;
END;
/



-- part 3
CREATE OR REPLACE
  TYPE tre IS TABLE OF VARCHAR2(100);
/ 


-- part 4
CREATE OR REPLACE
  TYPE struct IS OBJECT
  ( xnumber NUMBER
  , xdate DATE
  , xstring VARCHAR2(20));
/



CREATE OR REPLACE TYPE structs IS TABLE OF struct;


-- part 5
CREATE OR REPLACE
  FUNCTION cast_strings
  ( pv_list TRE ) RETURN struct IS

    lv_retval STRUCT := struct( NULL
                              , NULL
                              , NULL );

    FUNCTION debugger
    ( pv_string VARCHAR2 ) RETURN VARCHAR2 IS

      lv_retval VARCHAR2(60);

    BEGIN 
      $IF $$DEBUG = 1 $THEN
        lv_retval := 'Evaluating ['|| pv_string ||']';
      $END

      RETURN lv_retval;
    END debugger;
  BEGIN 
    FOR i IN 1..pv_list.LAST LOOP
      DBMS_OUTPUT.PUT_LINE(debugger(pv_list(i)));

      IF pv_list.EXISTS(i) THEN

        CASE 
          WHEN lv_retval.xnumber IS NULL AND REGEXP_LIKE(pv_list(i), '^[0-9]+$') THEN
            lv_retval.xnumber := pv_list(i);

          WHEN lv_retval.xdate IS NULL AND to_date(pv_list(i, 'DD-MON-YYYY')) IS NOT NULL THEN
            lv_retval.xdate := to_date(pv_list(i, 'DD-MON-YYYY'));

          WHEN lv_retval.xstring IS NULL AND REGEXP_LIKE(pv_list(i), '^[a-zA-Z0-9 ]+$') THEN
            lv_retval.xstring := pv.list(i);
          ELSE
            NULL;
        END CASE;
      END IF;
    END LOOP;

    RETURN lv_retval;
  END;
/



-- part 6 TEST CASE 1
/*
* Write an anonymous block program to test cast_string function.
*/
DECLARE
  lv_list TRE := tre('16-APR-2018', 'Day after ...', '1040');

  lv_struct STRUCT := struct(null, null, null)

BEGIN 
  lv_struct := cast_strings(lv_list);

  DBMS_OUTPUT.PUT_LINE('xstring ['||lv_struct.xstring||']');
  DBMS_OUTPUT.PUT_LINE('xdate ['||lv_struct.xdate||']');
  DBMS_OUTPUT.PUT_LINE('xnumber ['||lv_struct.xnumber||']');
END;
/



-- part 7 TEST CASE 2
SELECT TO_CHAR(xdate,'DD-MON-YYYY') AS xdate
,      xnumber
,      xstring
FROM   TABLE(structs(cast_strings(tre('catch22','25','25-Nov-1945'))
                    ,cast_strings(tre('31-APR-2017','1918','areodromes'))));