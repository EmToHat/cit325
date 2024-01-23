-- before testing the insert_contact procedure
-- ensures all system_user_name values are unique
UPDATE system_user
SET    system_user_name = system_user_name || ' ' || system_user_id
WHERE  system_user_name = 'DBA';

-- clean test data
BEGIN
  DELETE FROM telephone WHERE contact_id > 1007;
  DELETE FROM street_address WHERE address_id > 1007;
  DELETE FROM address WHERE address_id > 1007;
  DELETE FROM transaction WHERE rental_id > 1007;
  DELETE FROM rental_item WHERE rental_id > 1007;
  DELETE FROM rental WHERE rental_id > 1007;
  DELETE FROM contact WHERE contact_id > 1007;
  DELETE FROM member WHERE member_id > 1007;
END;
/

-- part 1
-- Create the following account_creation package specification.
CREATE OR REPLACE
  PACKAGE account_creation IS

  FUNCTION get_system_user_id
  ( pv_system_user_name VARCHAR2 ) RETURN NUMBER IS
    lv_retval NUMBER := 0; -- Default value is 0.

    CURSOR find_system_user_id 
    ( cv_system_user_name VARCHAR2 ) IS
      SELECT system_user_id
      FROM system_user 
      WHERE system_user_name = pv_system_user_name;
    
    BEGIN
      FOR i IN find_system_user_id(pv_system_user_name) LOOP 
        lv_retval := i.system_user_id;
      END LOOP;
    RETURN lv_retval;
  END get_system_user_id;
  
  PROCEDURE insert_contact
  ( pv_first_name          VARCHAR2
  , pv_middle_name         VARCHAR2 := NULL
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
  , pv_user_id             NUMBER );

  PROCEDURE insert_contact
  ( pv_first_name          VARCHAR2
  , pv_middle_name         VARCHAR2 := NULL
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
  , pv_user_name           VARCHAR2 );
  
END account_creation;
/


-- part 2
CREATE OR REPLACE PACKAGE BODY account_creation IS

  FUNCTION get_system_user_id(pv_system_user_name VARCHAR2) RETURN NUMBER IS
    lv_retval NUMBER := 0;

    CURSOR find_system_user_id(cv_system_user_name VARCHAR2) IS
      SELECT system_user_id
      FROM system_user
      WHERE system_user_name = pv_system_user_name;

  BEGIN
    FOR i IN find_system_user_id(pv_system_user_name) LOOP
      lv_retval := i.system_user_id;
    END LOOP;

    RETURN lv_retval;
  END get_system_user_id;

  PROCEDURE insert_contact(
    pv_first_name         VARCHAR2,
    pv_middle_name        VARCHAR2 := NULL,
    pv_last_name          VARCHAR2,
    pv_contact_type       VARCHAR2,
    pv_account_number     VARCHAR2,
    pv_member_type        VARCHAR2,
    pv_credit_card_number VARCHAR2,
    pv_credit_card_type   VARCHAR2,
    pv_street_address     VARCHAR2,
    pv_city               VARCHAR2,
    pv_state_province     VARCHAR2,
    pv_postal_code        VARCHAR2,
    pv_address_type       VARCHAR2,
    pv_country_code       VARCHAR2,
    pv_area_code          VARCHAR2,
    pv_telephone_number   VARCHAR2,
    pv_telephone_type     VARCHAR2,
    pv_user_name          VARCHAR2
  ) IS
    v_user_id NUMBER;

    -- Function to get user_id based on user_name
    FUNCTION get_user_id_by_name(pv_user_name VARCHAR2) RETURN NUMBER IS
      lv_user_id NUMBER;
    BEGIN
      SELECT user_id
      INTO lv_user_id
      FROM users
      WHERE user_name = pv_user_name;

      RETURN lv_user_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    END get_user_id_by_name;

  BEGIN
    -- Get user_id from user_name
    v_user_id := get_user_id_by_name(pv_user_name);

    -- If user_id is not found, create a new user and get the generated user_id
    IF v_user_id IS NULL THEN
      -- Insert into users table
      INSERT INTO users (user_name) VALUES (pv_user_name) RETURNING user_id INTO v_user_id;
    END IF;

    -- Call the main procedure with user_id
    insert_contact(pv_first_name,
                  pv_middle_name,
                  pv_last_name,
                  pv_contact_type,
                  pv_account_number,
                  pv_member_type,
                  pv_credit_card_number,
                  pv_credit_card_type,
                  pv_street_address,
                  pv_city,
                  pv_state_province,
                  pv_postal_code,
                  pv_address_type,
                  pv_country_code,
                  pv_area_code,
                  pv_telephone_number,
                  pv_telephone_type,
                  v_user_id);
  END insert_contact;

  PROCEDURE insert_contact(
    pv_first_name          VARCHAR2,
    pv_middle_name         VARCHAR2 := NULL,
    pv_last_name           VARCHAR2,
    pv_contact_type        VARCHAR2,
    pv_account_number      VARCHAR2,
    pv_member_type         VARCHAR2,
    pv_credit_card_number  VARCHAR2,
    pv_credit_card_type    VARCHAR2,
    pv_street_address      VARCHAR2,
    pv_city                VARCHAR2,
    pv_state_province      VARCHAR2,
    pv_postal_code         VARCHAR2,
    pv_address_type        VARCHAR2,
    pv_country_code        VARCHAR2,
    pv_area_code           VARCHAR2,
    pv_telephone_number    VARCHAR2,
    pv_telephone_type      VARCHAR2,
    pv_user_id             NUMBER
  ) IS
  BEGIN
    -- Manage a single transaction across the specified tables using pv_user_id
    -- Perform DML operations on member, contact, address, street_address, and telephone tables
    -- Use the provided input parameters to populate the tables as needed
    -- Commit the transaction at the end
    NULL; -- Replace with your DML operations
    COMMIT;
  END insert_contact;

END account_creation;
/
