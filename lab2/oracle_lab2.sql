/* Declare a session bind variable. */
VARIABLE whom VARCHAR2(20)

/* Enable SERVEROUTPUT setting. */
SET SERVEROUTPUT ON SIZE UNLIMITED;

/* Test case when session bind variable is null. */
BEGIN
  /* Print a session variable value or the default value. */
  IF :whom IS NOT NULL THEN
    dbms_output.put_line('Hello '||:whom||'!');
  ELSE
    dbms_output.put_line('Hello World!');
  END IF;
END;
/

/* Set the session bind variable with a value. */
BEGIN
  :whom := 'Gideon';
END;
/

/* Test case when session bind variable is not null. */
BEGIN
  /* Print a session variable value or the default value. */
  IF :whom IS NOT NULL THEN
    dbms_output.put_line('Hello '||:whom||'!');
  ELSE
    dbms_output.put_line('Hello World!');
  END IF;
END;
/


/*
OUTPUT

Hello World!

PL/SQL procedure successfully completed.


PL/SQL procedure successfully completed.

Hello Gideon!

PL/SQL procedure successfully completed.
*/ 