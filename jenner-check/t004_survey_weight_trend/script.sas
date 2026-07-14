/* Trend survey-weight construction, from apc_10082019.sas (DATA apc7).
   Each K-NHANES cycle carries a different weight variable, so the author maps
   the year onto the correct per-cycle weight, rescales the half-cycle 2007
   weight, and derives birth = year - age. Reproduced unchanged from the
   upstream DATA step, followed by the author's own MEANS checks. */
data apc7; set apc6;
if year=1998 then wt_trend=wt_itv_t;
else if year=2001 then wt_trend=wt_bhv_t;
else if year=2005 then wt_trend=wt_bhv;
else if year in(2007,2008, 2009) then wt_trend=wt_itv;
else wt_trend=wt_itvex;

/* 14 survey years */
if year=2007 then wt_trend_wt=wt_trend*0.5/13.5;
else wt_trend_wt=wt_trend*1/13.5;

birth = year-age;
run;

proc means data=apc7; where smk ne .; var year age wt_trend wt_trend_wt; run;
proc means data=apc7; var birth; run;
