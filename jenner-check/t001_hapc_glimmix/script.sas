/* HAPC-CCREM of current smoking, from apc_10082019.sas.
   The upstream script reads its analysis dataset from an external libname
   (libname a 'd:\SASfiles'; ... data apc1; set a.apcupdate;), which the repo
   does not ship, so this bundle builds a small stand-in with the columns the
   model reads (id year age smk sex cohort_cat5) and derives the centered age
   terms exactly as the upstream DATA step does. The PROC GLIMMIX call below
   is the author's own, unchanged: cross-classified random effects on YEAR and
   COHORT_CAT5, binary response SMK, fixed effects on centered age. */
data apc1;
  input id year age smk sex cohort_cat5;
  age_c = age - 44;
  age_c2 = age_c*age_c;
datalines;
1 1998 25 1 1 5
2 2001 40 0 2 8
3 2005 55 1 1 10
4 2010 60 0 2 12
5 2017 30 1 2 6
6 1998 45 0 1 9
7 2005 50 1 2 11
8 2010 35 0 1 7
;
run;

proc glimmix data=apc1 maxopt=25000;
      class YEAR COHORT_CAT5;
      model SMK (event='1') = AGE_C AGE_C2 /solution CL
      dist=binary;
      random YEAR COHORT_CAT5 / solution;
      covtest GLM / WALD;
      NLOPTIONS TECHNIQUE=NRRIDG;
      title "Current Smoking Proportion Trends, KNHANES 1998-2017";
run;
