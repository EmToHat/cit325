-- Preparation
-- run video_store.sql file

-- part 1
-- Create the modified sample cartoon_user, grandma, and tweetie_bird tables and populate them with values.

-- DROP cartoon_user table w/conditions
DROP TABLE IF EXISTS cartoon_user CASCADE; 

-- CREATE cartoon_user table
CREATE TABLE cartoon_user
( cartoon_user_id     SERIAL
, cartoon_user_name   VARCHAR(30)   NOT NULL
, PRIMARY KEY (cartoon_user_id)
);

-- INSERT INTO the cartoon_user table
INSERT INTO cartoon_user
( cartoon_user_name )
VALUES 
  ('Bugs Bunny')
  , ('Wylie Coyote')
  , ('Elmer Fudd');

-- DROP grandma table w/conditions.
DROP TABLE IF EXIST grandma CASCADE;

-- CREATE the table.
CREATE TABLE grandma
( grandma_id      SERIAL
, grandma_house   VARCHAR(30)     NOT NULL
, created_by      INTEGER)
