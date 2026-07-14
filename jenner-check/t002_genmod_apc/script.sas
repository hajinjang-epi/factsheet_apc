/* Age-period-cohort Poisson model, from apc_10082019.sas.
   PROC GENMOD call reproduced unchanged from the upstream script:
   log-link Poisson regression of high-risk drinking on cohort (c), age
   category and period, each classed with an explicit reference level, plus
   an LSMEANS request over the age categories. */
proc genmod data=alco;
  where sex=2;
  class c(ref="1975") agecat(ref="1") period(ref="2005");
  model dr_high_risk = c agecat period / dist=poisson link=log;
  lsmeans agecat;
run;
