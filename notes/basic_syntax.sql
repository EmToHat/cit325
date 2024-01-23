DECLARE -- Optional section
< declarations section >
-- defines variables, cursors, subprograms, and other elements.
BEGIN -- Mandatory section
< executable command (s) >
-- must have at least one executable line of code
-- may be a NULL command (indicating that nothing will be executed)
EXCEPTION -- Optional section
<
exception handling >
-- Conains exception(s) which handle errors in the program.
END;

-- Hello World Example
DECLARE message VARCHAR2(20) := 'Hello World!';

BEGIN dbms_output.put_line (message);

END;

-- end; signals the end of the PL/SQL block.
/ -- to run code from the SQL command line.
-- Output
/*
Hello World

PL/SQL procedure successfully completed.
 */
-- PL/SQL Identifiers
/*
Identifiers are constants, variables, exceptions, procedures, cursors and reserved words.
Consist of a letter followed by more letters, numberals, dollarsigns, underscores, and number signs.
cannot exceed 30 characters.

Not case-sensitive
 */
integer /*OR*/ INTEGER -- numeric value
-- PL/SQL Delimiters
/*
A symbol with a special meaning.
 */
/*

+, - , *, /    Addition, subtraction/negation, multiplication, division

%              Attribute indicator

'              Character string delimiter

.	            Component selector

(,)	            Expression or list delimiter

:	            Host variable indicator

,	            Item separator

"	            Quoted identifier delimiter

=	            Relational operator

@	            Remote access indicator

;	            Statement terminator

:=	            Assignment operator

=>	            Association operator

||	            Concatenation operator

 **	            Exponentiation operator

<<, >>	        Label delimiter (begin and end)

/ *, * /	    Multi-line comment delimiter (begin and end)

--	            Single-line comment indicator

..	            Range operator

<, >, <=, >=	Relational operators

<>, '=, ~=, ^=	Different versions of NOT EQUAL


 */
-- PL/SQL Comments
DECLARE
-- variable declaration 
message varchar2(20) := 'Hello, World!';

BEGIN
/* 
 *  PL/SQL executable statement(s) 
 */
dbms_output.put_line (message);

END;

/
-- oracle lab 6
CREATE
OR REPLACE TYPE custom_record AS OBJECT (
  number_member NUMBER,
  date_member DATE,
  string_member VARCHAR2(20)
);

CREATE
OR REPLACE FUNCTION cast_strings (string_list IN SYS.ODCIVARCHAR2LIST) RETURN custom_record AS result custom_record;

BEGIN IF string_list IS NULL
OR string_list.COUNT = 0 THEN RETURN NULL;

-- Handle empty input list
END IF;

-- Extract values from the first element of the list
result.number_member := TO_NUMBER(REGEXP_SUBSTR(string_list (1), '(\d+)'));

result.date_member := TO_DATE(
  REGEXP_SUBSTR(string_list (1), '(\d{2}-[A-Z]{3}-\d{2})'),
  'DD-MON-YY'
);

result.string_member := REGEXP_SUBSTR(string_list (1), '\|(.*)', 1, 1, NULL, 1);

RETURN result;

END cast_strings;

/
DECLARE string_list SYS.ODCIVARCHAR2LIST;

result custom_record;

BEGIN string_list := SYS.ODCIVARCHAR2LIST ('12345|01-JAN-22|Test String');

result := cast_strings (string_list);

DBMS_OUTPUT.PUT_LINE ('Number: ' || result.number_member);

DBMS_OUTPUT.PUT_LINE (
  'Date: ' || TO_CHAR(result.date_member, 'DD-MON-YY')
);

DBMS_OUTPUT.PUT_LINE ('String: ' || result.string_member);

END;

/
-- Week 05 Oracle PL/SQL
BEGIN
/* Read forward through the days. */
FOR i IN 1..pv_days.COUNT
LOOP
/* Call the ADD procedure to add the two lines that lead each verse. */
ADD ('On the' || pv_days || 'days of Christmas');

ADD ('my true love sent to me.');

/* Read backward through the lyrics based on the ascending value of the day. */
FOR j IN REVERSE 1..i
LOOP
/*  Add the unique string for the partridge and pear tree's first 
 *  occurrence in the song when the condition is met, and the 
 *  generic verses when the condition is not met.
 */
IF i = 1 THEN
ADD ('-' || 'A' || '' || pv_gifts (i).gift);

ELSE
ADD (
  '-' || pv_gifts (i).days || '' || pv.gift (i).gift
);

END IF;

END
LOOP;

/* A line break by verse. */
ADD (CHR(13));

END
LOOP;

/* Return the song's lyrics. */
RETURN lv_retval;

END;

/