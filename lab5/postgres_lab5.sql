-- part 1
/*
Create a lyric record type
first member should be named days with a variable length of 8 characters in length.
second member should be named gift with a variable length of 24 characters in length.
*/
CREATE TYPE lyric AS
( 
    days VARCHAR(8),
    gift VARCHAR(24)
);

-- part 2
/*
Create a twelve_days function

accepts a variable length string of 8 characters in length with the values ( 'first','second','third','fourth','fifth','sixth'
,'seventh','eighth','nineth','tenth','eleventh','twelfth')

accepts an array of lyrics with the following structure values:
    days => 'and a', gift => 'Partridge in a pear tree'
    , days => 'Two',   gift => 'Turtle doves'
    , days => 'Three', gift => 'French hens'
    , days => 'Four',  gift => 'Calling birds'
    , days => 'Five',  gift => 'Golden rings'
    , days => 'Six',   gift => 'Geese a laying'
    , days => 'Seven', gift => 'Swans a swimming'
    , days => 'Eight', gift => 'Maids a milking'
    , days => 'Nine',  gift => 'Ladies dancing'
    , days => 'Ten',   gift => 'Lords a leaping'
    , days => 'Eleven',gift => 'Pipers piping'
    , days => 'Twelve',gift => 'Drummers drumming'

returns a variable length string 36 characters in length as an array with line breaks between verses like:
    On the first day of Christmas
    my true love sent to me:
    -A Partridge in a pear tree

    On the second day of Christmas
    my true love sent to me:
    -Two Turtle doves
    -and a Partridge in a pear tree

    ...

    On the twelfth day of Christmas
    my true love sent to me:
    -Twelve Drummers drumming
    -Eleven Pipers piping
    -Ten Lords a leaping
    -Nine Ladies dancing
    -Eight Maids a milking
    -Seven Swans a swimming
    -Six Geese a laying
    -Five Golden rings
    -Four Calling birds
    -Three French hens
    -Two Turtle doves
    -and a Partridge in a pear tree
*/
CREATE FUNCTION twelve_days
  ( IN pv_days   VARCHAR(8)[]
  , IN pv_gifts  LYRIC[] ) RETURNS VARCHAR[] AS
$$  
DECLARE 
  lv_retval  VARCHAR[];  -- Initialize the collection of lyrics as an array of variable length strings.
BEGIN
  -- Loop through the provided days.
  FOR i IN 1..ARRAY_LENGTH(pv_days, 1) LOOP
    -- Add the 'On the nth day of Christmas, my true love sent to me' to lv_retval.
    lv_retval := ARRAY_APPEND(lv_retval, 'On the ' || pv_days[i] || ' day of Christmas');
    lv_retval := ARRAY_APPEND(lv_retval, 'my true love sent to me:');
 
    -- Loop through the lyrics in reverse order.
    FOR j IN REVERSE i..1 LOOP
      -- Replace 'and a' with 'A' for the first day of Christmas.
      IF i = 1 AND j = i THEN
        lv_retval := ARRAY_APPEND(lv_retval, '-A ' || pv_gifts[j].gift);
      ELSE
        lv_retval := ARRAY_APPEND(lv_retval, '-' || pv_gifts[j].gift);
      END IF;
    END LOOP;
 
    -- Add a line break for each verse.
    lv_retval := ARRAY_APPEND(lv_retval, '');
  END LOOP;
 
  -- Return the song's lyrics.
  RETURN lv_retval;
END;
$$ LANGUAGE plpgsql;


-- part 3
/*
Use the following query to call and test the twelve_days function.
*/
SELECT UNNEST(twelve_days(ARRAY['first','second','third','fourth'
                          ,'fifth','sixth','seventh','eighth'
                          ,'nineth','tenth','eleventh','twelfth']
                         ,ARRAY[('and a','Partridge in a pear tree')::lyric
                          ,('Two','Turtle doves')::lyric
                          ,('Three','French hens')::lyric
                          ,('Four','Calling birds')::lyric
                          ,('Five','Golden rings')::lyric
                          ,('Six','Geese a laying')::lyric
                          ,('Seven','Swans a swimming')::lyric
                          ,('Eight','Maids a milking')::lyric
                          ,('Nine','Ladies dancing')::lyric
                          ,('Ten','Lords a leaping')::lyric
                          ,('Eleven','Pipers piping')::lyric
                          ,('Twelve','Drummers drumming')::lyric])) AS "12-Days of Christmas";


-- part 4 TEST CASE
/*
Write a DO-block that tests the twelve_days function 
like the query provided above. Use the following 
DO-block shell and replace the <<<element>>> 
placeholders with functional code.
*/
DO
$$
DECLARE
  /* Declare an lv_days array and initialize it with values. */
  lv_days VARCHAR(8)[] := ARRAY['first','second','third','fourth','fifth','sixth','seventh','eighth','nineth','tenth','eleventh','twelfth'];
							
  /* Declare an lv_gifts array and initialize it with values. */
  lv_gifts LYRIC[] := ARRAY[('and a','Partridge in a pear tree')::lyric,
                            ('Two','Turtle doves')::lyric,
                            ('Three','French hens')::lyric,
                            ('Four','Calling birds')::lyric,
                            ('Five','Golden rings')::lyric,
                            ('Six','Geese a laying')::lyric,
                            ('Seven','Swans a swimming')::lyric,
                            ('Eight','Maids a milking')::lyric,
                            ('Nine','Ladies dancing')::lyric,
                            ('Ten','Lords a leaping')::lyric,
                            ('Eleven','Pipers piping')::lyric,
                            ('Twelve','Drummers drumming')::lyric];

  /* Declare an lv_song array without initializing values. */
  lv_song VARCHAR[];

BEGIN
  /* Call the twelve_days function and assign the results to a local song variable. */
  lv_song := twelve_days(lv_days, lv_gifts);
  
  /* Read the lines from the local song variable. */
  FOR i IN 1..ARRAY_LENGTH(lv_song, 1) LOOP
    RAISE NOTICE '%', lv_song[i];
  END LOOP;
END;
$$
