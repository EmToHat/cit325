-- ------------------------------------------------------------------
--  Program Name:   system_user.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  11-Oct-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ==================================================================
--  This creates the system_user table and system_user_s1 sequences.
-- ------------------------------------------------------------------
--    Create and assign bind variable for table name.
-- ==================================================================
SET SESSION "videodb.table_name" = 'system_user';
SET CLIENT_MIN_MESSAGES TO ERROR;

--  Verify table name.
SELECT current_setting('videodb.table_name');

-- ------------------------------------------------------------------
--  Conditionally drop table.
-- ------------------------------------------------------------------
DROP TABLE IF EXISTS system_user CASCADE;

-- ------------------------------------------------------------------
--  Create table.
-- -------------------------------------------------------------------
CREATE TABLE system_user
( system_user_id              SERIAL
, system_user_name            VARCHAR(20)  NOT NULL
, system_user_group_id        INTEGER      NOT NULL
, system_user_type            INTEGER      NOT NULL
, first_name                  VARCHAR(20)
, middle_name                 VARCHAR(20)
, last_name                   VARCHAR(20)
, created_by                  INTEGER      NOT NULL
, creation_date               TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, last_updated_by             INTEGER      NOT NULL
, last_update_date            TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, PRIMARY KEY (system_user_id)
, CONSTRAINT fk_system_user_1 FOREIGN KEY (created_by) REFERENCES system_user (system_user_id)
, CONSTRAINT fk_system_user_2 FOREIGN KEY (last_updated_by) REFERENCES system_user (system_user_id));

-- Alter the sequence by restarting it at 1001.
ALTER SEQUENCE system_user_system_user_id_seq RESTART WITH 1001;

-- Display the table organization.
SELECT   tc.table_catalog || '.' || tc.constraint_name AS constraint_name
,        tc.table_catalog || '.' || tc.table_name AS table_name
,        kcu.column_name
,        ccu.table_catalog || '.' || ccu.table_name AS foreign_table_name
,        ccu.column_name AS foreign_column_name
FROM     information_schema.table_constraints AS tc JOIN information_schema.key_column_usage AS kcu
ON       tc.constraint_name = kcu.constraint_name
AND      tc.table_schema = kcu.table_schema JOIN information_schema.constraint_column_usage AS ccu
ON       ccu.constraint_name = tc.constraint_name
AND      ccu.table_schema = tc.table_schema
WHERE    tc.constraint_type = 'FOREIGN KEY'
AND      tc.table_name = current_setting('videodb.table_name')
ORDER BY 1;

SELECT c1.table_name
,      c1.ordinal_position
,      c1.column_name
,      CASE
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NOT NULL THEN 'PRIMARY KEY'
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NULL THEN 'NOT NULL'
       END AS is_nullable
,      CASE
         WHEN data_type = 'character varying' THEN
	   data_type||'('||character_maximum_length||')'
         WHEN data_type = 'numeric' THEN
	   CASE
	     WHEN numeric_scale != 0 AND numeric_scale IS NOT NULL THEN
               data_type||'('||numeric_precision||','||numeric_scale||')'
	     ELSE
               data_type||'('||numeric_precision||')'
	     END
         ELSE
           data_type
        END AS data_type
FROM    information_schema.columns c1 LEFT JOIN
          (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id' column_name
           FROM   information_schema.columns) c2
ON       c1.column_name = c2.column_name
WHERE    c1.table_name = current_setting('videodb.table_name')
ORDER BY c1.ordinal_position;

-- Create unique index on the system user name.
CREATE UNIQUE INDEX uq_system_user_1
  ON system_user (system_user_name);

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Display table, column, and sequence names.
SELECT table_name
,      column_name
,      trim(regexp_matches(column_default,'''.*''')::text,'{''}') AS sequence_name
FROM   information_schema.columns c1
WHERE  table_name = current_setting('videodb.table_name')
AND    column_name =
 (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id'
  FROM   information_schema.columns c2
  WHERE  c1.table_name = c2.table_name);

-- ------------------------------------------------------------------
--  Program Name:   common_lookup.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  11-Oct-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ==================================================================
--  This creates the system_user table and system_user_s1 sequences.
-- ------------------------------------------------------------------
--    Create and assign bind variable for table name.
-- ==================================================================
SET SESSION "videodb.table_name" = 'common_lookup';
SET CLIENT_MIN_MESSAGES TO ERROR;

--  Verify table name.
SELECT current_setting('videodb.table_name');

-- ------------------------------------------------------------------
--  Conditionally drop table.
-- ------------------------------------------------------------------
DROP TABLE IF EXISTS common_lookup CASCADE;

-- ------------------------------------------------------------------
--  Create table.
-- -------------------------------------------------------------------
CREATE TABLE common_lookup
( common_lookup_id            SERIAL
, common_lookup_context       VARCHAR(30)  NOT NULL
, common_lookup_type          VARCHAR(30)  NOT NULL
, common_lookup_meaning       VARCHAR(30)  NOT NULL
, created_by                  INTEGER      NOT NULL
, creation_date               TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, last_updated_by             INTEGER      NOT NULL
, last_update_date            TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, PRIMARY KEY (common_lookup_id)
, CONSTRAINT fk_clookup_1    FOREIGN KEY (created_by) REFERENCES system_user (system_user_id)
, CONSTRAINT fk_clookup_2    FOREIGN KEY (last_updated_by) REFERENCES system_user (system_user_id));

-- Alter the sequence by restarting it at 1001.
ALTER SEQUENCE common_lookup_common_lookup_id_seq RESTART WITH 1001;

-- Display the table organization.
SELECT   tc.table_catalog || '.' || tc.constraint_name AS constraint_name
,        tc.table_catalog || '.' || tc.table_name AS table_name
,        kcu.column_name
,        ccu.table_catalog || '.' || ccu.table_name AS foreign_table_name
,        ccu.column_name AS foreign_column_name
FROM     information_schema.table_constraints AS tc JOIN information_schema.key_column_usage AS kcu
ON       tc.constraint_name = kcu.constraint_name
AND      tc.table_schema = kcu.table_schema JOIN information_schema.constraint_column_usage AS ccu
ON       ccu.constraint_name = tc.constraint_name
AND      ccu.table_schema = tc.table_schema
WHERE    tc.constraint_type = 'FOREIGN KEY'
AND      tc.table_name = current_setting('videodb.table_name')
ORDER BY 1;

-- Query table description.
SELECT c1.table_name
,      c1.ordinal_position
,      c1.column_name
,      CASE
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NOT NULL THEN 'PRIMARY KEY'
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NULL THEN 'NOT NULL'
       END AS is_nullable
,      CASE
         WHEN data_type = 'character varying' THEN
	   data_type||'('||character_maximum_length||')'
         WHEN data_type = 'numeric' THEN
	   CASE
	     WHEN numeric_scale != 0 AND numeric_scale IS NOT NULL THEN
               data_type||'('||numeric_precision||','||numeric_scale||')'
	     ELSE
               data_type||'('||numeric_precision||')'
	     END
         ELSE
           data_type
        END AS data_type
FROM    information_schema.columns c1 LEFT JOIN
          (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id' column_name
           FROM   information_schema.columns) c2
ON       c1.column_name = c2.column_name
WHERE    c1.table_name = current_setting('videodb.table_name')
ORDER BY c1.ordinal_position;

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Add a constraint to the system_user table dependent on common_lookup_id.
ALTER TABLE system_user
  ADD CONSTRAINT fk_system_user_3 FOREIGN KEY (system_user_group_id)
      REFERENCES common_lookup (common_lookup_id);

-- Add a constraint to the system_user table dependent on common_lookup_id.
ALTER TABLE system_user
  ADD CONSTRAINT fk_system_user_4 FOREIGN KEY (system_user_type)
      REFERENCES common_lookup (common_lookup_id);

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Drop unique index on the context name.
DROP INDEX IF EXISTS nq_common_lookup_n1;

-- Create unique index on the system user name.
CREATE INDEX nq_common_lookup_n1
  ON common_lookup (common_lookup_context);

-- Drop unique index on the context name.
DROP INDEX IF EXISTS uq_common_lookup_u1;

-- Create unique index on the system user name.
CREATE UNIQUE INDEX uq_common_lookup_u1
  ON common_lookup (common_lookup_context, common_lookup_type);

-- Display table indexes.
SELECT tablename
,      indexname
FROM   pg_indexes
WHERE  tablename = current_setting('videodb.table_name');

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Display table, column, and sequence names.
SELECT table_name
,      column_name
,      trim(regexp_matches(column_default,'''.*''')::text,'{''}') AS sequence_name
FROM   information_schema.columns c1
WHERE  table_name = current_setting('videodb.table_name')
AND    column_name =
 (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id'
  FROM   information_schema.columns c2
  WHERE  c1.table_name = c2.table_name);

-- ------------------------------------------------------------------
--  Program Name:   member.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  11-Oct-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ==================================================================
--  This creates the system_user table and system_user_s1 sequences.
-- ------------------------------------------------------------------
--    Create and assign bind variable for table name.
-- ==================================================================
SET SESSION "videodb.table_name" = 'member';
SET CLIENT_MIN_MESSAGES TO ERROR;

--  Verify table name.
SELECT current_setting('videodb.table_name');

-- ------------------------------------------------------------------
--  Conditionally drop table.
-- ------------------------------------------------------------------
DROP TABLE IF EXISTS member CASCADE;

-- ------------------------------------------------------------------
--  Create table.
-- -------------------------------------------------------------------
CREATE TABLE member
( member_id                   SERIAL
, member_type                 INTEGER
, account_number              VARCHAR(10)  NOT NULL
, credit_card_number          VARCHAR(19)  NOT NULL
, credit_card_type            INTEGER      NOT NULL
, created_by                  INTEGER      NOT NULL
, creation_date               TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, last_updated_by             INTEGER      NOT NULL
, last_update_date            TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, PRIMARY KEY (member_id)
, CONSTRAINT fk_member_1      FOREIGN KEY (member_type) REFERENCES common_lookup (common_lookup_id)
, CONSTRAINT fk_member_2      FOREIGN KEY (credit_card_type) REFERENCES common_lookup (common_lookup_id)
, CONSTRAINT fk_member_3      FOREIGN KEY (created_by) REFERENCES system_user (system_user_id)
, CONSTRAINT fk_member_4      FOREIGN KEY (last_updated_by) REFERENCES system_user (system_user_id));

-- Alter the sequence by restarting it at 1001.
ALTER SEQUENCE member_member_id_seq RESTART WITH 1001;

-- Display the table organization.
SELECT   tc.table_catalog || '.' || tc.constraint_name AS constraint_name
,        tc.table_catalog || '.' || tc.table_name AS table_name
,        kcu.column_name
,        ccu.table_catalog || '.' || ccu.table_name AS foreign_table_name
,        ccu.column_name AS foreign_column_name
FROM     information_schema.table_constraints AS tc JOIN information_schema.key_column_usage AS kcu
ON       tc.constraint_name = kcu.constraint_name
AND      tc.table_schema = kcu.table_schema JOIN information_schema.constraint_column_usage AS ccu
ON       ccu.constraint_name = tc.constraint_name
AND      ccu.table_schema = tc.table_schema
WHERE    tc.constraint_type = 'FOREIGN KEY'
AND      tc.table_name = current_setting('videodb.table_name')
ORDER BY 1;

SELECT c1.table_name
,      c1.ordinal_position
,      c1.column_name
,      CASE
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NOT NULL THEN 'PRIMARY KEY'
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NULL THEN 'NOT NULL'
       END AS is_nullable
,      CASE
         WHEN data_type = 'character varying' THEN
	   data_type||'('||character_maximum_length||')'
         WHEN data_type = 'numeric' THEN
	   CASE
	     WHEN numeric_scale != 0 AND numeric_scale IS NOT NULL THEN
               data_type||'('||numeric_precision||','||numeric_scale||')'
	     ELSE
               data_type||'('||numeric_precision||')'
	     END
         ELSE
           data_type
        END AS data_type
FROM    information_schema.columns c1 LEFT JOIN
          (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id' column_name
           FROM   information_schema.columns) c2
ON       c1.column_name = c2.column_name
WHERE    c1.table_name = current_setting('videodb.table_name')
ORDER BY c1.ordinal_position;

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Drop index on the context name.
DROP INDEX IF EXISTS nq_member_n1;

-- Create index on the system user name.
CREATE INDEX nq_member_n1
  ON member (credit_card_type);

-- Display table indexes.
SELECT tablename
,      indexname
FROM   pg_indexes
WHERE  tablename = current_setting('videodb.table_name');

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Display table, column, and sequence names.
SELECT table_name
,      column_name
,      trim(regexp_matches(column_default,'''.*''')::text,'{''}') AS sequence_name
FROM   information_schema.columns c1
WHERE  table_name = current_setting('videodb.table_name')
AND    column_name =
 (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id'
  FROM   information_schema.columns c2
  WHERE  c1.table_name = c2.table_name);

-- ------------------------------------------------------------------
--  Program Name:   contact.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  11-Oct-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ==================================================================
--  This creates the system_user table and system_user_s1 sequences.
-- ------------------------------------------------------------------
--    Create and assign bind variable for table name.
-- ==================================================================
SET SESSION "videodb.table_name" = 'contact';
SET CLIENT_MIN_MESSAGES TO ERROR;

--  Verify table name.
SELECT current_setting('videodb.table_name');

-- ------------------------------------------------------------------
--  Conditionally drop table.
-- ------------------------------------------------------------------
DROP TABLE IF EXISTS contact CASCADE;

-- ------------------------------------------------------------------
--  Create table.
-- -------------------------------------------------------------------
CREATE TABLE contact
( contact_id                  SERIAL
, member_id                   INTEGER      NOT NULL
, contact_type                INTEGER      NOT NULL
, first_name                  VARCHAR(20)  NOT NULL
, middle_name                 VARCHAR(20)
, last_name                   VARCHAR(20)  NOT NULL
, created_by                  INTEGER      NOT NULL
, creation_date               TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, last_updated_by             INTEGER      NOT NULL
, last_update_date            TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, PRIMARY KEY (contact_id)
, CONSTRAINT fk_contact_1     FOREIGN KEY (member_id) REFERENCES member (member_id)
, CONSTRAINT fk_contact_2     FOREIGN KEY (contact_type) REFERENCES common_lookup (common_lookup_id)
, CONSTRAINT fk_contact_3     FOREIGN KEY (created_by) REFERENCES system_user (system_user_id)
, CONSTRAINT fk_contact_4     FOREIGN KEY (last_updated_by) REFERENCES system_user (system_user_id));

-- Alter the sequence by restarting it at 1001.
ALTER SEQUENCE contact_contact_id_seq RESTART WITH 1001;

-- Display the table organization.
SELECT   tc.table_catalog || '.' || tc.constraint_name AS constraint_name
,        tc.table_catalog || '.' || tc.table_name AS table_name
,        kcu.column_name
,        ccu.table_catalog || '.' || ccu.table_name AS foreign_table_name
,        ccu.column_name AS foreign_column_name
FROM     information_schema.table_constraints AS tc JOIN information_schema.key_column_usage AS kcu
ON       tc.constraint_name = kcu.constraint_name
AND      tc.table_schema = kcu.table_schema JOIN information_schema.constraint_column_usage AS ccu
ON       ccu.constraint_name = tc.constraint_name
AND      ccu.table_schema = tc.table_schema
WHERE    tc.constraint_type = 'FOREIGN KEY'
AND      tc.table_name = current_setting('videodb.table_name')
ORDER BY 1;

SELECT c1.table_name
,      c1.ordinal_position
,      c1.column_name
,      CASE
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NOT NULL THEN 'PRIMARY KEY'
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NULL THEN 'NOT NULL'
       END AS is_nullable
,      CASE
         WHEN data_type = 'character varying' THEN
	   data_type||'('||character_maximum_length||')'
         WHEN data_type = 'numeric' THEN
	   CASE
	     WHEN numeric_scale != 0 AND numeric_scale IS NOT NULL THEN
               data_type||'('||numeric_precision||','||numeric_scale||')'
	     ELSE
               data_type||'('||numeric_precision||')'
	     END
         ELSE
           data_type
        END AS data_type
FROM    information_schema.columns c1 LEFT JOIN
          (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id' column_name
           FROM   information_schema.columns) c2
ON       c1.column_name = c2.column_name
WHERE    c1.table_name = current_setting('videodb.table_name')
ORDER BY c1.ordinal_position;

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Drop index on the context name.
DROP INDEX IF EXISTS nq_contact_n1;

-- Create index on the system user name.
CREATE INDEX nq_contact_n1
  ON contact (member_id);

-- Drop index on the context name.
DROP INDEX IF EXISTS nq_contact_n2;

-- Create index on the system user name.
CREATE INDEX nq_contact_n2
  ON contact (member_id);

-- Display table indexes.
SELECT tablename
,      indexname
FROM   pg_indexes
WHERE  tablename = current_setting('videodb.table_name');

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Display table, column, and sequence names.
SELECT table_name
,      column_name
,      trim(regexp_matches(column_default,'''.*''')::text,'{''}') AS sequence_name
FROM   information_schema.columns c1
WHERE  table_name = current_setting('videodb.table_name')
AND    column_name =
 (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id'
  FROM   information_schema.columns c2
  WHERE  c1.table_name = c2.table_name);

-- ------------------------------------------------------------------
--  Program Name:   address.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  11-Oct-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ==================================================================
--  This creates the system_user table and system_user_s1 sequences.
-- ------------------------------------------------------------------
--    Create and assign bind variable for table name.
-- ==================================================================
SET SESSION "videodb.table_name" = 'address';
SET CLIENT_MIN_MESSAGES TO ERROR;

--  Verify table name.
SELECT current_setting('videodb.table_name');

-- ------------------------------------------------------------------
--  Conditionally drop table.
-- ------------------------------------------------------------------
DROP TABLE IF EXISTS address CASCADE;

-- ------------------------------------------------------------------
--  Create table.
-- -------------------------------------------------------------------
CREATE TABLE address
( address_id                  SERIAL
, contact_id                  INTEGER      NOT NULL
, address_type                INTEGER      NOT NULL
, city                        VARCHAR(30)  NOT NULL
, state_province              VARCHAR(30)  NOT NULL
, postal_code                 VARCHAR(20)  NOT NULL
, created_by                  INTEGER      NOT NULL
, creation_date               TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, last_updated_by             INTEGER      NOT NULL
, last_update_date            TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, PRIMARY KEY (address_id)
, CONSTRAINT fk_address_1     FOREIGN KEY (contact_id) REFERENCES contact (contact_id)
, CONSTRAINT fk_address_2     FOREIGN KEY (address_type) REFERENCES common_lookup (common_lookup_id)
, CONSTRAINT fk_address_3     FOREIGN KEY (created_by) REFERENCES system_user (system_user_id)
, CONSTRAINT fk_address_4     FOREIGN KEY (last_updated_by) REFERENCES system_user (system_user_id));

-- Alter the sequence by restarting it at 1001.
ALTER SEQUENCE address_address_id_seq RESTART WITH 1001;

-- Display the table organization.
SELECT   tc.table_catalog || '.' || tc.constraint_name AS constraint_name
,        tc.table_catalog || '.' || tc.table_name AS table_name
,        kcu.column_name
,        ccu.table_catalog || '.' || ccu.table_name AS foreign_table_name
,        ccu.column_name AS foreign_column_name
FROM     information_schema.table_constraints AS tc JOIN information_schema.key_column_usage AS kcu
ON       tc.constraint_name = kcu.constraint_name
AND      tc.table_schema = kcu.table_schema JOIN information_schema.constraint_column_usage AS ccu
ON       ccu.constraint_name = tc.constraint_name
AND      ccu.table_schema = tc.table_schema
WHERE    tc.constraint_type = 'FOREIGN KEY'
AND      tc.table_name = current_setting('videodb.table_name')
ORDER BY 1;

SELECT c1.table_name
,      c1.ordinal_position
,      c1.column_name
,      CASE
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NOT NULL THEN 'PRIMARY KEY'
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NULL THEN 'NOT NULL'
       END AS is_nullable
,      CASE
         WHEN data_type = 'character varying' THEN
	   data_type||'('||character_maximum_length||')'
         WHEN data_type = 'numeric' THEN
	   CASE
	     WHEN numeric_scale != 0 AND numeric_scale IS NOT NULL THEN
               data_type||'('||numeric_precision||','||numeric_scale||')'
	     ELSE
               data_type||'('||numeric_precision||')'
	     END
         ELSE
           data_type
        END AS data_type
FROM    information_schema.columns c1 LEFT JOIN
          (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id' column_name
           FROM   information_schema.columns) c2
ON       c1.column_name = c2.column_name
WHERE    c1.table_name = current_setting('videodb.table_name')
ORDER BY c1.ordinal_position;

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Drop index on the contact_id.
DROP INDEX IF EXISTS nq_address_n1;

-- Create index on the contact_id.
CREATE INDEX nq_address_n1 ON address (contact_id);

-- Drop index on the address_type.
DROP INDEX IF EXISTS nq_address_n2;

-- Create index on the address type.
CREATE INDEX nq_address_n2 ON address (address_type);

-- Display table indexes.
SELECT tablename
,      indexname
FROM   pg_indexes
WHERE  tablename = current_setting('videodb.table_name');

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Display table, column, and sequence names.
SELECT table_name
,      column_name
,      trim(regexp_matches(column_default,'''.*''')::text,'{''}') AS sequence_name
FROM   information_schema.columns c1
WHERE  table_name = current_setting('videodb.table_name')
AND    column_name =
 (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id'
  FROM   information_schema.columns c2
  WHERE  c1.table_name = c2.table_name);

-- ------------------------------------------------------------------
--  Program Name:   street_address.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  11-Oct-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ==================================================================
--  This creates the system_user table and system_user_s1 sequences.
-- ------------------------------------------------------------------
--    Create and assign bind variable for table name.
-- ==================================================================
SET SESSION "videodb.table_name" = 'street_address';
SET CLIENT_MIN_MESSAGES TO ERROR;

--  Verify table name.
SELECT current_setting('videodb.table_name');

-- ------------------------------------------------------------------
--  Conditionally drop table.
-- ------------------------------------------------------------------
DROP TABLE IF EXISTS street_address CASCADE;

-- ------------------------------------------------------------------
--  Create table.
-- -------------------------------------------------------------------
CREATE TABLE street_address
( street_address_id           SERIAL
, address_id                  INTEGER      NOT NULL
, street_address              VARCHAR(30)  NOT NULL
, created_by                  INTEGER      NOT NULL
, creation_date               TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, last_updated_by             INTEGER      NOT NULL
, last_update_date            TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, PRIMARY KEY (street_address_id)
, CONSTRAINT fk_s_address_1   FOREIGN KEY (address_id) REFERENCES address (address_id)
, CONSTRAINT fk_s_address_3   FOREIGN KEY (created_by) REFERENCES system_user (system_user_id)
, CONSTRAINT fk_s_address_4   FOREIGN KEY (last_updated_by) REFERENCES system_user (system_user_id));

-- Alter the sequence by restarting it at 1001.
ALTER SEQUENCE street_address_street_address_id_seq RESTART WITH 1001;

-- Display the table organization.
SELECT   tc.table_catalog || '.' || tc.constraint_name AS constraint_name
,        tc.table_catalog || '.' || tc.table_name AS table_name
,        kcu.column_name
,        ccu.table_catalog || '.' || ccu.table_name AS foreign_table_name
,        ccu.column_name AS foreign_column_name
FROM     information_schema.table_constraints AS tc JOIN information_schema.key_column_usage AS kcu
ON       tc.constraint_name = kcu.constraint_name
AND      tc.table_schema = kcu.table_schema JOIN information_schema.constraint_column_usage AS ccu
ON       ccu.constraint_name = tc.constraint_name
AND      ccu.table_schema = tc.table_schema
WHERE    tc.constraint_type = 'FOREIGN KEY'
AND      tc.table_name = current_setting('videodb.table_name')
ORDER BY 1;

SELECT c1.table_name
,      c1.ordinal_position
,      c1.column_name
,      CASE
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NOT NULL THEN 'PRIMARY KEY'
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NULL THEN 'NOT NULL'
       END AS is_nullable
,      CASE
         WHEN data_type = 'character varying' THEN
	   data_type||'('||character_maximum_length||')'
         WHEN data_type = 'numeric' THEN
	   CASE
	     WHEN numeric_scale != 0 AND numeric_scale IS NOT NULL THEN
               data_type||'('||numeric_precision||','||numeric_scale||')'
	     ELSE
               data_type||'('||numeric_precision||')'
	     END
         ELSE
           data_type
        END AS data_type
FROM    information_schema.columns c1 LEFT JOIN
          (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id' column_name
           FROM   information_schema.columns) c2
ON       c1.column_name = c2.column_name
WHERE    c1.table_name = current_setting('videodb.table_name')
ORDER BY c1.ordinal_position;

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Drop index on the context name.
DROP INDEX IF EXISTS nq_contact_n1;

-- Create index on the system user name.
CREATE INDEX nq_contact_n1
  ON contact (member_id);

-- Drop index on the context name.
DROP INDEX IF EXISTS nq_contact_n2;

-- Create index on the system user name.
CREATE INDEX nq_contact_n2
  ON contact (member_id);

-- Display table indexes.
SELECT tablename
,      indexname
FROM   pg_indexes
WHERE  tablename = current_setting('videodb.table_name');

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Display table, column, and sequence names.
SELECT table_name
,      column_name
,      trim(regexp_matches(column_default,'''.*''')::text,'{''}') AS sequence_name
FROM   information_schema.columns c1
WHERE  table_name = current_setting('videodb.table_name')
AND    column_name =
 (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id'
  FROM   information_schema.columns c2
  WHERE  c1.table_name = c2.table_name);

-- ------------------------------------------------------------------
--  Program Name:   telephone.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  11-Oct-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ==================================================================
--  This creates the system_user table and system_user_s1 sequences.
-- ------------------------------------------------------------------
--    Create and assign bind variable for table name.
-- ==================================================================
SET SESSION "videodb.table_name" = 'telephone';
SET CLIENT_MIN_MESSAGES TO ERROR;

--  Verify table name.
SELECT current_setting('videodb.table_name');

-- ------------------------------------------------------------------
--  Conditionally drop table.
-- ------------------------------------------------------------------
DROP TABLE IF EXISTS telephone CASCADE;

-- ------------------------------------------------------------------
--  Create table.
-- -------------------------------------------------------------------
CREATE TABLE telephone
( telephone_id                SERIAL
, contact_id                  INTEGER      NOT NULL
, address_id                  INTEGER
, telephone_type              INTEGER      NOT NULL
, country_code                VARCHAR(3)   NOT NULL
, area_code                   VARCHAR(6)   NOT NULL
, telephone_number            VARCHAR(10)  NOT NULL
, created_by                  INTEGER      NOT NULL
, creation_date               TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, last_updated_by             INTEGER      NOT NULL
, last_update_date            TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, PRIMARY KEY (telephone_id)
, CONSTRAINT fk_telephone_1   FOREIGN KEY (contact_id) REFERENCES contact (contact_id)
, CONSTRAINT fk_telephone_2   FOREIGN KEY (telephone_type) REFERENCES common_lookup (common_lookup_id)
, CONSTRAINT fk_telephone_3   FOREIGN KEY (created_by) REFERENCES system_user (system_user_id)
, CONSTRAINT fk_telephone_4   FOREIGN KEY (last_updated_by) REFERENCES system_user (system_user_id));

-- Alter the sequence by restarting it at 1001.
ALTER SEQUENCE telephone_telephone_id_seq RESTART WITH 1001;

-- Display the table organization.
SELECT   tc.table_catalog || '.' || tc.constraint_name AS constraint_name
,        tc.table_catalog || '.' || tc.table_name AS table_name
,        kcu.column_name
,        ccu.table_catalog || '.' || ccu.table_name AS foreign_table_name
,        ccu.column_name AS foreign_column_name
FROM     information_schema.table_constraints AS tc JOIN information_schema.key_column_usage AS kcu
ON       tc.constraint_name = kcu.constraint_name
AND      tc.table_schema = kcu.table_schema JOIN information_schema.constraint_column_usage AS ccu
ON       ccu.constraint_name = tc.constraint_name
AND      ccu.table_schema = tc.table_schema
WHERE    tc.constraint_type = 'FOREIGN KEY'
AND      tc.table_name = current_setting('videodb.table_name')
ORDER BY 1;

SELECT c1.table_name
,      c1.ordinal_position
,      c1.column_name
,      CASE
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NOT NULL THEN 'PRIMARY KEY'
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NULL THEN 'NOT NULL'
       END AS is_nullable
,      CASE
         WHEN data_type = 'character varying' THEN
	   data_type||'('||character_maximum_length||')'
         WHEN data_type = 'numeric' THEN
	   CASE
	     WHEN numeric_scale != 0 AND numeric_scale IS NOT NULL THEN
               data_type||'('||numeric_precision||','||numeric_scale||')'
	     ELSE
               data_type||'('||numeric_precision||')'
	     END
         ELSE
           data_type
        END AS data_type
FROM    information_schema.columns c1 LEFT JOIN
          (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id' column_name
           FROM   information_schema.columns) c2
ON       c1.column_name = c2.column_name
WHERE    c1.table_name = current_setting('videodb.table_name')
ORDER BY c1.ordinal_position;

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Drop index on the contact_id.
DROP INDEX IF EXISTS nq_address_n1;

-- Create index on the contact_id.
CREATE INDEX nq_address_n1 ON address (contact_id);

-- Drop index on the address_type.
DROP INDEX IF EXISTS nq_address_n2;

-- Create index on the address type.
CREATE INDEX nq_address_n2 ON address (address_type);

-- Display table indexes.
SELECT tablename
,      indexname
FROM   pg_indexes
WHERE  tablename = current_setting('videodb.table_name');

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Display table, column, and sequence names.
SELECT table_name
,      column_name
,      trim(regexp_matches(column_default,'''.*''')::text,'{''}') AS sequence_name
FROM   information_schema.columns c1
WHERE  table_name = current_setting('videodb.table_name')
AND    column_name =
 (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id'
  FROM   information_schema.columns c2
  WHERE  c1.table_name = c2.table_name);

-- ------------------------------------------------------------------
--  Program Name:   rental.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  11-Oct-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ==================================================================
--  This creates the system_user table and system_user_s1 sequences.
-- ------------------------------------------------------------------
--    Create and assign bind variable for table name.
-- ==================================================================
SET SESSION "videodb.table_name" = 'rental';
SET CLIENT_MIN_MESSAGES TO ERROR;

--  Verify table name.
SELECT current_setting('videodb.table_name');

-- ------------------------------------------------------------------
--  Conditionally drop table.
-- ------------------------------------------------------------------
DROP TABLE IF EXISTS rental CASCADE;

-- ------------------------------------------------------------------
--  Create table.
-- -------------------------------------------------------------------
CREATE TABLE rental
( rental_id                   SERIAL
, customer_id                 INTEGER  NOT NULL
, check_out_date              DATE     NOT NULL
, return_date                 DATE     NOT NULL
, created_by                  INTEGER  NOT NULL
, creation_date               TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, last_updated_by             INTEGER  NOT NULL
, last_update_date            TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, PRIMARY KEY (rental_id)
, CONSTRAINT fk_rental_1      FOREIGN KEY (customer_id) REFERENCES contact (contact_id)
, CONSTRAINT fk_rental_2      FOREIGN KEY (created_by) REFERENCES system_user (system_user_id)
, CONSTRAINT fk_rental_3      FOREIGN KEY (last_updated_by) REFERENCES system_user (system_user_id));

-- Alter the sequence by restarting it at 1001.
ALTER SEQUENCE rental_rental_id_seq RESTART WITH 1001;

-- Display the table organization.
SELECT   tc.table_catalog || '.' || tc.constraint_name AS constraint_name
,        tc.table_catalog || '.' || tc.table_name AS table_name
,        kcu.column_name
,        ccu.table_catalog || '.' || ccu.table_name AS foreign_table_name
,        ccu.column_name AS foreign_column_name
FROM     information_schema.table_constraints AS tc JOIN information_schema.key_column_usage AS kcu
ON       tc.constraint_name = kcu.constraint_name
AND      tc.table_schema = kcu.table_schema JOIN information_schema.constraint_column_usage AS ccu
ON       ccu.constraint_name = tc.constraint_name
AND      ccu.table_schema = tc.table_schema
WHERE    tc.constraint_type = 'FOREIGN KEY'
AND      tc.table_name = current_setting('videodb.table_name')
ORDER BY 1;

SELECT c1.table_name
,      c1.ordinal_position
,      c1.column_name
,      CASE
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NOT NULL THEN 'PRIMARY KEY'
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NULL THEN 'NOT NULL'
       END AS is_nullable
,      CASE
         WHEN data_type = 'character varying' THEN
	   data_type||'('||character_maximum_length||')'
         WHEN data_type = 'numeric' THEN
	   CASE
	     WHEN numeric_scale != 0 AND numeric_scale IS NOT NULL THEN
               data_type||'('||numeric_precision||','||numeric_scale||')'
	     ELSE
               data_type||'('||numeric_precision||')'
	     END
         ELSE
           data_type
        END AS data_type
FROM    information_schema.columns c1 LEFT JOIN
          (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id' column_name
           FROM   information_schema.columns) c2
ON       c1.column_name = c2.column_name
WHERE    c1.table_name = current_setting('videodb.table_name')
ORDER BY c1.ordinal_position;

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Drop index on the contact_id.
DROP INDEX IF EXISTS nq_address_n1;

-- Create index on the contact_id.
CREATE INDEX nq_address_n1 ON address (contact_id);

-- Drop index on the address_type.
DROP INDEX IF EXISTS nq_address_n2;

-- Create index on the address type.
CREATE INDEX nq_address_n2 ON address (address_type);

-- Display table indexes.
SELECT tablename
,      indexname
FROM   pg_indexes
WHERE  tablename = current_setting('videodb.table_name');

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Display table, column, and sequence names.
SELECT table_name
,      column_name
,      trim(regexp_matches(column_default,'''.*''')::text,'{''}') AS sequence_name
FROM   information_schema.columns c1
WHERE  table_name = current_setting('videodb.table_name')
AND    column_name =
 (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id'
  FROM   information_schema.columns c2
  WHERE  c1.table_name = c2.table_name);

-- ------------------------------------------------------------------
--  Program Name:   item.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  11-Oct-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ==================================================================
--  This creates the system_user table and system_user_s1 sequences.
-- ------------------------------------------------------------------
--    Create and assign bind variable for table name.
-- ==================================================================
SET SESSION "videodb.table_name" = 'item';
SET CLIENT_MIN_MESSAGES TO ERROR;

--  Verify table name.
SELECT current_setting('videodb.table_name');

-- ------------------------------------------------------------------
--  Conditionally drop table.
-- ------------------------------------------------------------------
DROP TABLE IF EXISTS item CASCADE;

-- ------------------------------------------------------------------
--  Create table.
-- -------------------------------------------------------------------
CREATE TABLE item
( item_id                     SERIAL
, item_barcode                VARCHAR(14)  NOT NULL
, item_type                   INTEGER      NOT NULL
, item_title                  VARCHAR(60)  NOT NULL
, item_subtitle               VARCHAR(60)
, item_rating                 VARCHAR(8)   NOT NULL
, item_release_date           DATE         NOT NULL
, created_by                  INTEGER      NOT NULL
, creation_date               TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, last_updated_by             INTEGER      NOT NULL
, last_update_date            TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, PRIMARY KEY (item_id)
, CONSTRAINT fk_item_1        FOREIGN KEY (item_type) REFERENCES common_lookup (common_lookup_id)
, CONSTRAINT fk_item_2        FOREIGN KEY (created_by) REFERENCES system_user (system_user_id)
, CONSTRAINT fk_item_3        FOREIGN KEY (last_updated_by) REFERENCES system_user (system_user_id));

-- Alter the sequence by restarting it at 1001.
ALTER SEQUENCE item_item_id_seq RESTART WITH 1001;

-- Display the table organization.
SELECT   tc.table_catalog || '.' || tc.constraint_name AS constraint_name
,        tc.table_catalog || '.' || tc.table_name AS table_name
,        kcu.column_name
,        ccu.table_catalog || '.' || ccu.table_name AS foreign_table_name
,        ccu.column_name AS foreign_column_name
FROM     information_schema.table_constraints AS tc JOIN information_schema.key_column_usage AS kcu
ON       tc.constraint_name = kcu.constraint_name
AND      tc.table_schema = kcu.table_schema JOIN information_schema.constraint_column_usage AS ccu
ON       ccu.constraint_name = tc.constraint_name
AND      ccu.table_schema = tc.table_schema
WHERE    tc.constraint_type = 'FOREIGN KEY'
AND      tc.table_name = current_setting('videodb.table_name')
ORDER BY 1;

SELECT c1.table_name
,      c1.ordinal_position
,      c1.column_name
,      CASE
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NOT NULL THEN 'PRIMARY KEY'
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NULL THEN 'NOT NULL'
       END AS is_nullable
,      CASE
         WHEN data_type = 'character varying' THEN
	   data_type||'('||character_maximum_length||')'
         WHEN data_type = 'numeric' THEN
	   CASE
	     WHEN numeric_scale != 0 AND numeric_scale IS NOT NULL THEN
               data_type||'('||numeric_precision||','||numeric_scale||')'
	     ELSE
               data_type||'('||numeric_precision||')'
	     END
         ELSE
           data_type
        END AS data_type
FROM    information_schema.columns c1 LEFT JOIN
          (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id' column_name
           FROM   information_schema.columns) c2
ON       c1.column_name = c2.column_name
WHERE    c1.table_name = current_setting('videodb.table_name')
ORDER BY c1.ordinal_position;

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Drop index on the contact_id.
DROP INDEX IF EXISTS nq_address_n1;

-- Create index on the contact_id.
CREATE INDEX nq_address_n1 ON address (contact_id);

-- Drop index on the address_type.
DROP INDEX IF EXISTS nq_address_n2;

-- Create index on the address type.
CREATE INDEX nq_address_n2 ON address (address_type);

-- Display table indexes.
SELECT tablename
,      indexname
FROM   pg_indexes
WHERE  tablename = current_setting('videodb.table_name');

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Display table, column, and sequence names.
SELECT table_name
,      column_name
,      trim(regexp_matches(column_default,'''.*''')::text,'{''}') AS sequence_name
FROM   information_schema.columns c1
WHERE  table_name = current_setting('videodb.table_name')
AND    column_name =
 (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id'
  FROM   information_schema.columns c2
  WHERE  c1.table_name = c2.table_name);

-- ------------------------------------------------------------------
--  Program Name:   rental_item.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  11-Oct-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ==================================================================
--  This creates the system_user table and system_user_s1 sequences.
-- ------------------------------------------------------------------
--    Create and assign bind variable for table name.
-- ==================================================================
SET SESSION "videodb.table_name" = 'rental_item';
SET CLIENT_MIN_MESSAGES TO ERROR;

--  Verify table name.
SELECT current_setting('videodb.table_name');

-- ------------------------------------------------------------------
--  Conditionally drop table.
-- ------------------------------------------------------------------
DROP TABLE IF EXISTS rental_item CASCADE;

-- ------------------------------------------------------------------
--  Create table.
-- -------------------------------------------------------------------
CREATE TABLE rental_item
( rental_item_id              SERIAL
, rental_id                   INTEGER   NOT NULL
, item_id                     INTEGER   NOT NULL
, created_by                  INTEGER   NOT NULL
, creation_date               TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, last_updated_by             INTEGER   NOT NULL
, last_update_date            TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, CONSTRAINT pk_rental_item_1 PRIMARY KEY (rental_item_id)
, CONSTRAINT fk_rental_item_1 FOREIGN KEY (rental_id) REFERENCES rental (rental_id)
, CONSTRAINT fk_rental_item_2 FOREIGN KEY (item_id) REFERENCES item (item_id)
, CONSTRAINT fk_rental_item_3 FOREIGN KEY (created_by) REFERENCES system_user (system_user_id)
, CONSTRAINT fk_rental_item_4 FOREIGN KEY (last_updated_by) REFERENCES system_user (system_user_id));

-- Alter the sequence by restarting it at 1001.
ALTER SEQUENCE rental_item_rental_item_id_seq RESTART WITH 1001;

-- Display the table organization.
SELECT   tc.table_catalog || '.' || tc.constraint_name AS constraint_name
,        tc.table_catalog || '.' || tc.table_name AS table_name
,        kcu.column_name
,        ccu.table_catalog || '.' || ccu.table_name AS foreign_table_name
,        ccu.column_name AS foreign_column_name
FROM     information_schema.table_constraints AS tc JOIN information_schema.key_column_usage AS kcu
ON       tc.constraint_name = kcu.constraint_name
AND      tc.table_schema = kcu.table_schema JOIN information_schema.constraint_column_usage AS ccu
ON       ccu.constraint_name = tc.constraint_name
AND      ccu.table_schema = tc.table_schema
WHERE    tc.constraint_type = 'FOREIGN KEY'
AND      tc.table_name = current_setting('videodb.table_name')
ORDER BY 1;

SELECT c1.table_name
,      c1.ordinal_position
,      c1.column_name
,      CASE
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NOT NULL THEN 'PRIMARY KEY'
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NULL THEN 'NOT NULL'
       END AS is_nullable
,      CASE
         WHEN data_type = 'character varying' THEN
	   data_type||'('||character_maximum_length||')'
         WHEN data_type = 'numeric' THEN
	   CASE
	     WHEN numeric_scale != 0 AND numeric_scale IS NOT NULL THEN
               data_type||'('||numeric_precision||','||numeric_scale||')'
	     ELSE
               data_type||'('||numeric_precision||')'
	     END
         ELSE
           data_type
        END AS data_type
FROM    information_schema.columns c1 LEFT JOIN
          (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id' column_name
           FROM   information_schema.columns) c2
ON       c1.column_name = c2.column_name
WHERE    c1.table_name = current_setting('videodb.table_name')
ORDER BY c1.ordinal_position;

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Display table indexes.
SELECT tablename
,      indexname
FROM   pg_indexes
WHERE  tablename = current_setting('videodb.table_name');

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Display table, column, and sequence names.
SELECT table_name
,      column_name
,      trim(regexp_matches(column_default,'''.*''')::text,'{''}') AS sequence_name
FROM   information_schema.columns c1
WHERE  table_name = current_setting('videodb.table_name')
AND    column_name =
 (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id'
  FROM   information_schema.columns c2
  WHERE  c1.table_name = c2.table_name);

-- ------------------------------------------------------------------
--  Program Name:   preseed_store.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  09-Oct-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  21-Feb-2022    Modified to run from Windows OS.
-- ------------------------------------------------------------------
-- This creates tables, sequences, indexes, and constraints necessary
-- to begin lesson #3. Demonstrates proper process and syntax.
-- ------------------------------------------------------------------

-- --------------------------------------------------------
--  Step #1
--  -------
--  Disable foreign key constraints dependencies.
-- --------------------------------------------------------
ALTER TABLE system_user
  DROP CONSTRAINT fk_system_user_3;

ALTER TABLE system_user
  DROP CONSTRAINT fk_system_user_4;

-- --------------------------------------------------------
--  Step #2
--  -------
--  Alter the table to remove not null constraints.
-- --------------------------------------------------------
ALTER TABLE system_user
  ALTER COLUMN system_user_group_id DROP NOT NULL;

ALTER TABLE system_user
  ALTER COLUMN system_user_type DROP NOT NULL;

-- --------------------------------------------------------
--  Step #3
--  -------
--  Insert partial data set for preseeded system_user.
-- --------------------------------------------------------
INSERT INTO system_user
( system_user_id
, system_user_name
, system_user_group_id
, system_user_type
, created_by
, last_updated_by )
VALUES
( 1            -- system_user_id
,'SYSADMIN'    -- system_user_name
, null         -- system_user_group_id            
, null         -- system_user_type
, 1            -- created_by
, 1            -- last_updated_by
);

-- --------------------------------------------------------
--  Step #4
--  -------
--  Disable foreign key constraints dependencies.
-- --------------------------------------------------------
ALTER TABLE common_lookup
  DROP CONSTRAINT fk_clookup_1;

ALTER TABLE common_lookup
  DROP CONSTRAINT fk_clookup_2;

-- --------------------------------------------------------
--  Step #5
--  -------
--  Insert data set for preseeded common_lookup table.
-- --------------------------------------------------------
INSERT INTO common_lookup
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('SYSTEM_USER'                -- common_lookup_context
,'SYSTEM_ADMIN'               -- common_lookup_type
,'System Administrator'       -- common_lookup_meaning
, 1                           -- created_by
, 1                           -- last_updated_by
);

INSERT INTO common_lookup
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('SYSTEM_USER'                -- common_lookup_context
,'DBA'                        -- common_lookup_type
,'Database Administrator'     -- common_lookup_meaning
, 1                           -- created_by
, 1                           -- last_updated_by
);

INSERT INTO common_lookup
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, last_updated_by )
 VALUES
('SYSTEM_USER'                -- common_lookup_context
,'SYSTEM_GROUP'               -- common_lookup_type
,'System Group'              -- common_lookup_meaning
, 1                           -- created_by
, 1                           -- last_updated_by
);

INSERT INTO common_lookup
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('SYSTEM_USER'                -- common_lookup_context
,'COST_CENTER'                -- common_lookup_type
,'Cost Center'                -- common_lookup_meaning
, 1                           -- created_by
, 1                           -- last_updated_by
);

INSERT INTO common_lookup
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('SYSTEM_USER'                -- common_lookup_context
,'INDIVIDUAL'                 -- common_lookup_type
,'Individual'                 -- common_lookup_meaning
, 1                           -- created_by
, 1                           -- last_updated_by
);

INSERT INTO common_lookup
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('CONTACT'                    -- common_lookup_context
,'EMPLOYEE'                   -- common_lookup_type
,'Employee'                   -- common_lookup_meaning
, 1                           -- created_by
, 1                           -- last_updated_by
);

INSERT INTO common_lookup
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('CONTACT'                    -- common_lookup_context
,'CUSTOMER'                   -- common_lookup_type
,'Customer'                   -- common_lookup_meaning
, 1                           -- created_by
, 1                           -- last_updated_by
);

INSERT INTO common_lookup
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('MEMBER'                     -- common_lookup_context
,'INDIVIDUAL'                 -- common_lookup_type
,'Individual Membership'      -- common_lookup_meaning
, 1                           -- created_by
, 1                           -- last_updated_by
);

INSERT INTO common_lookup
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('MEMBER'                     -- common_lookup_context
,'GROUP'                      -- common_lookup_type
,'Group Membership'           -- common_lookup_meaning
, 1                           -- created_by
, 1                           -- last_updated_by
);

INSERT INTO common_lookup
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('MEMBER'                     -- common_lookup_context
,'DISCOVER_CARD'              -- common_lookup_type
,'Discover Card'              -- common_lookup_meaning
, 1                           -- created_by
, 1                           -- last_updated_by
);

INSERT INTO common_lookup
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('MEMBER'                     -- common_lookup_context
,'MASTER_CARD'                -- common_lookup_type
,'Master Card'                -- common_lookup_meaning
, 1                           -- created_by
, 1                           -- last_updated_by
);

INSERT INTO common_lookup
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('MEMBER'                     -- common_lookup_context
,'VISA_CARD'                  -- common_lookup_type
,'Visa Card'                  -- common_lookup_meaning
, 1                           -- created_by
, 1                           -- last_updated_by
);

INSERT INTO common_lookup
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('MULTIPLE'                   -- common_lookup_context
,'HOME'                       -- common_lookup_type
,'Home'                       -- common_lookup_meaning
, 1                           -- created_by
, 1                           -- last_updated_by
);

INSERT INTO common_lookup
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('MULTIPLE'                   -- common_lookup_context
,'WORK'                       -- common_lookup_type
,'Work'                       -- common_lookup_meaning
, 1                           -- created_by
, 1                           -- last_updated_by
);

INSERT INTO common_lookup
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('ITEM'                       -- common_lookup_context
,'DVD_FULL_SCREEN'            -- common_lookup_type
,'DVD: Full Screen'           -- common_lookup_meaning
, 1                           -- created_by
, 1                           -- last_updated_by
);

INSERT INTO common_lookup
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('ITEM'                       -- common_lookup_context
,'DVD_WIDE_SCREEN'            -- common_lookup_type
,'DVD: Wide Screen'           -- common_lookup_meaning
, 1                           -- created_by
, 1                           -- last_updated_by
);

INSERT INTO common_lookup
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('ITEM'                       -- common_lookup_context
,'NINTENDO_GAMECUBE'          -- common_lookup_type
,'Nintendo Gamecube'          -- common_lookup_meaning
, 1                           -- created_by
, 1                           -- last_updated_by
);

INSERT INTO common_lookup
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('ITEM'                       -- common_lookup_context
,'PLAYSTATION2'               -- common_lookup_type
,'Playstation2'               -- common_lookup_meaning
, 1                           -- created_by
, 1                           -- last_updated_by
);

INSERT INTO common_lookup
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('ITEM'                       -- common_lookup_context
,'XBOX'                       -- common_lookup_type
,'XBOX'                       -- common_lookup_meaning
, 1                           -- created_by
, 1                           -- last_updated_by
);

INSERT INTO common_lookup
( common_lookup_context
, common_lookup_type
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('ITEM'                       -- common_lookup_context
,'BLU-RAY'                    -- common_lookup_type
,'Blu-ray'                    -- common_lookup_meaning
, 1                           -- created_by
, 1                           -- last_updated_by
);

-- --------------------------------------------------------
--  Step #6
--  -------
--  Display the preseeded values in the common_lookup table.
-- --------------------------------------------------------
SELECT   common_lookup_id
,        common_lookup_context
,        common_lookup_type
FROM     common_lookup;

-- --------------------------------------------------------
--  Step #7
--  -------
--  Write two queries using the COMMON_LOOKUP table:
--  --------------------------------------------------
--   One finds the primary key values for the
--   SYSTEM_USER_GROUP_ID in the COMMON_LOOKUP table.
--   Another finds the primary key values for the 
--   SYSTEM_USER_TYPE in the COMMON_LOOKUP table.
--  --------------------------------------------------
--  Both queries use the COMMON_LOOKUP_CONTEXT and
--  COMMON_LOOKUP_TYPE columns.
-- --------------------------------------------------------
SELECT   common_lookup_id AS "system_user_type"
FROM     common_lookup
WHERE    common_lookup_context = 'SYSTEM_USER'
AND      common_lookup_type = 'SYSTEM_ADMIN';

SELECT   common_lookup_id AS "system_group_group_id"
FROM     common_lookup
WHERE    common_lookup_context = 'SYSTEM_USER'
AND      common_lookup_type = 'SYSTEM_GROUP';

-- --------------------------------------------------------
--  Step #8
--  -------
--  Update the SYSTEM_USER_GROUP_ID and SYSTEM_USER_TYPE
--  columns in the SYSTEM_USER table.
-- --------------------------------------------------------
UPDATE system_user
SET    system_user_group_id = 
         (SELECT   common_lookup_id
          FROM     common_lookup
          WHERE    common_lookup_context = 'SYSTEM_USER'
          AND      common_lookup_type = 'SYSTEM_ADMIN')
WHERE  system_user_id = 1;

-- Display results.
SELECT   system_user_id
,        system_user_name
,        system_user_group_id
,        system_user_type
FROM     system_user
WHERE    system_user_id = 1;

UPDATE system_user
SET    system_user_type = 
         (SELECT   common_lookup_id
          FROM     common_lookup
          WHERE    common_lookup_context = 'SYSTEM_USER'
          AND      common_lookup_type = 'SYSTEM_GROUP')
WHERE  system_user_id = 1;

-- Display results.
SELECT   system_user_id
,        system_user_name
,        system_user_group_id
,        system_user_type
FROM     system_user
WHERE    system_user_id = 1;

-- --------------------------------------------------------
--  Step #9
--  --------
--  Enable foreign key constraints dependencies.
-- --------------------------------------------------------
-- Enable fk_system_user_3 constraint.
ALTER TABLE system_user
  ADD CONSTRAINT fk_system_user_3 FOREIGN KEY (system_user_group_id)
      REFERENCES common_lookup (common_lookup_id);

-- Enable fk_system_user_4 constraint.
ALTER TABLE system_user
  ADD CONSTRAINT fk_system_user_4 FOREIGN KEY (system_user_type)
      REFERENCES common_lookup (common_lookup_id);

-- Enable fk_clookup_1 constraint.
ALTER TABLE common_lookup
  ADD CONSTRAINT fk_clookup_1 FOREIGN KEY (created_by) REFERENCES system_user (system_user_id);

ALTER TABLE common_lookup
  ADD CONSTRAINT fk_clookup_2 FOREIGN KEY (last_updated_by) REFERENCES system_user (system_user_id);

-- --------------------------------------------------------
--  Step #10
--  --------
--  Alter the table to add not null constraints.
-- --------------------------------------------------------
ALTER TABLE system_user
  ALTER COLUMN system_user_group_id SET NOT NULL;

ALTER TABLE system_user
  ALTER COLUMN system_user_type SET NOT NULL;

-- --------------------------------------------------------
--  Step #11
--  --------
--  Insert row in the system_user table with subqueries.
-- --------------------------------------------------------
INSERT INTO system_user
( system_user_name
, system_user_group_id
, system_user_type
, first_name
, middle_name
, last_name
, created_by
, last_updated_by )
VALUES
('DBA1'                                           -- system_user_name
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'SYSTEM_USER'
  AND      common_lookup_type = 'DBA')            -- system_user_group_id            
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'SYSTEM_USER'
  AND      common_lookup_type = 'SYSTEM_GROUP')   -- system_user_type
,'Phineas'
,'Taylor'
,'Barnum'
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

INSERT INTO system_user
( system_user_name
, system_user_group_id
, system_user_type
, first_name
, last_name
, created_by
, last_updated_by )
VALUES
('DBA2'                                           -- system_user_name
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'SYSTEM_USER'
  AND      common_lookup_type = 'DBA')            -- system_user_group_id            
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'SYSTEM_USER'
  AND      common_lookup_type = 'SYSTEM_GROUP')   -- system_user_type
,'Phileas'
,'Fogg'
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

-- --------------------------------------------------------
--  Step #12
--  --------
--  Display inserted rows from the system_user table.
-- --------------------------------------------------------
SELECT   system_user_id
,        system_user_group_id
,        system_user_type
,        system_user_name
,        last_name || ', ' || first_name
||       CASE
           WHEN middle_name IS NOT NULL THEN middle_name
	   ELSE ''
         END AS full_user_name
FROM     system_user;

-- ------------------------------------------------------------------
--  Program Name:   group_account1.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  12-Oct-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
-- This seeds data in the video store model.
-- ------------------------------------------------------------------
-- ------------------------------------------------------------------
--  This seeds rows in a dependency chain, including the following
--  tables:
--
--    1. MEMBER
--    2. CONTACT
--    3. ADDRESS
--    4. STREET_ADDRESS
--    5. TELEPHONE
--
--  It creates primary keys with the .NEXTVAL pseudo columns and
--  foreign keys with the .CURRVAL pseudo columns.
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
--  Insert record set #1, with one entry in the member table and
--  two entries in contact table.
-- ------------------------------------------------------------------
INSERT INTO member
( member_type
, account_number
, credit_card_number
, credit_card_type
, created_by
, last_updated_by )
VALUES
((SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'MEMBER'
  AND      common_lookup_type = 'GROUP')          -- member_type
,'B293-71445'                                     -- account_number
,'1111-2222-3333-4444'                            -- credit_card_number
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'MEMBER'
  AND      common_lookup_type = 'DISCOVER_CARD')  -- member_type
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

-- ------------------------------------------------------------------
--  Insert first contact in a group account user.
-- ------------------------------------------------------------------
INSERT INTO contact
( member_id
, contact_type
, first_name
, last_name
, created_by
, last_updated_by )
VALUES
( CURRVAL('member_member_id_seq') 
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'CONTACT'
  AND      common_lookup_type = 'CUSTOMER')       -- contact_type
,'Randi'                                          -- first_name
,'Winn'                                           -- last_name
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

INSERT INTO address
( contact_id
, address_type
, city
, state_province
, postal_code
, created_by
, last_updated_by )
VALUES
( CURRVAL('contact_contact_id_seq')
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_type = 'HOME')           -- address_type
,'San Jose'                                       -- city
,'CA'                                             -- state_province
,'95192'                                          -- postal_code
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

INSERT INTO street_address
( address_id
, street_address
, created_by
, last_updated_by )
 VALUES
( CURRVAL('address_address_id_seq')
,'10 El Camino Real'                              -- street_address
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

INSERT INTO telephone
( contact_id
, address_id
, telephone_type
, country_code
, area_code
, telephone_number
, created_by
, last_updated_by )
 VALUES
( CURRVAL('contact_contact_id_seq')
, CURRVAL('address_address_id_seq')
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'MULTIPLE'
  AND      common_lookup_type = 'HOME')           -- telephone_type
,'001'                                            -- country_code
,'408'                                            -- area_code
,'111-1111'                                       -- telephone_number
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

-- ------------------------------------------------------------------
--  Insert second contact in a group account user.
-- ------------------------------------------------------------------
INSERT INTO contact
( member_id
, contact_type
, first_name
, last_name
, created_by
, last_updated_by )
VALUES
( CURRVAL('member_member_id_seq')
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'CONTACT'
  AND      common_lookup_type = 'CUSTOMER')       -- contact_type
,'Brian'                                          -- first_name
,'Winn'                                           -- last_name
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

INSERT INTO address
( contact_id
, address_type
, city
, state_province
, postal_code
, created_by
, last_updated_by )
VALUES
( CURRVAL('contact_contact_id_seq')
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_type = 'HOME')           -- address_type
,'San Jose'                                       -- city
,'CA'                                             -- state_province
,'95192'                                          -- postal_code
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

INSERT INTO street_address
( address_id
, street_address
, created_by
, last_updated_by )
 VALUES
( CURRVAL('address_address_id_seq')
,'10 El Camino Real'                              -- street_address
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

INSERT INTO telephone
( contact_id
, address_id
, telephone_type
, country_code
, area_code
, telephone_number
, created_by
, last_updated_by )
 VALUES
( CURRVAL('contact_contact_id_seq')
, CURRVAL('address_address_id_seq')
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'MULTIPLE'
  AND      common_lookup_type = 'HOME')           -- telephone_type
,'001'                                            -- country_code
,'408'                                            -- area_code
,'111-1111'                                       -- telephone_number
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

SELECT   m.account_number
,        c.last_name || ', ' || c.first_name
||       CASE
           WHEN c.middle_name IS NOT NULL THEN ' ' || c.middle_name
	   ELSE ''
         END AS full_name
,        a.city
,        a.state_province
,        t.country_code || '-(' || t.area_code || ') ' || t.telephone_number AS telephone
FROM     member m INNER JOIN contact c ON m.member_id = c.member_id INNER JOIN
         address a ON c.contact_id = a.contact_id INNER JOIN
         street_address sa ON a.address_id = sa.address_id INNER JOIN
         telephone t ON c.contact_id = t.contact_id AND a.address_id = t.address_id
WHERE    c.last_name = 'Winn';

-- ------------------------------------------------------------------
--  Program Name:   group_account2.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  12-Oct-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
-- This seeds data in the video store model.
-- ------------------------------------------------------------------
-- ------------------------------------------------------------------
--  This seeds rows in a dependency chain, including the following
--  tables:
--
--    1. MEMBER
--    2. CONTACT
--    3. ADDRESS
--    4. STREET_ADDRESS
--    5. TELEPHONE
--
--  It creates primary keys with the .NEXTVAL pseudo columns and
--  foreign keys with the .CURRVAL pseudo columns.
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
--  Insert record set #2, with one entry in the member table and
--  two entries in contact table.
-- ------------------------------------------------------------------
SELECT CURRVAL('member_member_id_seq');
INSERT INTO member
( member_type
, account_number
, credit_card_number
, credit_card_type
, created_by
, last_updated_by )
VALUES
((SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'MEMBER'
  AND      common_lookup_type = 'DISCOVER_CARD')  -- member_type
,'B293-71446'                                     -- account_number
,'2222-3333-4444-5555'                            -- credit_card_number
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'MEMBER'
  AND      common_lookup_type = 'DISCOVER_CARD')  -- credit_card_type
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

-- ------------------------------------------------------------------
--  Insert first contact in a group account user.
-- ------------------------------------------------------------------
INSERT INTO contact
( member_id
, contact_type
, first_name
, last_name
, created_by
, last_updated_by )
VALUES
( CURRVAL('member_member_id_seq')                 -- member_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'CONTACT'
  AND      common_lookup_type = 'CUSTOMER')       -- contact_type
,'Oscar'                                          -- first_name
,'Vizquel'                                        -- last_name
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

INSERT INTO address
( contact_id
, address_type
, city
, state_province
, postal_code
, created_by
, last_updated_by )
VALUES
( CURRVAL('contact_contact_id_seq')               -- contact_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_type = 'HOME')           -- address_type
,'San Jose'                                       -- city
,'CA'                                             -- state_province
,'95192'                                          -- postal_code
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

INSERT INTO street_address
( address_id
, street_address
, created_by
, last_updated_by )
 VALUES
( CURRVAL('address_address_id_seq')               -- address_id
,'12 El Camino Real'                              -- street_address
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

INSERT INTO telephone
( contact_id
, address_id
, telephone_type
, country_code
, area_code
, telephone_number
, created_by
, last_updated_by )
 VALUES
( CURRVAL('contact_contact_id_seq')               -- contact_id
, CURRVAL('address_address_id_seq')               -- address_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'MULTIPLE'
  AND      common_lookup_type = 'HOME')           -- telephone_type
,'USA'                                            -- country_code
,'408'                                            -- area_code
,'222-2222'                                       -- telephone_number
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

-- ------------------------------------------------------------------
--  Insert second contact in a group account user.
-- ------------------------------------------------------------------
INSERT INTO contact
( member_id
, contact_type
, first_name
, last_name
, created_by
, last_updated_by )
VALUES
( CURRVAL('member_member_id_seq')                 -- member_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'CONTACT'
  AND      common_lookup_type = 'CUSTOMER')       -- contact_type
,'Doreen'                                         -- first_name
,'Vizquel'                                        -- last_name
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

INSERT INTO address
( contact_id
, address_type
, city
, state_province
, postal_code
, created_by
, last_updated_by )
VALUES
( CURRVAL('contact_contact_id_seq')               -- contact_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_type = 'HOME')           -- address_type
,'San Jose'                                       -- city
,'CA'                                             -- state_province
,'95192'                                          -- postal_code
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

INSERT INTO street_address
( address_id
, street_address
, created_by
, last_updated_by )
VALUES
( CURRVAL('address_address_id_seq')               -- address_id
,'12 El Camino Real'                              -- street_address
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

INSERT INTO telephone
( contact_id
, address_id
, telephone_type
, country_code
, area_code
, telephone_number
, created_by
, last_updated_by )
VALUES
( CURRVAL('contact_contact_id_seq')               -- contact_id
, CURRVAL('address_address_id_seq')               -- address_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'MULTIPLE'
  AND      common_lookup_type = 'HOME')           -- telephone_type
,'USA'                                            -- country_code
,'408'                                            -- area_code
,'222-2222'                                       -- telephone_number
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

SELECT   m.account_number
,        c.last_name || ', ' || c.first_name
||       CASE
           WHEN c.middle_name IS NOT NULL THEN ' ' || c.middle_name
         END AS full_name
,        a.city
,        a.state_province
,        t.country_code || '-(' || t.area_code || ') ' || t.telephone_number AS telephone
FROM     member m INNER JOIN contact c ON m.member_id = c.member_id INNER JOIN
         address a ON c.contact_id = a.contact_id INNER JOIN
         street_address sa ON a.address_id = sa.address_id INNER JOIN
         telephone t ON c.contact_id = t.contact_id AND a.address_id = t.address_id
WHERE    c.last_name = 'Vizquel';

-- ------------------------------------------------------------------
--  Program Name:   group_account3.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  12-Oct-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
-- This seeds data in the video store model.
-- ------------------------------------------------------------------
-- ------------------------------------------------------------------
--  This seeds rows in a dependency chain, including the following
--  tables:
--
--    1. MEMBER
--    2. CONTACT
--    3. ADDRESS
--    4. STREET_ADDRESS
--    5. TELEPHONE
--
--  It creates primary keys with the .NEXTVAL pseudo columns and
--  foreign keys with the .CURRVAL pseudo columns.
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
--  Insert record set #3, with one entry in the member table and
--  two entries in contact table.
-- ------------------------------------------------------------------
INSERT INTO member
( member_type
, account_number
, credit_card_number
, credit_card_type
, created_by
, last_updated_by )
VALUES
((SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'MEMBER'
  AND      common_lookup_type = 'DISCOVER_CARD')  -- member_type
,'B293-71447'                                     -- account_number
,'3333-4444-5555-6666'                            -- credit_card_number
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'MEMBER'
  AND      common_lookup_type = 'DISCOVER_CARD')  -- credit_card_type
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

-- ------------------------------------------------------------------
--  Insert first contact in a group account user.
-- ------------------------------------------------------------------
INSERT INTO contact
( member_id
, contact_type
, first_name
, last_name
, created_by
, last_updated_by )
VALUES
( CURRVAL('member_member_id_seq')                 -- member_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'CONTACT'
  AND      common_lookup_type = 'CUSTOMER')       -- contact_type
,'Meaghan'                                        -- first_name
,'Sweeney'                                        -- last_name
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

INSERT INTO address
( contact_id
, address_type
, city
, state_province
, postal_code
, created_by
, last_updated_by )
VALUES
( CURRVAL('contact_contact_id_seq')               -- contact_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_type = 'HOME')           -- address_type
,'San Jose'                                       -- city
,'CA'                                             -- state_province
,'95192'                                          -- postal_code
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

INSERT INTO street_address
( address_id
, street_address
, created_by
, last_updated_by )
 VALUES
( CURRVAL('address_address_id_seq')               -- address_id
,'14 El Camino Real'                              -- street_address
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

INSERT INTO telephone
( contact_id
, address_id
, telephone_type
, country_code
, area_code
, telephone_number
, created_by
, last_updated_by )
 VALUES
( CURRVAL('contact_contact_id_seq')               -- address_id
, CURRVAL('address_address_id_seq')               -- contact_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'MULTIPLE'
  AND      common_lookup_type = 'HOME')           -- telephone_type
,'USA'                                            -- country_code
,'408'                                            -- area_code
,'333-3333'                                       -- telephone_number
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

-- ------------------------------------------------------------------
--  Insert second contact in a group account user.
-- ------------------------------------------------------------------
INSERT INTO contact
( member_id
, contact_type
, first_name
, last_name
, created_by
, last_updated_by )
VALUES
( CURRVAL('member_member_id_seq')                 -- member_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'CONTACT'
  AND      common_lookup_type = 'CUSTOMER')       -- contact_type
,'Matthew'                                         -- first_name
,'Sweeney'                                        -- last_name
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

INSERT INTO address
( contact_id
, address_type
, city
, state_province
, postal_code
, created_by
, last_updated_by )
VALUES
( CURRVAL('contact_contact_id_seq')               -- contact_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_type = 'HOME')           -- address_type
,'San Jose'                                       -- city
,'CA'                                             -- state_province
,'95192'                                          -- postal_code
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

INSERT INTO street_address
( address_id
, street_address
, created_by
, last_updated_by )
VALUES
( CURRVAL('address_address_id_seq')               -- address_id
,'14 El Camino Real'                              -- street_address
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

INSERT INTO telephone
( contact_id
, address_id
, telephone_type
, country_code
, area_code
, telephone_number
, created_by
, last_updated_by )
 VALUES
( CURRVAL('contact_contact_id_seq')               -- address_id
, CURRVAL('address_address_id_seq')               -- contact_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'MULTIPLE'
  AND      common_lookup_type = 'HOME')           -- telephone_type
,'USA'                                            -- country_code
,'408'                                            -- area_code
,'333-3333'                                       -- telephone_number
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

-- ------------------------------------------------------------------
--  Insert third contact in a group account user.
-- ------------------------------------------------------------------
INSERT INTO contact
( member_id
, contact_type
, first_name
, middle_name
, last_name
, created_by
, last_updated_by )
VALUES
( CURRVAL('member_member_id_seq')                 -- member_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'CONTACT'
  AND      common_lookup_type = 'CUSTOMER')       -- contact_type
,'Ian'                                            -- first_name
,'M'                                              -- middle_name
,'Sweeney'                                        -- last_name
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);


INSERT INTO address
( contact_id
, address_type
, city
, state_province
, postal_code
, created_by
, last_updated_by )
VALUES
( CURRVAL('contact_contact_id_seq')               -- contact_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_type = 'HOME')           -- address_type
,'San Jose'                                       -- city
,'CA'                                             -- state_province
,'95192'                                          -- postal_code
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

INSERT INTO street_address
( address_id
, street_address
, created_by
, last_updated_by )
VALUES
( CURRVAL('address_address_id_seq')               -- address_id
,'14 El Camino Real'                              -- street_address
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

INSERT INTO telephone
( contact_id
, address_id
, telephone_type
, country_code
, area_code
, telephone_number
, created_by
, last_updated_by )
 VALUES
( CURRVAL('contact_contact_id_seq')               -- contact_id
, CURRVAL('address_address_id_seq')               -- address_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'MULTIPLE'
  AND      common_lookup_type = 'HOME')           -- telephone_type
,'USA'                                            -- country_code
,'408'                                            -- area_code
,'333-3333'                                       -- telephone_number
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

SELECT   m.account_number
,        c.last_name || ', ' || c.first_name
||       CASE
           WHEN c.middle_name IS NOT NULL THEN ' ' || c.middle_name
	   ELSE ''
         END AS full_name
,        a.city
,        a.state_province
,        t.country_code || '-(' || t.area_code || ') ' || t.telephone_number AS telephone
FROM     member m INNER JOIN contact c ON m.member_id = c.member_id INNER JOIN
         address a ON c.contact_id = a.contact_id INNER JOIN
         street_address sa ON a.address_id = sa.address_id INNER JOIN
         telephone t ON c.contact_id = t.contact_id AND a.address_id = t.address_id
WHERE    c.last_name = 'Sweeney';

-- ------------------------------------------------------------------
--  Program Name:   item_inserts.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  12-Oct-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------

-- ------------------------------------------------------------------
--  This seeds rows in a item table.
-- ------------------------------------------------------------------
--  - Insert 21 rows in the ITEM table.
-- ------------------------------------------------------------------

INSERT INTO item
( item_barcode
, item_type
, item_title
, item_subtitle
, item_rating
, item_release_date
, created_by
, last_updated_by )
VALUES
('9736-05640-4'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'DVD_WIDE_SCREEN')
,'The Hunt for Red October'
,'Special Collector''s Edition'
,'PG'
,'02-MAR-90'
, 1001
, 1001 );

INSERT INTO item 
( item_barcode
, item_type
, item_title
, item_subtitle
, item_rating
, item_release_date
, created_by
, last_updated_by )
VALUES
('24543-02392'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'DVD_WIDE_SCREEN')
,'Star Wars I'
,'Phantom Menace'
,'PG'
,'04-MAY-99'
, 1001
, 1001);

INSERT INTO item 
( item_barcode
, item_type
, item_title
, item_subtitle
, item_rating
, item_release_date
, created_by
, last_updated_by )
VALUES
('24543-5615'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'DVD_FULL_SCREEN')
,'Star Wars II'
,'Attack of the Clones'
,'PG'
,'16-MAY-02'
, 1001
, 1001);

INSERT INTO item 
( item_barcode
, item_type
, item_title
, item_subtitle
, item_rating
, item_release_date
, created_by
, last_updated_by )
VALUES
('24543-05539'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'DVD_WIDE_SCREEN')
,'Star Wars II'
,'Attack of the Clones'
,'PG'
,'16-MAY-02'
, 1001
, 1001);

INSERT INTO item
( item_barcode
, item_type
, item_title
, item_subtitle
, item_rating
, item_release_date
, created_by
, last_updated_by )
VALUES
('24543-20309'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'DVD_WIDE_SCREEN')
,'Star Wars III'
,'Revenge of the Sith'
,'PG13'
,'19-MAY-05'
, 1001
, 1001);

INSERT INTO item
( item_barcode
, item_type
, item_title
, item_subtitle
, item_rating
, item_release_date
, created_by
, last_updated_by )
VALUES
('86936-70380'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'DVD_WIDE_SCREEN')
,'The Chronicles of Narnia'
,'The Lion, the Witch and the Wardrobe','PG'
,'16-MAY-02'
, 1001
, 1001);

INSERT INTO item
( item_barcode
, item_type
, item_title
, item_subtitle
, item_rating
, item_release_date
, created_by
, last_updated_by )
VALUES
('91493-06475'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'XBOX')
,'RoboCop'
,''
,'Mature'
,'24-JUL-03'
, 1001
, 1001);

INSERT INTO item
( item_barcode
, item_type
, item_title
, item_subtitle
, item_rating
, item_release_date
, created_by
, last_updated_by )
VALUES
('93155-11810'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'XBOX')
,'Pirates of the Caribbean'
,''
,'Teen'
,'30-JUN-03'
, 1001
, 1001);

INSERT INTO item
( item_barcode
, item_type
, item_title
, item_subtitle
, item_rating
, item_release_date
, created_by
, last_updated_by )
VALUES
('12725-00173'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'XBOX')
,'The Chronicles of Narnia'
,'The Lion, the Witch and the Wardrobe'
,'Everyone'
,'30-JUN-03'
, 1001
, 1001);

INSERT INTO item
( item_barcode
, item_type
, item_title
, item_subtitle
, item_rating
, item_release_date
, created_by
, last_updated_by )
VALUES
('45496-96128'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'NINTENDO_GAMECUBE')
,'MarioKart'
,'Double Dash'
,'Everyone'
,'17-NOV-03'
, 1001
, 1001);

INSERT INTO item
( item_barcode
, item_type
, item_title
, item_subtitle
, item_rating
, item_release_date
, created_by
, last_updated_by )
VALUES
('08888-32214'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'PLAYSTATION2')
,'Splinter Cell'
,'Chaos Theory'
,'Teen'
,'08-APR-03'
, 1001
, 1001);

INSERT INTO item
( item_barcode
, item_type
, item_title
, item_subtitle
, item_rating
, item_release_date
, created_by
, last_updated_by )
VALUES
('14633-14821'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'PLAYSTATION2')
,'Need for Speed'
,'Most Wanted'
,'Everyone'
,'15-NOV-04'
, 1001
, 1001);

INSERT INTO item
( item_barcode
, item_type
, item_title
, item_subtitle
, item_rating
, item_release_date
, created_by
, last_updated_by )
VALUES
('10425-29944'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'XBOX')
,'The DaVinci Code'
,''
,'Teen'
,'19-MAY-06'
, 1001
, 1001);

INSERT INTO item
( item_barcode
, item_type
, item_title
, item_subtitle
, item_rating
, item_release_date
, created_by
, last_updated_by )
VALUES
('52919-52057'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'XBOX')
,'Cars'
,''
,'Everyone'
,'28-APR-06'
, 1001
, 1001);

INSERT INTO item
( item_barcode
, item_type
, item_title
, item_subtitle
, item_rating
, item_release_date
, created_by
, last_updated_by )
VALUES
('9689-80547-3'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'BLU-RAY')
,'Beau Geste'
,''
,'PG'
,'01-MAR-92'
, 1001
, 1001);

INSERT INTO item
( item_barcode
, item_type
, item_title
, item_subtitle
, item_rating
, item_release_date
, created_by
, last_updated_by )
VALUES
('53939-64103'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'BLU-RAY')
,'I Remember Mama'
,''
,'NR'
,'05-JAN-98'
, 1001
, 1001);

INSERT INTO item
( item_barcode
, item_type
, item_title
, item_subtitle
, item_rating
, item_release_date
, created_by
, last_updated_by )
VALUES
('24543-01292'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'BLU-RAY')
,'Tora! Tora! Tora!'
,'The Attack on Pearl Harbor'
,'G'
,'02-NOV-99'
, 1001
, 1001);

INSERT INTO item
( item_barcode
, item_type
, item_title
, item_subtitle
, item_rating
, item_release_date
, created_by
, last_updated_by )
VALUES
('43396-60047'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'BLU-RAY')
,'A Man for All Seasons'
,''
,'G'
,'28-JUN-94'
, 1001
, 1001);

INSERT INTO item
( item_barcode
, item_type
, item_title
, item_subtitle
, item_rating
, item_release_date
, created_by
, last_updated_by )
VALUES
('43396-70603'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'BLU-RAY')
,'Hook'
,''
,'PG'
,'11-DEC-91'
, 1001
, 1001);

INSERT INTO item
( item_barcode
, item_type
, item_title
, item_subtitle
, item_rating
, item_release_date
, created_by
, last_updated_by )
VALUES
('85391-13213'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'BLU-RAY')
,'Around the World in 80 Days'
,''
,'G'
,'04-DEC-92'
, 1001
, 1001);

INSERT INTO item
( item_barcode
, item_type
, item_title
, item_subtitle
, item_rating
, item_release_date
, created_by
, last_updated_by )
VALUES
('85391-10843'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'BLU-RAY')
,'Camelot'
,''
,'G'
,'15-MAY-98'
, 1001
, 1001);

-- ------------------------------------------------------------------
--  Display the 21 inserts into the item table.
-- ------------------------------------------------------------------
SELECT   i.item_id
,        cl.common_lookup_meaning
,        i.item_title
,        i.item_release_date
FROM     item i INNER JOIN common_lookup cl ON i.item_type = cl.common_lookup_id;

-- ------------------------------------------------------------------
--  Program Name:   create_insert_contacts.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  12-Oct-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
--  This automates creating accounts.
-- ------------------------------------------------------------------
-- ------------------------------------------------------------------
--  Automates inserts of member accounts for individual accounts. 
-- ------------------------------------------------------------------

-- Transaction Management Example.
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

-- Transaction Management Example.
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
, IN pv_created_by          INTEGER = 1001
, IN pv_last_updated_by     INTEGER = 1001 ) AS
$$
DECLARE
  /* Declare local variable. */
  lv_middle_name  VARCHAR(20);

  /* Declare error handling variables. */
  err_num  TEXT;
  err_msg  INTEGER;
BEGIN
  /* Assing a null value to an empty string. */ 
  IF pv_middle_name IS NULL THEN
    lv_middle_name = '';
  END IF;

  /* Insert into the member table. */
  INSERT INTO member
  ( member_type
  , account_number
  , credit_card_number
  , credit_card_type
  , created_by
  , last_updated_by )
  VALUES
  ((SELECT   common_lookup_id
    FROM     common_lookup
    WHERE    common_lookup_context = 'MEMBER'
    AND      common_lookup_type = pv_member_type)
  , pv_account_number
  , pv_credit_card_number
  ,(SELECT   common_lookup_id
    FROM     common_lookup
    WHERE    common_lookup_context = 'MEMBER'
    AND      common_lookup_type = pv_credit_card_type)
  , pv_created_by
  , pv_last_updated_by );

  /* Insert into the contact table. */
  INSERT INTO contact
  ( member_id
  , contact_type
  , first_name
  , middle_name
  , last_name
  , created_by
  , last_updated_by )
  VALUES
  ( CURRVAL('member_member_id_seq')
  ,(SELECT   common_lookup_id
    FROM     common_lookup
    WHERE    common_lookup_context = 'CONTACT'
    AND      common_lookup_type = pv_contact_type)
  , pv_first_name
  , pv_middle_name
  , pv_last_name
  , pv_created_by
  , pv_last_updated_by );

  /* Insert into the address table. */
  INSERT INTO address
  ( contact_id
  , address_type
  , city
  , state_province
  , postal_code
  , created_by
  , last_updated_by )
  VALUES
  ( CURRVAL('contact_contact_id_seq')
  ,(SELECT   common_lookup_id
    FROM     common_lookup
    WHERE    common_lookup_context = 'MULTIPLE'
    AND      common_lookup_type = pv_address_type)
  , pv_city
  , pv_state_province
  , pv_postal_code
  , pv_created_by
  , pv_last_updated_by );

  /* Insert into the street_address table. */
  INSERT INTO street_address
  ( address_id
  , street_address
  , created_by
  , last_updated_by )
  VALUES
  ( CURRVAL('address_address_id_seq')
  , pv_street_address
  , pv_created_by
  , pv_last_updated_by );

  /* Insert into the telephone table. */
  INSERT INTO telephone
  ( contact_id
  , address_id
  , telephone_type
  , country_code
  , area_code
  , telephone_number
  , created_by
  , last_updated_by )
  VALUES
  ( CURRVAL('contact_contact_id_seq')
  , CURRVAL('address_address_id_seq')
  ,(SELECT   common_lookup_id
    FROM     common_lookup
    WHERE    common_lookup_context = 'MULTIPLE'
    AND      common_lookup_type = pv_telephone_type)
  , pv_country_code
  , pv_area_code
  , pv_telephone_number
  , pv_created_by
  , pv_last_updated_by);

EXCEPTION
  WHEN OTHERS THEN
    err_num := SQLSTATE;
    err_msg := SUBSTR(SQLERRM,1,100);
    RAISE NOTICE 'Trapped Error: %', err_msg;
END
$$ LANGUAGE plpgsql;

-- ------------------------------------------------------------------
--  Program Name:   individual_accounts.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  12-Oct-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
--  This inserts 5 individual accounts through procedure.
-- ------------------------------------------------------------------

-- Insert first contact.
CALL contact_insert(
       pv_member_type := 'INDIVIDUAL'
     , pv_account_number := 'R11-514-34'
     , pv_credit_card_number := '1111-1111-1111-1111'
     , pv_credit_card_type := 'VISA_CARD'
     , pv_first_name := 'Goeffrey'
     , pv_middle_name := 'Ward'
     , pv_last_name := 'Clinton'
     , pv_contact_type := 'CUSTOMER'
     , pv_address_type := 'HOME'
     , pv_city := 'Provo'
     , pv_state_province := 'Utah'
     , pv_postal_code := '84606'
     , pv_street_address := '118 South 9th East'
     , pv_telephone_type := 'HOME'
     , pv_country_code := '001'
     , pv_area_code := '801'
     , pv_telephone_number := '423-1234'
     , pv_created_by := 1001
     , pv_last_updated_by := 1001 );

-- Insert second contact.
CALL contact_insert(
       pv_member_type := 'INDIVIDUAL'
     , pv_account_number := 'R11-514-35'
     , pv_credit_card_number := '1111-2222-1111-1111'
     , pv_credit_card_type := 'VISA_CARD'
     , pv_first_name := 'Wendy'
     , pv_middle_name := ''
     , pv_last_name := 'Moss'
     , pv_contact_type := 'CUSTOMER'
     , pv_address_type := 'HOME'
     , pv_city := 'Provo'
     , pv_state_province := 'Utah'
     , pv_postal_code := '84606'
     , pv_street_address := '1218 South 10th East'
     , pv_telephone_type := 'HOME'
     , pv_country_code := '001'
     , pv_area_code := '801'
     , pv_telephone_number := '423-1235'
     , pv_created_by := 1001
     , pv_last_updated_by := 1001 );

-- Insert third contact.
CALL contact_insert(
       pv_member_type := 'INDIVIDUAL'
     , pv_account_number := 'R11-514-36'
     , pv_credit_card_number := '1111-1111-2222-1111'
     , pv_credit_card_type := 'VISA_CARD'
     , pv_first_name := 'Simon'
     , pv_middle_name := 'Jonah'
     , pv_last_name := 'Gretelz'
     , pv_contact_type := 'CUSTOMER'
     , pv_address_type := 'HOME'
     , pv_city := 'Provo'
     , pv_state_province := 'Utah'
     , pv_postal_code := '84606'
     , pv_street_address := '2118 South 7th East'
     , pv_telephone_type := 'HOME'
     , pv_country_code := '001'
     , pv_area_code := '801'
     , pv_telephone_number := '423-1236'
     , pv_created_by := 1001
     , pv_last_updated_by := 1001 );

-- Insert fourth contact.
CALL contact_insert(
       pv_member_type := 'INDIVIDUAL'
     , pv_account_number := 'R11-514-37'
     , pv_credit_card_number := '3333-1111-1111-2222'
     , pv_credit_card_type := 'VISA_CARD'
     , pv_first_name := 'Elizabeth'
     , pv_middle_name := 'Jane'
     , pv_last_name := 'Royal'
     , pv_contact_type := 'CUSTOMER'
     , pv_address_type := 'HOME'
     , pv_city := 'Provo'
     , pv_state_province := 'Utah'
     , pv_postal_code := '84606'
     , pv_street_address := '2228 South 14th East'
     , pv_telephone_type := 'HOME'
     , pv_country_code := '001'
     , pv_area_code := '801'
     , pv_telephone_number := '423-1237'
     , pv_created_by := 1001
     , pv_last_updated_by := 1001 );

-- Insert fifth contact.
CALL contact_insert(
       pv_member_type := 'INDIVIDUAL'
     , pv_account_number := 'R11-514-38'
     , pv_credit_card_number := '1111-1111-3333-1111'
     , pv_credit_card_type := 'VISA_CARD'
     , pv_first_name := 'Brian'
     , pv_middle_name := 'Nathan'
     , pv_last_name := 'Smith'
     , pv_contact_type := 'CUSTOMER'
     , pv_address_type := 'HOME'
     , pv_city := 'Spanish Fork'
     , pv_state_province := 'Utah'
     , pv_postal_code := '84606'
     , pv_street_address := '333 North 2nd East'
     , pv_telephone_type := 'HOME'
     , pv_country_code := '001'
     , pv_area_code := '801'
     , pv_telephone_number := '423-1238'
     , pv_created_by := 1001
     , pv_last_updated_by := 1001 );

-- ------------------------------------------------------------------
--   Query to verify five individual rows of chained inserts through
--   a procedure into the five dependent tables.
-- ------------------------------------------------------------------
SELECT   m.account_number
,        c.last_name || ', ' || c.first_name
||       CASE
           WHEN c.middle_name IS NOT NULL THEN SUBSTRING(c.middle_name,1,1)
	   ELSE ''
         END AS full_name
,        a.city
,        a.state_province
,        t.country_code || '-(' || t.area_code || ') ' || t.telephone_number AS telephone
FROM     member m INNER JOIN contact c ON m.member_id = c.member_id INNER JOIN
         address a ON c.contact_id = a.contact_id INNER JOIN
         street_address sa ON a.address_id = sa.address_id INNER JOIN
         telephone t ON c.contact_id = t.contact_id AND a.address_id = t.address_id
WHERE    m.member_type = (SELECT common_lookup_id
                          FROM   common_lookup
                          WHERE  common_lookup_context = 'MEMBER'
                          AND    common_lookup_type = 'INDIVIDUAL');

-- ------------------------------------------------------------------
--  Program Name:   update_members.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  25-Jan-2018
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
-- These steps modify the MEMBER table created during Lab #2, by adding
-- a MEMBER_TYPE column and seeding an appropriate group or individual 
-- account on the basis of how many contacts belong to a member.
-- ------------------------------------------------------------------

-- Update all MEMBER_TYPE values based on number of dependent CONTACT rows.
UPDATE member m
SET    member_type =
        (SELECT   common_lookup_id
         FROM     common_lookup
         WHERE    common_lookup_context = 'MEMBER'
         AND      common_lookup_type =
                   (SELECT  dt.member_type
                    FROM   (SELECT   c.member_id
                            ,        CASE
                                       WHEN COUNT(c.member_id) > 1 THEN 'GROUP'
                                       ELSE 'INDIVIDUAL'
                                     END AS member_type
                            FROM     contact c
                            GROUP BY c.member_id) dt
                    WHERE    dt.member_id = m.member_id));

-- Modify the MEMBER table to add a NOT NULL constraint to the MEMBER_TYPE column.
ALTER TABLE member
  ALTER COLUMN member_type SET NOT NULL;

-- Use SQL*Plus report formatting commands.
SELECT   m.member_id
,        COUNT(contact_id) AS MEMBERS
,        m.member_type
,        cl.common_lookup_id
,        cl.common_lookup_type
FROM     member m INNER JOIN contact c
ON       m.member_id = c.member_id INNER JOIN common_lookup cl
ON       m.member_type = cl.common_lookup_id
GROUP BY m.member_id
,        m.member_type
,        cl.common_lookup_id
,        cl.common_lookup_type
ORDER BY m.member_id;

-- ------------------------------------------------------------------
--  Program Name:   rental_inserts.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  29-Jan-2018
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
--  This seeds data in the video store model.
--   - Inserts the data in the rental table for 5 records and
--     then inserts 9 dependent records in a non-sequential 
--     order.
--   - A non-sequential order requires that you use subqueries
--     to discover the foreign key values for the inserts.
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
-- Insert 5 records in the RENTAL table.
-- ------------------------------------------------------------------

INSERT INTO rental
( customer_id
, check_out_date
, return_date
, created_by
, last_updated_by )
VALUES
((SELECT   contact_id
  FROM     contact
  WHERE    last_name = 'Vizquel'
  AND      first_name = 'Oscar')
, CURRENT_DATE
, CURRENT_DATE + INTERVAL '5 day'
, 1001
, 1001 );

INSERT INTO rental
( customer_id
, check_out_date
, return_date
, created_by
, last_updated_by )
VALUES
((SELECT   contact_id
  FROM     contact
  WHERE    last_name = 'Vizquel'
  AND      first_name = 'Doreen')
, CURRENT_DATE
, CURRENT_DATE + INTERVAL '5 day'
, 1001
, 1001 );

INSERT INTO rental
( customer_id
, check_out_date
, return_date
, created_by
, last_updated_by )
VALUES
((SELECT   contact_id
  FROM     contact
  WHERE    last_name = 'Sweeney'
  AND      first_name = 'Meaghan')
, CURRENT_DATE
, CURRENT_DATE + INTERVAL '5 day'
, 1001
, 1001 );

INSERT INTO rental
( customer_id
, check_out_date
, return_date
, created_by
, last_updated_by )
VALUES
((SELECT   contact_id
  FROM     contact
  WHERE    last_name = 'Sweeney'
  AND      first_name = 'Ian')
, CURRENT_DATE
, CURRENT_DATE + INTERVAL '5 day'
, 1001
, 1001 );

INSERT INTO rental
( customer_id
, check_out_date
, return_date
, created_by
, last_updated_by )
VALUES
((SELECT   contact_id
  FROM     contact
  WHERE    last_name = 'Winn'
  AND      first_name = 'Brian')
, CURRENT_DATE
, CURRENT_DATE + INTERVAL '5 day'
, 1001
, 1001 );

-- ------------------------------------------------------------------
-- Insert 9 records in the RENTAL_ITEM table.
-- ------------------------------------------------------------------

INSERT INTO rental_item
( rental_id
, item_id
, created_by
, last_updated_by )
VALUES
((SELECT   r.rental_id
  FROM     rental r
  ,        contact c
  WHERE    r.customer_id = c.contact_id
  AND      c.last_name = 'Vizquel'
  AND      c.first_name = 'Oscar')
,(SELECT   i.item_id
  FROM     item i
  ,        common_lookup cl
  WHERE    i.item_title = 'Star Wars I'
  AND      i.item_subtitle = 'Phantom Menace'
  AND      i.item_type = cl.common_lookup_id
  AND      cl.common_lookup_type = 'DVD_WIDE_SCREEN')
, 1001
, 1001 );

INSERT INTO rental_item
( rental_id
, item_id
, created_by
, last_updated_by )
VALUES
((SELECT   r.rental_id
  FROM     rental r inner join contact c
  ON       r.customer_id = c.contact_id
  WHERE    c.last_name = 'Vizquel'
  AND      c.first_name = 'Oscar')
,(SELECT   d.item_id
  FROM     item d join common_lookup cl
  ON       d.item_title = 'Star Wars II'
  WHERE    d.item_subtitle = 'Attack of the Clones'
  AND      d.item_type = cl.common_lookup_id
  AND      cl.common_lookup_type = 'DVD_WIDE_SCREEN')
, 1001
, 1001 );

INSERT INTO rental_item
( rental_id
, item_id
, created_by
, last_updated_by )
VALUES
((SELECT   r.rental_id
  FROM     rental r
  ,        contact c
  WHERE    r.customer_id = c.contact_id
  AND      c.last_name = 'Vizquel'
  AND      c.first_name = 'Oscar')
,(SELECT   d.item_id
  FROM     item d
  ,        common_lookup cl
  WHERE    d.item_title = 'Star Wars III'
  AND      d.item_subtitle = 'Revenge of the Sith'
  AND      d.item_type = cl.common_lookup_id
  AND      cl.common_lookup_type = 'DVD_WIDE_SCREEN')
, 1001
, 1001 );

INSERT INTO rental_item
( rental_id
, item_id
, created_by
, last_updated_by )
VALUES
((SELECT   r.rental_id
  FROM     rental r
  ,        contact c
  WHERE    r.customer_id = c.contact_id
  AND      c.last_name = 'Vizquel'
  AND      c.first_name = 'Doreen')
,(SELECT   d.item_id
  FROM     item d
  ,        common_lookup cl
  WHERE    d.item_title = 'I Remember Mama'
  AND      d.item_subtitle = ''
  AND      d.item_type = cl.common_lookup_id
  AND      cl.common_lookup_type = 'BLU-RAY')
, 1001
, 1001 );

INSERT INTO rental_item
( rental_id
, item_id
, created_by
, last_updated_by )
VALUES
((SELECT   r.rental_id
  FROM     rental r
  ,        contact c
  WHERE    r.customer_id = c.contact_id
  AND      c.last_name = 'Vizquel'
  AND      c.first_name = 'Doreen')
,(SELECT   d.item_id
  FROM     item d
  ,        common_lookup cl
  WHERE    d.item_title = 'Camelot'
  AND      d.item_subtitle = ''
  AND      d.item_type = cl.common_lookup_id
  AND      cl.common_lookup_type = 'BLU-RAY')
, 1001
, 1001 );

INSERT INTO rental_item
( rental_id
, item_id
, created_by
, last_updated_by )
VALUES
((SELECT   r.rental_id
  FROM     rental r
  ,        contact c
  WHERE    r.customer_id = c.contact_id
  AND      c.last_name = 'Sweeney'
  AND      c.first_name = 'Meaghan')
,(SELECT   d.item_id
  FROM     item d
  ,        common_lookup cl
  WHERE    d.item_title = 'Hook'
  AND      d.item_subtitle = ''
  AND      d.item_type = cl.common_lookup_id
  AND      cl.common_lookup_type = 'BLU-RAY')
, 1001
, 1001 );

INSERT INTO rental_item
( rental_id
, item_id
, created_by
, last_updated_by )
VALUES
((SELECT   r.rental_id
  FROM     rental r
  ,        contact c
  WHERE    r.customer_id = c.contact_id
  AND      c.last_name = 'Sweeney'
  AND      c.first_name = 'Ian')
,(SELECT   d.item_id
  FROM     item d
  ,        common_lookup cl
  WHERE    d.item_title = 'Cars'
  AND      d.item_subtitle = ''
  AND      d.item_type = cl.common_lookup_id
  AND      cl.common_lookup_type = 'XBOX')
, 1001
, 1001 );

INSERT INTO rental_item
( rental_id
, item_id
, created_by
, last_updated_by )
VALUES
((SELECT   r.rental_id
  FROM     rental r
  ,        contact c
  WHERE    r.customer_id = c.contact_id
  AND      c.last_name = 'Winn'
  AND      c.first_name = 'Brian')
,(SELECT   d.item_id
  FROM     item d
  ,        common_lookup cl
  WHERE    d.item_title = 'RoboCop'
  AND      d.item_subtitle = ''
  AND      d.item_type = cl.common_lookup_id
  AND      cl.common_lookup_type = 'XBOX')
, 1001
, 1001 );

INSERT INTO rental_item
( rental_id
, item_id
, created_by
, last_updated_by )
VALUES
((SELECT   r.rental_id
  FROM     rental r
  ,        contact c
  WHERE    r.customer_id = c.contact_id
  AND      c.last_name = 'Winn'
  AND      c.first_name = 'Brian')
,(SELECT   d.item_id
  FROM     item d
  ,        common_lookup cl
  WHERE    d.item_title = 'The Hunt for Red October'
  AND      d.item_subtitle = 'Special Collector''s Edition'
  AND      d.item_type = cl.common_lookup_id
  AND      cl.common_lookup_type = 'DVD_WIDE_SCREEN')
, 1001
, 1001 );

-- ------------------------------------------------------------------
--   Query to verify nine rental agreements, some with one and some
--   with more than one rental item.
-- ------------------------------------------------------------------
SELECT   m.member_id
,        m.account_number
,        c.last_name || ', ' || c.first_name
||       CASE
           WHEN c.middle_name IS NOT NULL THEN ' ' ||SUBSTR(c.middle_name,1,1)
	   ELSE ''
         END AS full_name
,        r.rental_id
,        ri.rental_item_id
,        i.item_title
FROM     member m INNER JOIN contact c ON m.member_id = c.member_id INNER JOIN
         rental r ON c.contact_id = r.customer_id INNER JOIN
         rental_item ri ON r.rental_id = ri.rental_id INNER JOIN
         item i ON ri.item_id = i.item_id
ORDER BY r.rental_id;

-- ------------------------------------------------------------------
--  Program Name:   system_user_inserts.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  30-Jan-2018
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
-- This creates tables, sequences, indexes, and constraints necessary
-- to begin lesson #3. Demonstrates proper process and syntax.
-- ------------------------------------------------------------------

-- Insert statement demonstrates a mandatory-only column override signature.
-- ------------------------------------------------------------------
-- TIP: When a comment ends the last line, you must use a forward slash on
--      on the next line to run the statement rather than a semicolon.
-- ------------------------------------------------------------------

-- --------------------------------------------------------
--  Step #1
--  --------
--   Display the rows in the member and contact tables.
-- --------------------------------------------------------

SELECT   m.member_id
,        COUNT(contact_id) AS MEMBERS
,        cl.common_lookup_type
FROM     member m INNER JOIN contact c
ON       m.member_id = c.member_id INNER JOIN common_lookup cl
ON       m.member_type = cl.common_lookup_id
GROUP BY m.member_id
,        m.member_type
,        cl.common_lookup_id
,        cl.common_lookup_type
ORDER BY m.member_id;

-- --------------------------------------------------------
--  Step #2
--  --------
--   Create a view .
-- --------------------------------------------------------
CREATE OR REPLACE VIEW current_rental AS
  SELECT   m.account_number
  ,        c.last_name || ', ' || c.first_name
  ||       CASE
             WHEN c.middle_name IS NOT NULL THEN ' ' || SUBSTR(c.middle_name,1,1)
             ELSE ''
           END AS full_name
  ,        i.item_title AS title
  ,        i.item_subtitle AS subtitle
  ,        SUBSTR(cl.common_lookup_meaning,1,3) AS product
  ,        r.check_out_date
  ,        r.return_date
  FROM     member m INNER JOIN contact c ON m.member_id = c.member_id INNER JOIN
           rental r ON c.contact_id = r.customer_id INNER JOIN
           rental_item ri ON r.rental_id = ri.rental_id INNER JOIN
           item i ON ri.item_id = i.item_id INNER JOIN
           common_lookup cl ON i.item_id = cl.common_lookup_id
  ORDER BY 1, 2, 3;

-- --------------------------------------------------------
--  Step #3
--  --------
--   Display the content of a view .
-- --------------------------------------------------------
SELECT   cr.full_name
,        cr.title
,        cr.check_out_date
,        cr.return_date
FROM     current_rental cr;

-- ------------------------------------------------------------------
--  Program Name:   system_user_inserts.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  26-Jan-2018
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
-- This creates tables, sequences, indexes, and constraints necessary
-- to begin lesson #3. Demonstrates proper process and syntax.
-- ------------------------------------------------------------------

-- Insert statement demonstrates a mandatory-only column override signature.
-- ------------------------------------------------------------------
-- TIP: When a comment ends the last line, you must use a forward slash on
--      on the next line to run the statement rather than a semicolon.
-- ------------------------------------------------------------------

-- --------------------------------------------------------
--  Step #1
--  --------
--  Insert three new DBAs into the system_user table.
-- --------------------------------------------------------
INSERT
INTO system_user
( system_user_name
, system_user_group_id
, system_user_type
, last_name
, first_name
, created_by
, last_updated_by )
VALUES
('DBA3'                                           -- system_user_name
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'SYSTEM_USER'
  AND      common_lookup_type = 'DBA')            -- system_user_group_id            
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'SYSTEM_USER'
  AND      common_lookup_type = 'SYSTEM_GROUP')   -- system_user_type
,'Adams'                                          -- last_name
,'Samuel'                                         -- middle_name
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

INSERT
INTO system_user
( system_user_name
, system_user_group_id
, system_user_type
, last_name
, first_name
, created_by
, last_updated_by )
VALUES
('DBA4'                                           -- system_user_name
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'SYSTEM_USER'
  AND      common_lookup_type = 'DBA')            -- system_user_group_id            
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'SYSTEM_USER'
  AND      common_lookup_type = 'SYSTEM_GROUP')   -- system_user_type
,'Henry'                                          -- last_name
,'Patrick'                                        -- middle_name
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

INSERT
INTO system_user
( system_user_name
, system_user_group_id
, system_user_type
, last_name
, first_name
, created_by
, last_updated_by )
VALUES
('DBA5'                                           -- system_user_name
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'SYSTEM_USER'
  AND      common_lookup_type = 'DBA')            -- system_user_group_id            
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'SYSTEM_USER'
  AND      common_lookup_type = 'SYSTEM_GROUP')   -- system_user_type
,'Manmohan'                                       -- last_name
,'Puri'                                           -- middle_name
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

-- --------------------------------------------------------
--  Step #2
--  --------
--  Display inserted rows from the system_user table.
-- --------------------------------------------------------
SELECT   system_user_id
,        system_user_group_id
,        system_user_type
,        system_user_name
,        CASE
           WHEN last_name IS NOT NULL THEN
             last_name || ', ' || first_name
||         CASE
             WHEN middle_name IS NOT NULL THEN ' ' || middle_name
             ELSE ''
	   END	
         END AS full_user_name
FROM     system_user;

-- ------------------------------------------------------------------
--  Program Name:   drop_rating_agency.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  11-Aug-2020
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  

-- ------------------------------------------------------------------
--  Conditionally drop table.
-- ------------------------------------------------------------------
DROP TABLE IF EXISTS rating_agency CASCADE;

-- ------------------------------------------------------------------
--  Program Name:   apply_lab5_step6.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  27-Aug-2020
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
--
-- ------------------------------------------------------------------
-- Instructions:
-- ------------------------------------------------------------------
-- You first connect to the Postgres database with this syntax:
--
--   psql -U student -d videodb -W
--
-- Then, you call this script with the following syntax:
--
--   psql> \i apply_lab5_step6.sql
--
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
--  Enter the query below.
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
--  Create table.
-- -------------------------------------------------------------------
CREATE TABLE rating_agency
( rating_agency_id    SERIAL
, rating_agency_abbr  VARCHAR(8)   NOT NULL
, rating_agency_name  VARCHAR(40)  NOT NULL
, created_by          INTEGER      NOT NULL
, creation_date       TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, last_updated_by     INTEGER      NOT NULL
, last_update_date    TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, CONSTRAINT pk_rating_agency PRIMARY KEY (rating_agency_id)
, CONSTRAINT uq_rating_agency UNIQUE (rating_agency_abbr, rating_agency_name)
, CONSTRAINT fk_rating_agency_1  FOREIGN KEY (created_by) REFERENCES system_user (system_user_id)
, CONSTRAINT fk_rating_agency_2  FOREIGN KEY (last_updated_by) REFERENCES system_user (system_user_id));

-- Alter the sequence by restarting it at 1001.
ALTER SEQUENCE rating_agency_rating_agency_id_seq RESTART WITH 1001;

-- ------------------------------------------------------------------
--  Program Name:   verify_rating_agency.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  11-Oct-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ==================================================================
--  This creates the system_user table and system_user_s1 sequences.
-- ------------------------------------------------------------------
--    Create and assign bind variable for table name.
-- ==================================================================
SET SESSION "videodb.table_name" = 'rating_agency';
SET CLIENT_MIN_MESSAGES TO ERROR;

--  Verify table name.
SELECT current_setting('videodb.table_name');

-- Display the table organization.
SELECT   tc.table_catalog || '.' || tc.constraint_name AS constraint_name
,        tc.table_catalog || '.' || tc.table_name AS table_name
,        kcu.column_name
,        ccu.table_catalog || '.' || ccu.table_name AS foreign_table_name
,        ccu.column_name AS foreign_column_name
FROM     information_schema.table_constraints AS tc JOIN information_schema.key_column_usage AS kcu
ON       tc.constraint_name = kcu.constraint_name
AND      tc.table_schema = kcu.table_schema JOIN information_schema.constraint_column_usage AS ccu
ON       ccu.constraint_name = tc.constraint_name
AND      ccu.table_schema = tc.table_schema
WHERE    tc.constraint_type = 'FOREIGN KEY'
AND      tc.table_name = current_setting('videodb.table_name')
ORDER BY 1;

SELECT c1.table_name
,      c1.ordinal_position
,      c1.column_name
,      CASE
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NOT NULL THEN 'PRIMARY KEY'
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NULL THEN 'NOT NULL'
       END AS is_nullable
,      CASE
         WHEN data_type = 'character varying' THEN
	   data_type||'('||character_maximum_length||')'
         WHEN data_type = 'numeric' THEN
	   CASE
	     WHEN numeric_scale != 0 AND numeric_scale IS NOT NULL THEN
               data_type||'('||numeric_precision||','||numeric_scale||')'
	     ELSE
               data_type||'('||numeric_precision||')'
	     END
         ELSE
           data_type
        END AS data_type
FROM    information_schema.columns c1 LEFT JOIN
          (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id' column_name
           FROM   information_schema.columns) c2
ON       c1.column_name = c2.column_name
WHERE    c1.table_name = current_setting('videodb.table_name')
ORDER BY c1.ordinal_position;

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Display table indexes.
SELECT tablename
,      indexname
FROM   pg_indexes
WHERE  tablename = current_setting('videodb.table_name');

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Display table, column, and sequence names.
SELECT table_name
,      column_name
,      trim(regexp_matches(column_default,'''.*''')::text,'{''}') AS sequence_name
FROM   information_schema.columns c1
WHERE  table_name = current_setting('videodb.table_name')
AND    column_name =
 (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id'
  FROM   information_schema.columns c2
  WHERE  c1.table_name = c2.table_name);

-- ------------------------------------------------------------------
--  Program Name:   apply_lab5_step7.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  27-Aug-2020
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
--
-- ------------------------------------------------------------------
-- Instructions:
-- ------------------------------------------------------------------
-- You first connect to the Postgres database with this syntax:
--
--   psql -U student -d videodb -W
--
-- Then, you call this script with the following syntax:
--
--   psql> \i apply_lab5_step7.sql
--
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
--  Enter the 1st Row below.
-- ------------------------------------------------------------------

INSERT INTO rating_agency
( rating_agency_abbr
, rating_agency_name
, created_by
, last_updated_by )
VALUES
('ESRB'
,'Entertainment Software Rating Board'
,(SELECT system_user_id
  FROM   system_user
  WHERE  system_user_name = 'DBA2')
,(SELECT system_user_id
  FROM   system_user
  WHERE  system_user_name = 'DBA2'));

-- ------------------------------------------------------------------
--  Enter the 1st Row below.
-- ------------------------------------------------------------------

INSERT INTO rating_agency
( rating_agency_abbr
, rating_agency_name
, created_by
, last_updated_by )
VALUES
('MPAA'
,'Motion Picture Association of America'
,(SELECT system_user_id
  FROM   system_user
  WHERE  system_user_name = 'DBA2')
,(SELECT system_user_id
  FROM   system_user
  WHERE  system_user_name = 'DBA2'));

-- ------------------------------------------------------------------
--  Program Name:   drop_rating.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  11-Aug-2020
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  

-- ------------------------------------------------------------------
--  Conditionally drop table.
-- ------------------------------------------------------------------
DROP TABLE IF EXISTS rating CASCADE;

-- ------------------------------------------------------------------
--  Program Name:   apply_lab5_step8.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  27-Aug-2020
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
--
-- ------------------------------------------------------------------
-- Instructions:
-- ------------------------------------------------------------------
-- You first connect to the Postgres database with this syntax:
--
--   psql -U student -d videodb -W
--
-- Then, you call this script with the following syntax:
--
--   psql> \i apply_lab5_step8.sql
--
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
--  Enter the query below.
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
--  Create table.
-- -------------------------------------------------------------------
CREATE TABLE rating
( rating_id           SERIAL
, rating_agency_id    INTEGER      NOT NULL
, rating              VARCHAR(10)  NOT NULL
, description         VARCHAR(420) NOT NULL
, created_by          INTEGER      NOT NULL
, creation_date       TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, last_updated_by     INTEGER      NOT NULL
, last_update_date    TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, CONSTRAINT pk_rating  PRIMARY KEY (rating_id)
, CONSTRAINT uq_rating  UNIQUE (rating)
, CONSTRAINT fk_rating_1  FOREIGN KEY (rating_agency_id) REFERENCES rating_agency (rating_agency_id)
, CONSTRAINT fk_rating_2  FOREIGN KEY (created_by) REFERENCES system_user (system_user_id)
, CONSTRAINT fk_rating_3  FOREIGN KEY (last_updated_by) REFERENCES system_user (system_user_id));

-- Alter the sequence by restarting it at 1001.
ALTER SEQUENCE rating_rating_id_seq RESTART WITH 1001;

-- ------------------------------------------------------------------
--  Program Name:   verify_rating.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  11-Oct-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ==================================================================
--  This creates the system_user table and system_user_s1 sequences.
-- ------------------------------------------------------------------
--    Create and assign bind variable for table name.
-- ==================================================================
SET SESSION "videodb.table_name" = 'rating';
SET CLIENT_MIN_MESSAGES TO ERROR;

--  Verify table name.
SELECT current_setting('videodb.table_name');

-- Display the table organization.
SELECT   tc.table_catalog || '.' || tc.constraint_name AS constraint_name
,        tc.table_catalog || '.' || tc.table_name AS table_name
,        kcu.column_name
,        ccu.table_catalog || '.' || ccu.table_name AS foreign_table_name
,        ccu.column_name AS foreign_column_name
FROM     information_schema.table_constraints AS tc JOIN information_schema.key_column_usage AS kcu
ON       tc.constraint_name = kcu.constraint_name
AND      tc.table_schema = kcu.table_schema JOIN information_schema.constraint_column_usage AS ccu
ON       ccu.constraint_name = tc.constraint_name
AND      ccu.table_schema = tc.table_schema
WHERE    tc.constraint_type = 'FOREIGN KEY'
AND      tc.table_name = current_setting('videodb.table_name')
ORDER BY 1;

SELECT c1.table_name
,      c1.ordinal_position
,      c1.column_name
,      CASE
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NOT NULL THEN 'PRIMARY KEY'
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NULL THEN 'NOT NULL'
       END AS is_nullable
,      CASE
         WHEN data_type = 'character varying' THEN
	   data_type||'('||character_maximum_length||')'
         WHEN data_type = 'numeric' THEN
	   CASE
	     WHEN numeric_scale != 0 AND numeric_scale IS NOT NULL THEN
               data_type||'('||numeric_precision||','||numeric_scale||')'
	     ELSE
               data_type||'('||numeric_precision||')'
	     END
         ELSE
           data_type
        END AS data_type
FROM    information_schema.columns c1 LEFT JOIN
          (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id' column_name
           FROM   information_schema.columns) c2
ON       c1.column_name = c2.column_name
WHERE    c1.table_name = current_setting('videodb.table_name')
ORDER BY c1.ordinal_position;

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Display table indexes.
SELECT tablename
,      indexname
FROM   pg_indexes
WHERE  tablename = current_setting('videodb.table_name');

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Display table, column, and sequence names.
SELECT table_name
,      column_name
,      trim(regexp_matches(column_default,'''.*''')::text,'{''}') AS sequence_name
FROM   information_schema.columns c1
WHERE  table_name = current_setting('videodb.table_name')
AND    column_name =
 (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id'
  FROM   information_schema.columns c2
  WHERE  c1.table_name = c2.table_name);

-- ------------------------------------------------------------------
--  Program Name:   apply_lab5_step9.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  27-Aug-2020
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
--
-- ------------------------------------------------------------------
-- Instructions:
-- ------------------------------------------------------------------
-- You first connect to the Postgres database with this syntax:
--
--   psql -U student -d videodb -W
--
-- Then, you call this script with the following syntax:
--
--   psql> \i apply_lab5_step9.sql
--
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
--  Enter the Task #1.
-- ------------------------------------------------------------------

UPDATE item
SET    item_rating = 'PG-13'
WHERE  item_rating = 'PG13';

-- ------------------------------------------------------------------
--  Enter the Task #2.
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
--  Analyze the INSERT statement.
--  -----------------------------
--   1. The WITH clause is called a common table expression (CTE).
--   2. The rating_agency and item tables have nothing in common,
--      which makes joining them a challenge.
--   3. The rating_agency and item tables have a many-to-many 
--      relationship logically, which means there needs to exist
--      an association table.
--   4. There are two rules for joining these result sets, one for
--      the esrb and another for the mpaa rating agency.
--   5. The esrb CTE uses a CROSS JOIN to create a set of three
--      rows; the mpaa CTE uses a CROSS JOIN to create a set of
--      four rows; and the bridge CTE uses a SET operator to 
--      add one set to another based on their mirrored data 
--      structure, which is like a SELECT-list. 
--   6. The su CTE puts a single variable in context, which we
--      add to each row by using the Cartesian product process.
--      A Cartesian product of one table with another table of only
--      one column and row (or attribute and tuple) simply adds the
--      single column to each row in the original table.
--   7. The INSERT statement can then use a query to populate all
--      necessary rating table rows that allow you to join the
--      rating_agency row with the item table. The rating table
--      must have the correct data because after making this change
--      to the data model, it is essential to populate the new
--      rating_id foreign key column before removing the original
--      item_rating column.
-- ------------------------------------------------------------------

WITH esrb AS
(SELECT *
 FROM  (SELECT 'ESRB' AS abbr) k
        CROSS JOIN
       (SELECT 'E' AS rating
        ,      'Everyone' AS rating_desc
        UNION
        SELECT 'M' AS rating
        ,      'Mature' AS rating_desc
        UNION
        SELECT 'T' AS rating
        ,      'Teen' AS rating_desc) v)
, mpaa AS
(SELECT *
 FROM  (SELECT 'MPAA' AS abbr) k
        CROSS JOIN
       (SELECT 'G' AS rating
        ,      'General Audiences' AS rating_desc
        UNION
        SELECT 'PG' AS rating
        ,      'Parental Guidance' AS rating_desc
        UNION
        SELECT 'PG-13' AS rating
        ,      'Parental Strongly Caustioned' AS rating_desc 
        UNION
        SELECT 'NR' AS rating
        ,      'Not Rated' AS rating_desc) v)
, bridge AS
(SELECT *
 FROM   esrb
 UNION
 SELECT *
 FROM   mpaa)
, su AS
(SELECT system_user_id
 FROM   system_user
 WHERE  system_user_name = 'DBA2')
INSERT INTO rating
( rating_agency_id
, rating
, description
, created_by
, last_updated_by )
(SELECT  DISTINCT
         ra.rating_agency_id
 ,       i.item_rating AS rating
 ,       b.rating_desc AS description
 ,       su.system_user_id AS created_by
 ,       su.system_user_id AS last_updated_by
 FROM    rating_agency ra JOIN bridge b
 ON      ra.rating_agency_abbr = b.abbr JOIN item i
 ON      b.rating = i.item_rating
 OR      b.rating_desc = i.item_rating CROSS JOIN su);


-- ------------------------------------------------------------------
--  Enter the Task #3.
-- ------------------------------------------------------------------

ALTER TABLE item 
  ADD rating_id INT;

-- ------------------------------------------------------------------
--  Enter the Task #4.
-- ------------------------------------------------------------------

UPDATE item
SET    rating_id =
        (SELECT  r.rating_id
          FROM   rating r
	      WHERE  r.rating = item.item_rating
          OR     r.description = item.item_rating);

-- ------------------------------------------------------------------
--  Enter the Task #9d.
--  ------------------
--   Add a not null constraint on the rating_id column in the item
--   table.
-- ------------------------------------------------------------------

ALTER TABLE item
  ALTER COLUMN rating_id SET NOT NULL;

-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
--  Program Name:   verify_foreign_key.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  11-Oct-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ==================================================================
--  This creates the system_user table and system_user_s1 sequences.
-- ------------------------------------------------------------------
--    Create and assign bind variable for table name.
-- ==================================================================

--  Verify table name.
SELECT   i.item_id
,        r.rating_id
,        r.rating
,        i.item_rating
FROM     rating r JOIN item i
ON       r.rating_id = i.rating_id
ORDER BY i.item_id;

-- ------------------------------------------------------------------
--  Enter the Task #9e.
--  ------------------
--   Add a not null constraint on the rating_id column in the item
--   table.
-- ------------------------------------------------------------------

ALTER TABLE item
  ADD CONSTRAINT fk_item_4 FOREIGN KEY (rating_id)
      REFERENCES rating(rating_id);
	  
-- ------------------------------------------------------------------
--  Program Name:   verify_item.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  11-Oct-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ==================================================================
--  This creates the system_user table and system_user_s1 sequences.
-- ------------------------------------------------------------------
--    Create and assign bind variable for table name.
-- ==================================================================
SET SESSION "videodb.table_name" = 'item';
SET CLIENT_MIN_MESSAGES TO ERROR;

--  Verify table name.
SELECT current_setting('videodb.table_name');

-- Display the table organization.
SELECT   tc.table_catalog || '.' || tc.constraint_name AS constraint_name
,        tc.table_catalog || '.' || tc.table_name AS table_name
,        kcu.column_name
,        ccu.table_catalog || '.' || ccu.table_name AS foreign_table_name
,        ccu.column_name AS foreign_column_name
FROM     information_schema.table_constraints AS tc JOIN information_schema.key_column_usage AS kcu
ON       tc.constraint_name = kcu.constraint_name
AND      tc.table_schema = kcu.table_schema JOIN information_schema.constraint_column_usage AS ccu
ON       ccu.constraint_name = tc.constraint_name
AND      ccu.table_schema = tc.table_schema
WHERE    tc.constraint_type = 'FOREIGN KEY'
AND      tc.table_name = current_setting('videodb.table_name')
ORDER BY 1;

SELECT c1.table_name
,      c1.ordinal_position
,      c1.column_name
,      CASE
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NOT NULL THEN 'PRIMARY KEY'
         WHEN c1.is_nullable = 'NO' AND c2.column_name IS NULL THEN 'NOT NULL'
       END AS is_nullable
,      CASE
         WHEN data_type = 'character varying' THEN
	   data_type||'('||character_maximum_length||')'
         WHEN data_type = 'numeric' THEN
	   CASE
	     WHEN numeric_scale != 0 AND numeric_scale IS NOT NULL THEN
               data_type||'('||numeric_precision||','||numeric_scale||')'
	     ELSE
               data_type||'('||numeric_precision||')'
	     END
         ELSE
           data_type
        END AS data_type
FROM    information_schema.columns c1 LEFT JOIN
          (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id' column_name
           FROM   information_schema.columns) c2
ON       c1.column_name = c2.column_name
WHERE    c1.table_name = current_setting('videodb.table_name')
ORDER BY c1.ordinal_position;

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Display table indexes.
SELECT tablename
,      indexname
FROM   pg_indexes
WHERE  tablename = current_setting('videodb.table_name');

-- Display primary key and unique constraints.
SELECT constraint_name
,      lower(constraint_type) AS constraint_type
FROM   information_schema.table_constraints
WHERE  table_name = current_setting('videodb.table_name')
AND    constraint_type IN ('PRIMARY KEY','UNIQUE');

-- Display table, column, and sequence names.
SELECT table_name
,      column_name
,      trim(regexp_matches(column_default,'''.*''')::text,'{''}') AS sequence_name
FROM   information_schema.columns c1
WHERE  table_name = current_setting('videodb.table_name')
AND    column_name =
 (SELECT trim(regexp_matches(column_default,current_setting('videodb.table_name'))::text,'{}')||'_id'
  FROM   information_schema.columns c2
  WHERE  c1.table_name = c2.table_name);

-- ------------------------------------------------------------------
--  Enter the Task #9e.
-- ------------------------------------------------------------------

ALTER TABLE item DROP COLUMN item_rating;

-- ------------------------------------------------------------------
--  Enter the query below.
-- ------------------------------------------------------------------

SELECT   m.account_number
,        c.last_name
,        i.item_title
,        ra.rating_agency_abbr
,        rate.rating
FROM     member m JOIN contact c
ON       m.member_id = c.member_id 
JOIN     rental r
ON       c.contact_id = r.customer_id
JOIN     rental_item ri
ON       r.rental_id = ri.rental_id
JOIN     item i
ON       ri.item_id = i.item_id
JOIN     rating rate
ON       i.rating_id = rate.rating_id
JOIN     rating_agency ra
ON       rate.rating_agency_id = ra.rating_agency_id
ORDER BY c.last_name
,        i.item_title;

-- ------------------------------------------------------------------
--  Program Name:   apply_lab6_step1.sql
--  Lab Assignment: Lab #6
--  Program Author: Michael McLaughlin
--  Creation Date:  05-Nov-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
--
-- ------------------------------------------------------------------
-- Instructions:
-- ------------------------------------------------------------------
-- You first connect to the Postgres database with this syntax:
--
--   psql -U student -d videodb -W
--
-- Then, you call this script with the following syntax:
--
--   psql> \i apply_lab6_step1.sql
--
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
--  Task #1: Add rental_item_type column.
-- ------------------------------------------------------------------
ALTER TABLE rental_item
ADD COLUMN rental_item_type int;

-- ------------------------------------------------------------------
--  Task #2: Add foreign key constraint on rental_item_type column.
-- ------------------------------------------------------------------
ALTER TABLE rental_item
ADD CONSTRAINT fk_rental_item_5 FOREIGN KEY (rental_item_type)
REFERENCES common_lookup (common_lookup_id);

-- ------------------------------------------------------------------
--  Task #3: Add rental_item_price column.
-- ------------------------------------------------------------------
ALTER TABLE rental_item
ADD COLUMN rental_item_price decimal(12,2);

-- ------------------------------------------------------------------
--  Program Name:   apply_lab6_step2.sql
--  Lab Assignment: Lab #6
--  Program Author: Michael McLaughlin
--  Creation Date:  05-Nov-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
--
-- ------------------------------------------------------------------
-- Instructions:
-- ------------------------------------------------------------------
-- You first connect to the Postgres database with this syntax:
--
--   psql -U student -d videodb -W
--
-- Then, you call this script with the following syntax:
--
--   psql> \i apply_lab6_step2.sql
--
-- ------------------------------------------------------------------

DROP TABLE IF EXISTS price;

-- ------------------------------------------------------------------
--  Task #1: Create the price table.
-- -------------------------------------------------------------------
CREATE TABLE price
( price_id                SERIAL
, item_id                 INTEGER
, price_type              INTEGER      NOT NULL
, active_flag             VARCHAR(1)   NOT NULL
, start_date              INTEGER      NOT NULL
, end_date                INTEGER
, amount                  NUMERIC      NOT NULL 
, created_by              INTEGER      NOT NULL
, creation_date           TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, last_updated_by         INTEGER      NOT NULL
, last_update_date        TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, PRIMARY KEY (price_id)
, CONSTRAINT fk_price_1   FOREIGN KEY (item_id) REFERENCES item (item_id)
, CONSTRAINT fk_price_2   FOREIGN KEY (price_type) REFERENCES common_lookup (common_lookup_id)
, CONSTRAINT fk_price_3   FOREIGN KEY (created_by) REFERENCES system_user (system_user_id)
, CONSTRAINT fk_price_4   FOREIGN KEY (last_updated_by) REFERENCES system_user (system_user_id));

-- ------------------------------------------------------------------
--  Task #2: Alter sequence to restart at 1001.
-- ------------------------------------------------------------------
ALTER SEQUENCE price_price_id_seq RESTART WITH 1001;

-- ------------------------------------------------------------------
--  Task #3: Add yn_price check constraint.
-- ------------------------------------------------------------------
ALTER TABLE price
ADD CONSTRAINT yn_price CHECK (active_flag IN ('Y','N'));

-- ------------------------------------------------------------------
--  Program Name:   apply_lab6_step3.sql
--  Lab Assignment: Lab #6
--  Program Author: Michael McLaughlin
--  Creation Date:  07-Nov-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
--
-- ------------------------------------------------------------------
-- Instructions:
-- ------------------------------------------------------------------
-- You first connect to the Postgres database with this syntax:
--
--   psql -U student -d videodb -W
--
-- Then, you call this script with the following syntax:
--
--   psql> \i apply_lab6_step3.sql
--
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
--  Task #1: Rename the column item_release_date to release_date.
-- -------------------------------------------------------------------
ALTER TABLE item
RENAME COLUMN item_release_date TO release_date;

-- ------------------------------------------------------------------
--  Program Name:   apply_lab6_step4.sql
--  Lab Assignment: Lab #6
--  Program Author: Michael McLaughlin
--  Creation Date:  07-Nov-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
--
-- ------------------------------------------------------------------
-- Instructions:
-- ------------------------------------------------------------------
-- You first connect to the Postgres database with this syntax:
--
--   psql -U student -d videodb -W
--
-- Then, you call this script with the following syntax:
--
--   psql> \i apply_lab6_step4.sql
--
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
--  Task #1: Create the price table.
-- -------------------------------------------------------------------
INSERT INTO item
( item_barcode
, item_type
, item_title
, rating_id
, release_date
, created_by
, last_updated_by )
VALUES
('B07RJ9M8JW'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'BLU-RAY')
,'X-Men: Dark Phoenix'
,(SELECT   rating_id
  FROM     rating
  WHERE    rating = 'PG-13')
,(CURRENT_DATE - INTERVAL '10 days')::date
, 1001
, 1001 );

-- ------------------------------------------------------------------
--  Task #2: Alter sequence to restart at 1001.
-- ------------------------------------------------------------------
INSERT INTO item
( item_barcode
, item_type
, item_title
, rating_id
, release_date
, created_by
, last_updated_by )
VALUES
('B07VHY78RQ'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'BLU-RAY')
,'Toy Story 4'
,(SELECT   rating_id
  FROM     rating
  WHERE    rating = 'G')
,(CURRENT_DATE - INTERVAL '10 days')::date
, 1001
, 1001 );

-- ------------------------------------------------------------------
--  Task #3: Add yn_price check constraint.
-- ------------------------------------------------------------------
INSERT INTO item
( item_barcode
, item_type
, item_title
, rating_id
, release_date
, created_by
, last_updated_by )
VALUES
('B07SRF34CC'
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'ITEM'
  AND      common_lookup_type = 'BLU-RAY')
,'Spider-Man: Far from Home'
,(SELECT   rating_id
  FROM     rating
  WHERE    rating = 'PG-13')
,(CURRENT_DATE - INTERVAL '10 days')::date
, 1001
, 1001 );

-- ------------------------------------------------------------------
--  Program Name:   apply_lab6_step2.sql
--  Lab Assignment: Lab #6
--  Program Author: Michael McLaughlin
--  Creation Date:  07-Nov-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
--
-- ------------------------------------------------------------------
-- Instructions:
-- ------------------------------------------------------------------
-- You first connect to the Postgres database with this syntax:
--
--   psql -U student -d videodb -W
--
-- Then, you call this script with the following syntax:
--
--   psql> \i apply_lab6_step5.sql
--
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
--  Task #1: Insert a record in member table for Potter family.
-- -------------------------------------------------------------------
INSERT INTO member
( member_type
, account_number
, credit_card_number
, credit_card_type
, created_by
, last_updated_by )
VALUES
((SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'MEMBER'
  AND      common_lookup_type = 'DISCOVER_CARD')  -- member_type
,'US00011'                                        -- account_number
,'6011-0000-0000-0078'                            -- credit_card_number
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'MEMBER'
  AND      common_lookup_type = 'DISCOVER_CARD')  -- credit_card_type
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'DBA1')             -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'DBA1')             -- last_updated_by
);

-- ------------------------------------------------------------------
--  Task #2: Insert a records for Harry Potter.
-- -------------------------------------------------------------------

-- ------------------------------------------------------------------
-- Insert into contact.
-- ------------------------------------------------------------------
INSERT INTO contact
( member_id
, contact_type
, first_name
, last_name
, created_by
, last_updated_by )
VALUES
( CURRVAL('member_member_id_seq')                 -- member_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'CONTACT'
  AND      common_lookup_type = 'CUSTOMER')       -- contact_type
,'Harry'                                          -- first_name
,'Potter'                                         -- last_name
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'DBA1')             -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'DBA1')             -- last_updated_by
);

-- ------------------------------------------------------------------
-- Insert into address.
-- ------------------------------------------------------------------
INSERT INTO address
( contact_id
, address_type
, city
, state_province
, postal_code
, created_by
, last_updated_by )
VALUES
( CURRVAL('contact_contact_id_seq')               -- contact_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_type = 'HOME')           -- address_type
,'Provo'                                          -- city
,'Utah'                                           -- state_province
,'84601'                                          -- postal_code
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'DBA1')             -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'DBA1')             -- last_updated_by
);

-- ------------------------------------------------------------------
-- Insert into street_address.
-- ------------------------------------------------------------------
INSERT INTO street_address
( address_id
, street_address
, created_by
, last_updated_by )
 VALUES
( CURRVAL('address_address_id_seq')               -- address_id
,'900 E 300 N'                                    -- street_address
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'DBA1')             -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'DBA1')             -- last_updated_by
);

-- ------------------------------------------------------------------
-- Insert into telephone.
-- ------------------------------------------------------------------
INSERT INTO telephone
( contact_id
, address_id
, telephone_type
, country_code
, area_code
, telephone_number
, created_by
, last_updated_by )
 VALUES
( CURRVAL('contact_contact_id_seq')               -- address_id
, CURRVAL('address_address_id_seq')               -- contact_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'MULTIPLE'
  AND      common_lookup_type = 'HOME')           -- telephone_type
,'001'                                            -- country_code
,'801'                                            -- area_code
,'333-3333'                                       -- telephone_number
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'DBA1')             -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'DBA1')             -- last_updated_by
);

-- ------------------------------------------------------------------
--  Task #3: Insert a records for Ginny Potter.
-- -------------------------------------------------------------------

-- ------------------------------------------------------------------
-- Insert into contact.
-- ------------------------------------------------------------------
INSERT INTO contact
( member_id
, contact_type
, first_name
, last_name
, created_by
, last_updated_by )
VALUES
( CURRVAL('member_member_id_seq')                 -- member_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'CONTACT'
  AND      common_lookup_type = 'CUSTOMER')       -- contact_type
,'Ginny'                                          -- first_name
,'Potter'                                         -- last_name
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'DBA1')             -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'DBA1')             -- last_updated_by
);

-- ------------------------------------------------------------------
-- Insert into address.
-- ------------------------------------------------------------------
INSERT INTO address
( contact_id
, address_type
, city
, state_province
, postal_code
, created_by
, last_updated_by )
VALUES
( CURRVAL('contact_contact_id_seq')               -- contact_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_type = 'HOME')           -- address_type
,'Provo'                                          -- city
,'Utah'                                           -- state_province
,'84601'                                          -- postal_code
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'DBA1')             -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'DBA1')             -- last_updated_by
);

-- ------------------------------------------------------------------
-- Insert into street_address.
-- ------------------------------------------------------------------
INSERT INTO street_address
( address_id
, street_address
, created_by
, last_updated_by )
VALUES
( CURRVAL('address_address_id_seq')               -- address_id
,'900 E 300 N'                                    -- street_address
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'DBA1')             -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'DBA1')             -- last_updated_by
);

-- ------------------------------------------------------------------
-- Insert into telephone.
-- ------------------------------------------------------------------
INSERT INTO telephone
( contact_id
, address_id
, telephone_type
, country_code
, area_code
, telephone_number
, created_by
, last_updated_by )
 VALUES
( CURRVAL('contact_contact_id_seq')               -- address_id
, CURRVAL('address_address_id_seq')               -- contact_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'MULTIPLE'
  AND      common_lookup_type = 'HOME')           -- telephone_type
,'001'                                            -- country_code
,'408'                                            -- area_code
,'333-3333'                                       -- telephone_number
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'DBA1')             -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'DBA1')             -- last_updated_by
);

-- ------------------------------------------------------------------
--  Task #4: Insert a records for Lily Luna Potter.
-- -------------------------------------------------------------------

-- ------------------------------------------------------------------
-- Insert into contact.
-- ------------------------------------------------------------------
INSERT INTO contact
( member_id
, contact_type
, first_name
, middle_name
, last_name
, created_by
, last_updated_by )
VALUES
( CURRVAL('member_member_id_seq')                 -- member_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'CONTACT'
  AND      common_lookup_type = 'CUSTOMER')       -- contact_type
,'Lily'                                           -- first_name
,'Luna'                                           -- middle_name
,'Potter'                                         -- last_name
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

-- ------------------------------------------------------------------
-- Insert into address.
-- ------------------------------------------------------------------
INSERT INTO address
( contact_id
, address_type
, city
, state_province
, postal_code
, created_by
, last_updated_by )
VALUES
( CURRVAL('contact_contact_id_seq')               -- contact_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_type = 'HOME')           -- address_type
,'Provo'                                          -- city
,'Utah'                                           -- state_province
,'84601'                                          -- postal_code
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'DBA1')             -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'DBA1')             -- last_updated_by
);

-- ------------------------------------------------------------------
-- Insert into street_address.
-- ------------------------------------------------------------------
INSERT INTO street_address
( address_id
, street_address
, created_by
, last_updated_by )
VALUES
( CURRVAL('address_address_id_seq')               -- address_id
,'900 E 300 N'                                    -- street_address
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'DBA1')            -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'DBA1')            -- last_updated_by
);

-- ------------------------------------------------------------------
-- Insert into telephone.
-- ------------------------------------------------------------------
INSERT INTO telephone
( contact_id
, address_id
, telephone_type
, country_code
, area_code
, telephone_number
, created_by
, last_updated_by )
 VALUES
( CURRVAL('contact_contact_id_seq')               -- contact_id
, CURRVAL('address_address_id_seq')               -- address_id
,(SELECT   common_lookup_id
  FROM     common_lookup
  WHERE    common_lookup_context = 'MULTIPLE'
  AND      common_lookup_type = 'HOME')           -- telephone_type
,'001'                                            -- country_code
,'408'                                            -- area_code
,'333-3333'                                       -- telephone_number
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- created_by
,(SELECT   system_user_id
  FROM     system_user
  WHERE    system_user_name = 'SYSADMIN')         -- last_updated_by
);

-- ------------------------------------------------------------------
--  Program Name:   apply_lab6_step2.sql
--  Lab Assignment: Lab #6
--  Program Author: Michael McLaughlin
--  Creation Date:  07-Nov-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
--
-- ------------------------------------------------------------------
-- Instructions:
-- ------------------------------------------------------------------
-- You first connect to the Postgres database with this syntax:
--
--   psql -U student -d videodb -W
--
-- Then, you call this script with the following syntax:
--
--   psql> \i apply_lab6_step6.sql
--
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
--  Task #1: Insert a rental agreement with two rental items.
-- -------------------------------------------------------------------
INSERT INTO rental
( customer_id
, check_out_date
, return_date
, created_by
, last_updated_by )
VALUES
((SELECT   contact_id
  FROM     contact
  WHERE    last_name = 'Potter'
  AND      first_name = 'Harry')
, CURRENT_DATE
, CURRENT_DATE + INTERVAL '1 day'
, 1001
, 1001 );

-- One rental item.
INSERT INTO rental_item
( rental_id
, item_id
, created_by
, last_updated_by )
VALUES
((SELECT   r.rental_id
  FROM     rental r
  ,        contact c
  WHERE    r.customer_id = c.contact_id
  AND      c.last_name = 'Potter'
  AND      c.first_name = 'Harry')
,(SELECT   i.item_id
  FROM     item i INNER JOIN common_lookup cl
  ON       i.item_type = cl.common_lookup_id
  WHERE    i.item_title = 'Toy Story 4'
  AND      cl.common_lookup_type = 'BLU-RAY')
, 1001
, 1001 );

-- Second rental item.
INSERT INTO rental_item
( rental_id
, item_id
, created_by
, last_updated_by )
VALUES
((SELECT   r.rental_id
  FROM     rental r
  ,        contact c
  WHERE    r.customer_id = c.contact_id
  AND      c.last_name = 'Potter'
  AND      c.first_name = 'Harry')
,(SELECT   i.item_id
  FROM     item i INNER JOIN common_lookup cl
  ON       i.item_type = cl.common_lookup_id
  WHERE    i.item_title = 'X-Men: Dark Phoenix'
  AND      cl.common_lookup_type = 'BLU-RAY')
, 1001
, 1001 );

-- ------------------------------------------------------------------
--  Task #2: Insert a rental agreement with one rental item.
-- -------------------------------------------------------------------
INSERT INTO rental
( customer_id
, check_out_date
, return_date
, created_by
, last_updated_by )
VALUES
((SELECT   contact_id
  FROM     contact
  WHERE    last_name = 'Potter'
  AND      first_name = 'Ginny')
, CURRENT_DATE
, CURRENT_DATE + INTERVAL '3 day'
, 1001
, 1001 );

-- One rental item.
INSERT INTO rental_item
( rental_id
, item_id
, created_by
, last_updated_by )
VALUES
((SELECT   r.rental_id
  FROM     rental r
  ,        contact c
  WHERE    r.customer_id = c.contact_id
  AND      c.last_name = 'Potter'
  AND      c.first_name = 'Ginny')
,(SELECT   i.item_id
  FROM     item i INNER JOIN common_lookup cl
  ON       i.item_type = cl.common_lookup_id
  WHERE    i.item_title = 'Toy Story 4'
  AND      cl.common_lookup_type = 'BLU-RAY')
, 1001
, 1001 );

-- ------------------------------------------------------------------
--  Task #3: Insert a rental agreement with one rental item.
-- -------------------------------------------------------------------
INSERT INTO rental
( customer_id
, check_out_date
, return_date
, created_by
, last_updated_by )
VALUES
((SELECT   contact_id
  FROM     contact
  WHERE    last_name = 'Potter'
  AND      first_name = 'Lily')
, CURRENT_DATE
, CURRENT_DATE + INTERVAL '5 day'
, 1001
, 1001 );

-- One rental item.
INSERT INTO rental_item
( rental_id
, item_id
, created_by
, last_updated_by )
VALUES
((SELECT   r.rental_id
  FROM     rental r
  ,        contact c
  WHERE    r.customer_id = c.contact_id
  AND      c.last_name = 'Potter'
  AND      c.first_name = 'Lily')
,(SELECT   i.item_id
  FROM     item i INNER JOIN common_lookup cl
  ON       i.item_type = cl.common_lookup_id
  WHERE    i.item_title = 'X-Men: Dark Phoenix'
  AND      cl.common_lookup_type = 'BLU-RAY')
, 1001
, 1001 );

-- ------------------------------------------------------------------
--  Program Name:   apply_lab6_step2.sql
--  Lab Assignment: Lab #6
--  Program Author: Michael McLaughlin
--  Creation Date:  05-Nov-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
--
-- ------------------------------------------------------------------
-- Instructions:
-- ------------------------------------------------------------------
-- You first connect to the Postgres database with this syntax:
--
--   psql -U student -d videodb -W
--
-- Then, you call this script with the following syntax:
--
--   psql> \i apply_lab6_step2.sql
--
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
--  Task #1: Drop two indexes from the common_lookup table.
--            1. nq_common_lookup_n1
--            2. uq_common_lookup_u1
-- -------------------------------------------------------------------

-- Drop unique index on the context name.
DROP INDEX IF EXISTS nq_common_lookup_n1;

-- Drop unique index on the context name.
DROP INDEX IF EXISTS uq_common_lookup_u1;

-- ------------------------------------------------------------------
--  Task #2: Add the three new columns to the common_lookup table:
--            1. common_lookup_table
--            2. common_lookup_column
--            3. common_lookup_code
-- ------------------------------------------------------------------

-- Alter table and add common_lookup_table column.
ALTER TABLE common_lookup
ADD COLUMN common_lookup_table varchar(30);

-- Alter table and add common_lookup_table column.
ALTER TABLE common_lookup
ADD COLUMN common_lookup_column varchar(30);

-- Alter table and add common_lookup_table column.
ALTER TABLE common_lookup
ADD COLUMN common_lookup_code varchar(2);

-- ------------------------------------------------------------------
--  Task #3: Update the common_lookup_table and common_lookup_column
--           columns with data from the common_lookup_context
--           column and a literal ADDRESS or ADDRESS_TYPE value for
--           those rows where the common_lookup_context value is
--           an uppercase MULTIPLE value.
-- ------------------------------------------------------------------

UPDATE common_lookup
SET    common_lookup_table =
        CASE
          WHEN common_lookup_context = 'MULTIPLE' THEN 'ADDRESS'
          ELSE common_lookup_context
        END
,      common_lookup_column =
        CASE
          WHEN common_lookup_context = 'MULTIPLE' THEN 'ADDRESS_TYPE'
          WHEN common_lookup_context = 'MEMBER' AND
               common_lookup_type LIKE '%CARD' THEN 'CREDIT_CARD_TYPE'
          ELSE common_lookup_context || '_TYPE'
        END;

-- ------------------------------------------------------------------
--  Task #4: Drop the common_lookup_context column from the 
--           common_lookup table.
-- ------------------------------------------------------------------

ALTER TABLE common_lookup
DROP COLUMN common_lookup_context;

-- ------------------------------------------------------------------
--  Task #5: Add two columns for the telephone table to the 
--           common_lookup table.
-- ------------------------------------------------------------------
INSERT INTO common_lookup
( common_lookup_table
, common_lookup_column
, common_lookup_type
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('TELEPHONE'                  -- common_lookup_table
,'TELEPHONE_TYPE'             -- common_lookup_column
,'HOME'                       -- common_lookup_type
,'Home'                       -- common_lookup_meaning
, 1                           -- created_by
, 1                           -- last_updated_by
);

INSERT INTO common_lookup
( common_lookup_table
, common_lookup_column
, common_lookup_type
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('TELEPHONE'                  -- common_lookup_table
,'TELEPHONE_TYPE'             -- common_lookup_column
,'WORK'                       -- common_lookup_type
,'Work'                       -- common_lookup_meaning
, 1                           -- created_by
, 1                           -- last_updated_by
);

-- ------------------------------------------------------------------
--  Task #6: Update the telephone_type foreign key values in the
--           telephone table by using an UPDATE statement.
-- ------------------------------------------------------------------

UPDATE telephone
SET    telephone_type =
        (SELECT cl1.common_lookup_id
	 FROM   common_lookup cl1 JOIN common_lookup cl2
	 ON     cl1.common_lookup_type = cl2.common_lookup_type
	 WHERE  cl1.common_lookup_table = 'TELEPHONE'
	 AND    cl1.common_lookup_column = 'TELEPHONE_TYPE'
	 AND    cl2.common_lookup_table = 'ADDRESS'
	 AND    cl2.common_lookup_column = 'ADDRESS_TYPE'
	 AND    telephone_type = cl2.common_lookup_id);

-- ------------------------------------------------------------------
--  Task #7: Alter the common_lookup table to add a not null
--           constraint to the following columns:
--            1. common_lookup_table
--            2. common_lookup_column
--           Create a uq_common_lookup unique index on three columns:
--            1. common_lookup_table
--            2. common_lookup_column
--            3. common_lookup_type
-- ------------------------------------------------------------------

ALTER TABLE common_lookup
ALTER COLUMN common_lookup_table SET NOT NULL;

ALTER TABLE common_lookup
ALTER COLUMN common_lookup_column SET NOT NULL;

CREATE UNIQUE INDEX uq_common_lookup 
ON common_lookup (common_lookup_table, common_lookup_column, common_lookup_type);

-- ------------------------------------------------------------------
--  Program Name:   apply_lab6_step8.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  11-Oct-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  21-Feb-2022    Updated for PostgreSQL.
-- ==================================================================
--  This creates the system_user table and system_user_s1 sequences.
-- ------------------------------------------------------------------
--    Create and assign bind variable for table name.
-- ==================================================================
SET SESSION "videodb.table_name" = 'price';
SET CLIENT_MIN_MESSAGES TO ERROR;

--  Verify table name.
SELECT current_setting('videodb.table_name');

-- ------------------------------------------------------------------
--  Conditionally drop table.
-- ------------------------------------------------------------------
DROP TABLE IF EXISTS price CASCADE;

-- ------------------------------------------------------------------
--  Create table.
-- -------------------------------------------------------------------
CREATE TABLE price
( price_id              SERIAL
, item_id               INTEGER
, price_type            INTEGER
, active_flag           VARCHAR(1)  CHECK (active_flag IN ('Y','N'))
, start_date            DATE
, end_date              DATE
, amount                NUMERIC(5,2)
, created_by            INTEGER  NOT NULL
, creation_date         TIMESTAMP  WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, last_updated_by       INTEGER  NOT NULL
, last_update_date      TIMESTAMP  WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
, PRIMARY KEY (price_id)
, CONSTRAINT fk_price_1    FOREIGN KEY (created_by) REFERENCES system_user (system_user_id)
, CONSTRAINT fk_price_2    FOREIGN KEY (last_updated_by) REFERENCES system_user (system_user_id));

-- Alter the sequence by restarting it at 1001.
ALTER SEQUENCE price_price_id_seq RESTART WITH 1001;

-- ------------------------------------------------------------------
--  Program Name:   apply_lab8_step1.sql
--  Lab Assignment: Lab #8
--  Program Author: Michael McLaughlin
--  Creation Date:  05-Nov-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
--
-- ------------------------------------------------------------------
-- Instructions:
-- ------------------------------------------------------------------
-- You first connect to the Postgres database with this syntax:
--
--   psql -U student -d videodb -W
--
-- Then, you call this script with the following syntax:
--
--   psql> \i apply_lab8_step1.sql
--
-- ------------------------------------------------------------------

INSERT INTO common_lookup
( common_lookup_table
, common_lookup_column
, common_lookup_type
, common_lookup_code
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('PRICE'
,'PRICE_TYPE'
,'1-DAY RENTAL'
,'1'
,'1-Day Rental'
, 1001
, 1001 );

INSERT INTO common_lookup
( common_lookup_table
, common_lookup_column
, common_lookup_type
, common_lookup_code
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('PRICE'
,'PRICE_TYPE'
,'3-DAY RENTAL'
,'3'
,'3-Day Rental'
, 1001
, 1001 );

INSERT INTO common_lookup
( common_lookup_table
, common_lookup_column
, common_lookup_type
, common_lookup_code
, common_lookup_meaning
, created_by
, last_updated_by )
VALUES
('PRICE'
,'PRICE_TYPE'
,'5-DAY RENTAL'
,'5'
,'5-Day Rental'
, 1001
, 1001 );

-- ------------------------------------------------------------------
--  Task #1: Add rows to the price table.
-- ------------------------------------------------------------------

INSERT INTO price
( item_id
, price_type
, active_flag
, start_date
, end_date
, amount
, created_by
, last_updated_by )
( SELECT   il.item_id
  ,        il.price_type
  ,        il.active_flag
  ,        il.start_date
  ,        il.end_date
  ,        il.amount
  ,        il.created_by
  ,        il.last_updated_by
  FROM
   (SELECT   i.item_id
    ,        af.active_flag
    ,        cl.common_lookup_id AS price_type
    ,        CASE
	           WHEN current_date - i.release_date <= 30 OR
                    current_date - i.release_date > 30  AND active_flag = 'N'
			   THEN i.release_date
	           ELSE i.release_date + interval '31 day'
             END::date AS start_date
    ,        CASE
               WHEN current_date - i.release_date > 30 AND active_flag = 'N'
			   THEN i.release_date + interval '30 day'
             END::date AS end_date
    ,        CASE
               WHEN current_date - release_date > 30 AND active_flag = 'Y' THEN 
	             CASE
                   WHEN dr.rental_days = '1' THEN 1
	               WHEN dr.rental_days = '3' THEN 3
                   WHEN dr.rental_days = '5' THEN 5
                 END
               ELSE
	             CASE
                   WHEN dr.rental_days = '1' THEN 5
	               WHEN dr.rental_days = '3' THEN 10
                   WHEN dr.rental_days = '5' THEN 15
                 END
             END AS amount
    ,        1001 AS created_by
    ,        1001 AS last_updated_by
    FROM     item i CROSS JOIN
            (SELECT 'Y' AS active_flag
             UNION ALL
             SELECT 'N' AS active_flag) af CROSS JOIN
            (SELECT '1' AS rental_days
             UNION ALL
             SELECT '3' AS rental_days
             UNION ALL
             SELECT '5' AS rental_days) dr INNER JOIN
             common_lookup cl ON dr.rental_days = SUBSTR(cl.common_lookup_type,1,1)
    WHERE    cl.common_lookup_table = 'PRICE'
    AND      cl.common_lookup_column = 'PRICE_TYPE'
    AND NOT ((current_date - i.release_date <= 30) AND (active_flag = 'N'))) il);

SELECT * FROM price;

-- ------------------------------------------------------------------
--  Task #2: Add not null constraint to the price_type column.
-- ------------------------------------------------------------------

ALTER TABLE price
ALTER COLUMN price_type SET NOT NULL;

-- ------------------------------------------------------------------
--  Program Name:   apply_lab8_step2.sql
--  Lab Assignment: Lab #8
--  Program Author: Michael McLaughlin
--  Creation Date:  10-Nov-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
--
-- ------------------------------------------------------------------
-- Instructions:
-- ------------------------------------------------------------------
-- You first connect to the Postgres database with this syntax:
--
--   psql -U student -d videodb -W
--
-- Then, you call this script with the following syntax:
--
--   psql> \i apply_lab8_step2.sql
--
-- ------------------------------------------------------------------

-- ------------------------------------------------------------------
--  Task #1: Update rental_item_price column with data.
-- ------------------------------------------------------------------

UPDATE   rental_item ri
SET      rental_item_price =
          (SELECT   p.amount
           FROM     price p INNER JOIN common_lookup cl1
           ON       p.price_type = cl1.common_lookup_id CROSS JOIN rental r
                    CROSS JOIN common_lookup cl2
           WHERE    p.item_id = ri.item_id
           AND      ri.rental_id = r.rental_id
           AND      ri.rental_item_type = cl2.common_lookup_id
           AND      cl1.common_lookup_code = cl2.common_lookup_code
           AND      r.check_out_date
                      BETWEEN p.start_date
                      AND COALESCE(p.end_date,current_date + INTERVAL '3 day'));


-- ------------------------------------------------------------------
--  Program Name:   apply_lab8_step3.sql
--  Lab Assignment: Lab #8
--  Program Author: Michael McLaughlin
--  Creation Date:  11-Nov-2019
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
--
-- ------------------------------------------------------------------
-- Instructions:
-- ------------------------------------------------------------------
-- You first connect to the Postgres database with this syntax:
--
--   psql -U student -d videodb -W
--
-- Then, you call this script with the following syntax:
--
--   psql> \i apply_lab6_step3.sql
--
-- ------------------------------------------------------------------

select rental_item_id, rental_item_price
from   rental_item;

-- ------------------------------------------------------------------
--  Task #1: Add not null constraint.
-- -------------------------------------------------------------------

ALTER TABLE rental_item
ALTER COLUMN rental_item_price SET NOT NULL;














