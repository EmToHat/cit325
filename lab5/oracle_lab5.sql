-- part 1
/*
create a user-defined type (UDT) data type named days 
with a variable length string of 8 characters in length.
 */
CREATE OR REPLACE TYPE days IS TABLE OF VARCHAR2(8);
/

-- part 2
/*
create a user-defined type (UDT) data type named song 
with a variable length string of 36 characters in length.
 */
CREATE OR REPLACE TYPE song IS TABLE OF VARCHAR2(36);
/

-- part 3
/*
create a user-defined type (UDT) data type named lyric
give it two members day, and gift
day should have a variable length string of 8 characters in length
gift should have a variable length string of 24 characters in length
 */
CREATE OR REPLACE TYPE lyric IS OBJECT (day VARCHAR2(8), gift VARCHAR2(24));
/

-- part 4
/*
create a user-defined type (UDT) data type named lyrics
lyrics should be a table of lyric
 */
CREATE OR REPLACE TYPE lyrics IS TABLE OF LYRIC;
/

-- part 5
-- Function
CREATE OR REPLACE FUNCTION twelve_days(pv_days DAYS, pv_gifts LYRICS) RETURN song IS
/* Initialize the collection of lyrics. */
   lv_retval SONG := song ();

/* Local procedure to add to the song. */
   PROCEDURE ADD(pv_input VARCHAR2) IS
   BEGIN
      lv_retval.EXTEND;
      lv_retval (lv_retval.COUNT) := pv_input;
   END ADD;

BEGIN
   FOR i IN 1..pv_days.COUNT LOOP
      ADD ('On the ' || pv_days (i) || ' day of Christmas');
      ADD ('my true love sent to me:');

      FOR j IN REVERSE 1..i LOOP
         IF j = 1 AND i <> 1 THEN
            ADD ('and a ' || pv_gifts(j).gift);
         ELSE
            ADD (pv_gifts(j).gift);
         END IF;
      END LOOP;
      ADD (CHR(10));
   END LOOP;
   RETURN lv_retval;
END;
/

-- part 6
/*
Create a query, provided as a sample, that calls 
the twelve_days function and unnest the result 
from the twelve_days function.
 */
SELECT
  column_value AS "12-Days of Christmas"
FROM
  TABLE (
    twelve_days (
      days (
        'first',
        'second',
        'third',
        'fourth',
        'fifth',
        'sixth',
        'seventh',
        'eighth',
        'nineth',
        'tenth',
        'eleventh',
        'twelfth'
      ),
      lyrics (
        lyric (
          days => 'and a',
          gift => 'Partridge in a pear tree'
        ),
        lyric (days => 'Two', gift => 'Turtle doves'),
        lyric (days => 'Three', gift => 'French hens'),
        lyric (days => 'Four', gift => 'Calling birds'),
        lyric (days => 'Five', gift => 'Golden rings'),
        lyric (days => 'Six', gift => 'Geese a laying'),
        lyric (days => 'Seven', gift => 'Swans a swimming'),
        lyric (days => 'Eight', gift => 'Maids a milking'),
        lyric (days => 'Nine', gift => 'Ladies dancing'),
        lyric (days => 'Ten', gift => 'Lords a leaping'),
        lyric (days => 'Eleven', gift => 'Pipers piping'),
        lyric (days => 'Twelve', gift => 'Drummers drumming')
      )
    )
  );

-- part 7 TEST CASE
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
   lv_days DAYS := DAYS('first','second','third','fourth','fifth','sixth','seventh','eighth','nineth','tenth','eleventh','twelfth');

   lv_gifts LYRICS := LYRICS (
      LYRIC (days => 'and a', gift => 'Partridge in a pear tree'),
      LYRIC (days => 'Two', gift => 'Turtle doves'),
      LYRIC (days => 'Three', gift => 'French hens'),
      LYRIC (days => 'Four', gift => 'Calling birds'),
      LYRIC (days => 'Five', gift => 'Golden rings'),
      LYRIC (days => 'Six', gift => 'Geese a laying'),
      LYRIC (days => 'Seven', gift => 'Swans a swimming'),
      LYRIC (days => 'Eight', gift => 'Maids a milking'),
      LYRIC (days => 'Nine', gift => 'Ladies dancing'),
      LYRIC (days => 'Ten', gift => 'Lords a leaping'),
      LYRIC (days => 'Eleven', gift => 'Pipers piping'),
      LYRIC (days => 'Twelve', gift => 'Drummers drumming')
   );

   lv_song SONG;

BEGIN
   lv_song := twelve_days (lv_days, lv_gifts);

   FOR i IN 1..lv_song.COUNT LOOP 
      DBMS_OUTPUT.PUT_LINE(lv_song (i));
   END LOOP; 
END;
/