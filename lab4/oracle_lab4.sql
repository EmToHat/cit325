DROP FUNCTION npv; 

CREATE OR REPLACE
	FUNCTION npv 
	( future_value	NUMBER
	, periods	INTEGER 
	, interest	NUMBER ) 
	RETURN NUMBER DETERMINISTIC IS
	BEGIN
		RETURN (future_value / ((1 + interest) **periods));
	END;
/

SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  	future_value NUMBER := 41000;
	periods INTEGER := 60;
	interest NUMBER := .06;
BEGIN
  	dbms_output.put_line('The result ['||ROUND(npv(future_value, periods, interest),2)||'].');
END;
/