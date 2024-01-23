-- Part 1
CREATE OR REPLACE PROCEDURE insert_contact
( pv_first_name          VARCHAR2
, pv_middle_name         VARCHAR2
, pv_last_name           VARCHAR2
, pv_contact_type        VARCHAR2
, pv_account_number      VARCHAR2
, pv_member_type         VARCHAR2
, pv_credit_card_number  VARCHAR2
, pv_credit_card_type    VARCHAR2
, pv_street_address      VARCHAR2
, pv_city                VARCHAR2
, pv_state_province      VARCHAR2
, pv_postal_code         VARCHAR2
, pv_address_type        VARCHAR2
, pv_country_code        VARCHAR2
, pv_area_code           VARCHAR2
, pv_telephone_number    VARCHAR2
, pv_telephone_type      VARCHAR2
, pv_user_name           VARCHAR2 ) IS

  /* Declare local constants. */
  lv_current_date      DATE := TRUNC(SYSDATE);

  /* Declare a who-audit variables. */
  lv_member_id         NUMBER :=0; 
  lv_created_by        NUMBER;
  lv_updated_by        NUMBER;
  lv_system_user_id    NUMBER;

  /* Declare type variables. */
  lv_member_type       NUMBER;
  lv_credit_card_type  NUMBER;
  lv_contact_type      NUMBER;
  lv_address_type      NUMBER;
  lv_telephone_type    NUMBER;


UPDATE system_user
SET    system_user_name = system_user_name || ' ' || system_user_id
WHERE  system_user_name = 'DBA';


  FUNCTION get_lookup_type 
  ( pv_table_name    VARCHAR2
  , pv_column_name   VARCHAR2
  , pv_type_name     VARCHAR2 ) RETURN NUMBER IS

    /* Declare a return variable. */
    lv_retval  NUMBER := 0;

    /* Declare a local cursor. */
    CURSOR get_lookup_value
    ( cv_table_name    VARCHAR2
    , cv_column_name   VARCHAR2
    , cv_type_name     VARCHAR2 ) IS
      SELECT common_lookup_id
      FROM   common_lookup
      WHERE  common_lookup_table = cv_table_name
      AND    common_lookup_column = cv_column_name
      AND    common_lookup_type = cv_type_name;

  BEGIN

    /* Find a valid value. */
    FOR i IN get_lookup_value(pv_table_name, pv_column_name, pv_type_name) LOOP
      lv_retval := i.common_lookup_id;
    END LOOP;

    /* Return the value, where a 0 always fails the insert statements. */
    RETURN lv_retval;
  END get_lookup_type;
  
  /* Convert the member account_number into a surrogate member_id value. */
  FUNCTION get_member_id
  ( pv_account_number VARCHAR2 ) RETURN NUMBER IS
  
    /* Local return variable. */
    lv_retval  NUMBER := 0;  -- Default value is 0.
 
    /* A cursor that lookups up a member's ID by their account number. */
    CURSOR find_member_id
    ( cv_account_number VARCHAR2 ) IS
      SELECT member_id
      FROM member
      WHERE pv_account_number = cv_account_number;
    
  BEGIN  
    /* 
     *  Write a FOR-LOOP that:
     *    Assign a member_id as the return value when a row exists.
     */
    FOR i IN find_member_id(pv_account_number) LOOP
      lv_retval := i.member_id;
    END LOOP;

    /* Return 0 when no row found and the member_id when a row is found. */
    RETURN lv_retval;
  END get_member_id;
  
BEGIN
  /* Get the member_type ID value. */
  lv_member_type := get_lookup_type('MEMBER','MEMBER_TYPE', pv_member_type);

  /* Get the credit_card_type ID value. */
  lv_credit_card_type := get_lookup_type('MEMBER','CREDIT_CARD_TYPE', pv_credit_card_type);

  /* Get the contact_type ID value. */
  lv_contact_type := get_lookup_type('CONTACT','CONTACT_TYPE', pv_contact_type);

  /* Get the address_type ID value. */
  lv_address_type := get_lookup_type('ADDRESS','ADDRESS_TYPE', pv_address_type);

  /* Get the telephone_type ID value. */
  lv_telephone_type := get_lookup_type('TELEPHONE','TELEPHONE_TYPE', pv_telephone_type);


-- Convert the system_user_name value into a surrogate system_user_id value
-- and assign the system_user_id value to the local lv_system_user_id variable.
SELECT user_id
INTO lv_system_user_id
FROM system_user
WHERE user_name = pv_user_name;

-- Assign the system_user_id value to these local variables.
lv_created_by := lv_system_user_id;
lv_updated_by := lv_system_user_id;


  /* Set save point. */
  SAVEPOINT start_point;

  /*
   *  Identify whether a member account exists and assign it's value
   *  to a local variable.
   */
  IF get_member_id(pv_account_number) = 0 THEN  
    -- Insert into member table.
    INSERT INTO member (account_number, created_by, updated_by, created_date, updated_date)
    VALUES (pv_account_number, lv_created_by, lv_updated_by, lv_current_date, lv_current_date)
    RETURNING member_id INTO lv_member_id;
  END IF;

  /* Insert into contact table. */
  INSERT INTO contact (member_id, contact_type_id, created_by, updated_by, created_date, updated_date)
  VALUES (lv_member_id, lv_contact_type, lv_created_by, lv_updated_by, lv_current_date, lv_current_date);


  /* Insert into address table. */
  INSERT INTO address (member_id, address_type_id, country_code, city, state_province, postal_code, created_by, updated_by, created_date, updated_date)
  VALUES (lv_member_id, lv_address_type, pv_country_code, pv_city, pv_state_province, pv_postal_code, lv_created_by, lv_updated_by, lv_current_date, lv_current_date);


  /* Insert into street_address table. */
  INSERT INTO street_address (address_id, street_address, created_by, updated_by, created_date, updated_date)
  VALUES (LAST_INSERT_ID(), pv_street_address, lv_created_by, lv_updated_by, lv_current_date, lv_current_date);

  
  /* Insert into telephone table. */
  INSERT INTO telephone (member_id, telephone_type_id, area_code, telephone_number, created_by, updated_by, created_date, updated_date)
  VALUES (lv_member_id, lv_telephone_type, pv_area_code, pv_telephone_number, lv_created_by, lv_updated_by, lv_current_date, lv_current_date); 


  /* Commit the writes to all four tables. */
  COMMIT;

EXCEPTION
  /* Catch all errors. */
  WHEN OTHERS THEN
    /* Unremark the following line to generate an error message. */
    -- dbms_output.put_line('['||SQLERRM||']');
    ROLLBACK TO start_point;
END insert_contact;
/


BEGIN
  DELETE FROM telephone WHERE contact_id > 1018;
  DELETE FROM street_address WHERE address_id > 1018;
  DELETE FROM address WHERE address_id > 1018;
  DELETE FROM contact WHERE contact_id > 1018;
  DELETE FROM member WHERE member_id > 1018;
END;
/


BEGIN
  /* Call procedure once. */
  insert_contact(
      pv_first_name         => 'Charles'
    , pv_middle_name        => 'Francis'
    , pv_last_name          => 'Xavier'
    , pv_contact_type       => 'CUSTOMER'
    , pv_account_number     => 'SLC-000008'
    , pv_member_type        => 'INDIVIDUAL'
    , pv_credit_card_number => '7777-6666-5555-4444'
    , pv_credit_card_type   => 'DISCOVER_CARD'
    , pv_street_address     => '1407 Graymalkin Lane' 
    , pv_city               => 'Bayville'
    , pv_state_province     => 'New York'
    , pv_postal_code        => '10032'
    , pv_address_type       => 'HOME'
    , pv_country_code       => '001'
    , pv_area_code          => '207'
    , pv_telephone_number   => '111-1234'
    , pv_telephone_type     => 'HOME'
    , pv_user_name          => 'DBA 2'
    );

  /* Call procedure twice. */
  insert_contact(
      pv_first_name         => 'James'
    , pv_last_name          => 'Xavier'
    , pv_contact_type       => 'CUSTOMER'
    , pv_account_number     => 'SLC-000008'
    , pv_member_type        => 'INDIVIDUAL'
    , pv_credit_card_number => '7777-6666-5555-4444'
    , pv_credit_card_type   => 'DISCOVER_CARD'
    , pv_street_address     => '1407 Graymalkin Lane' 
    , pv_city               => 'Bayville'
    , pv_state_province     => 'New York'
    , pv_postal_code        => '10032'
    , pv_address_type       => 'HOME'
    , pv_country_code       => '001'
    , pv_area_code          => '207'
    , pv_telephone_number   => '111-1234'
    , pv_telephone_type     => 'HOME'
    , pv_user_name          => 'DBA 2'
    );
END;
/


COLUMN account_number  FORMAT A10  HEADING "Account|Number"
COLUMN contact_name    FORMAT A30  HEADING "Contact Name"
SELECT m.account_number
,      c.last_name ||', '||c.first_name AS contact_name
FROM   member m INNER JOIN contact c
ON     m.member_id = c.member_id
WHERE  m.account_number = 'SLC-000008';