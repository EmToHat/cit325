DO
$$
BEGIN
    /*RAISE NOTICE '[%]','Ascending Loop';*/
  /* Ascending loops.*/
     for counter in 1..10 loop
	/*RAISE NOTICE 'counter: %', counter;*/
    RAISE NOTICE '[%]', counter;
   end loop;
 
    /*RAISE NOTICE '[%]','Descending Loop';*/
  /* Descending loop. */
  for counter in reverse 10..1 loop
	/*RAISE NOTICE 'counter: %', counter;*/
    RAISE NOTICE '[%]', counter;
   end loop;
END;
$$;


/*
OUTPUT

NOTICE: [1]
NOTICE: [2]
NOTICE: [3]
NOTICE: [4]
NOTICE: [5]
NOTICE: [6]
NOTICE: [7]
NOTICE: [8]
NOTICE: [9]
NOTICE: [10]
NOTICE: [10]
NOTICE: [9]
NOTICE: [8]
NOTICE: [7]
NOTICE: [6]
NOTICE: [5]
NOTICE: [4]
NOTICE: [3]
NOTICE: [2]
NOTICE: [1]
DO
*/ 