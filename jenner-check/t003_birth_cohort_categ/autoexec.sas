options obs=100;  /* cap input rows for the captured run */

/* The upstream apc7 dataset comes from the external-libname merges the repo
   does not ship. This autoexec builds a small stand-in carrying the columns
   the categorization DATA step reads (id year age sex smk) and derives the
   author's birth = year - age exactly as the upstream apc7 step does. The
   DATA apc8 categorization and the FREQ/MEANS calls in script.sas are the
   author's own, unchanged. */
data apc7;
  input id year age sex smk;
  birth = year - age;
datalines;
1 1998 25 1 1
2 2001 40 2 0
3 2005 55 1 1
4 2007 60 2 0
5 2010 33 2 1
6 2012 47 1 0
7 2015 70 1 1
8 2017 22 2 0
9 1998 45 1 1
10 2005 51 2 0
;
run;
