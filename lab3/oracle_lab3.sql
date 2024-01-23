SET SERVEROUTPUT ON SIZE UNLIMITED
BEGIN
  /* Ascending loops. */
  FOR l_counter IN 1..10
  LOOP
    DBMS_OUTPUT.PUT_LINE( '[' || l_counter || ']' );
  END LOOP;

  /* Descending loop. */
   FOR l_counter IN REVERSE 1..10
  LOOP
    DBMS_OUTPUT.PUT_LINE( '[' || l_counter || ']' );
  END LOOP;
END;
/

/*
OUTPUT

[1]
[2]
[3]
[4]
[5]
[6]
[7]
[8]
[9]
[10]
[10]
[9]
[8]
[7]
[6]
[5]
[4]
[3]
[2]
[1]

PL/SQL procedure successfully completed.
*/ 