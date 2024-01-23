CREATE OR REPLACE
  FUNCTION npv
  ( future_value  decimal
  , periods       integer
  , interest      decimal )
  RETURNS decimal AS
  $$
  DECLARE
    /* Declare a result variable. */
    ret_val decimal;
  BEGIN
    /* Calculate the result and round it to the nearest penny and assign it to a local variable. */
    ret_val := (future_value / ((1 + interest) ^periods));
	
    /* Return the calculated result. */
    RETURN ret_val;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

DO
$$
DECLARE
  /* Declare inputs by data type. */
    future_value    decimal := 41000;
    periods         integer := 60;
    interest        decimal := .06;

  /* Result variable. */
  lv_result decimal;
BEGIN
  /* Call function and assign value. */
  SELECT ROUND(npv(future_value, periods, interest), 2) INTO lv_result;
  
  /* Display value. */
  RAISE NOTICE '%',CONCAT('The result [',lv_result,'].');
END;
$$;