options obs=100;  /* cap input rows for the captured run */

/* The upstream 'alco' dataset is derived from the external-libname data
   (a.apcupdate) that the repo does not ship. This autoexec builds a small
   stand-in with the columns the PROC GENMOD model classes and reads
   (sex dr_high_risk c agecat period). The PROC GENMOD call in script.sas is
   the author's own, unchanged. */
data alco;
  input id sex dr_high_risk c agecat period;
datalines;
1 2 1 1975 1 2005
2 2 0 1980 3 2010
3 2 1 1970 5 2013
4 2 0 1990 7 2016
5 2 1 1985 2 2007
6 2 0 1975 4 2005
7 2 1 1960 8 2017
8 2 0 1995 6 2010
;
run;
