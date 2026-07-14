options obs=100;  /* cap input rows for the captured run */

/* The upstream apc6 dataset comes from the external-libname survey-cycle
   merges (b.hn98_all ... b.hn17_all) that the repo does not ship. This
   autoexec builds a small stand-in carrying the per-cycle weight columns the
   trend-weight DATA step reads (wt_itv_t wt_bhv_t wt_bhv wt_itv wt_itvex)
   plus id year age sex smk. The DATA apc7 weight-assignment logic and the
   MEANS calls in script.sas are the author's own, unchanged. */
data apc6;
  input id year age sex smk wt_itv_t wt_bhv_t wt_bhv wt_itv wt_itvex;
datalines;
1 1998 25 1 1 1.20 . . . .
2 2001 40 2 0 . 0.95 . . .
3 2005 55 1 1 . . 1.10 . .
4 2007 60 2 0 . . . 0.88 .
5 2008 33 2 1 . . . 1.05 .
6 2010 47 1 0 . . . . 1.30
7 2015 70 1 1 . . . . 0.77
8 2017 22 2 0 . . . . 1.44
;
run;
