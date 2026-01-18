
libname a 'd:\SASfiles';


/********* convert STATA data file to SAS *****/
/* data a.knhanes_apc; set apc;
run; */
/*  200713개의 관측값과 22개의 변수 */
/** update (modified data) ***/
/* data a.apcupdate; set apcupdate; run; */
/*  200713개의 관측값과 44개의 변수 */

/* read data */
/* data apc; set a.knhanes_apc; run; */ /*  200713개의 관측값과 22개의 변수 */
/* 14 years */

/* modified--read data */
data apc; set a.apcupdate; run; /* 200713개의 관측값과 44개의 변수 */

/* b/c updated data is missing cancer, cvd, pg variables, get from old data */
data apcshort; set a.knhanes_apc; 
keep id cancer cvd pg; run; /* 200713개의 관측값과 4개의 변수 */

proc sort data=apcshort; by id;
proc sort data=apc; by id;
run;
data apc2; 
merge apc apcshort;
by id;
run; /*   200713개의 관측값과 47개 변수 */

proc freq data=apc2; tables year cohort cohort_cat5 cohort_cat10; run;
/* age 13 missing */
  
/*** 1. eligibility **/

/******* delete if missing age ***/
data apc3; set apc2;
if age=. then delete;
run; /*   200700개의 관측값과 47개의 변수 */

/* 연령 19-79세 */
data apc4; set apc3;
if 19<=age<=79 ;
run; /* 145640개의 관측값과 47개의 변수 */

/**** delete if have cancer, cvd, or pregnant ****/
/* 암(변수명: cancer), 심혈관계질환자(변수명: cvd) 제외
임산/수유부(변수명: pg) 제외 */
data apc5; set apc4;
if cancer=1 then delete;
if cvd=1 then delete;
if pg=1 then delete;
run; /*   137260개의 관측값과 47개의 변수  */


libname b "D:\SASfiles\knhanes";

/* 1-2기는 _w , 3기부터는 기본가중치 */
/* weight 1-2기, wt_bhv_t, 3기 wt_bhv, 4기 wt_itv, 5-6기 wt_itvex */
/* 2007 1/2 */
data hn98; set b.hn98_all; keep id kstrata psu wt_itv wt_itv_t wt_bhv wt_bhv_t ; run;
data hn01; set b.hn01_all; keep id kstrata psu wt_bhv wt_bhv_t; run;
data hn05; set b.hn05_all; keep id kstrata psu wt_bhv ; run;
data hn07; set b.hn07_all; keep id kstrata psu he_bmi wt_itv; run;
data hn08; set b.hn08_all; keep id kstrata psu he_bmi wt_itv; run;
data hn09; set b.hn09_all; keep id kstrata psu he_bmi wt_itv; run;
data hn10; set b.hn10_all; keep id kstrata psu he_bmi wt_itvex; run;
data hn11; set b.hn11_all; keep id kstrata psu he_bmi wt_itvex; run;
data hn12; set b.hn12_all; keep id kstrata psu he_bmi wt_itvex; run;
data hn13; set b.hn13_all; keep id kstrata psu he_bmi wt_itvex; run;
data hn14; set b.hn14_all; keep id kstrata psu he_bmi wt_itvex; run;
data hn15; set b.hn15_all; keep id kstrata psu he_bmi wt_itvex; run;
data hn16; set b.hn16_all; keep id kstrata psu he_bmi wt_itvex; run;
data hn17; set b.hn17_all; keep id kstrata psu he_bmi wt_itvex; run;

proc sort data=hn98; by id;
proc sort data=hn01; by id;
proc sort data=hn05; by id;
proc sort data=hn07; by id;
proc sort data=hn08; by id;
proc sort data=hn09; by id;
proc sort data=hn10; by id;
proc sort data=hn11; by id;
proc sort data=hn12; by id;
proc sort data=hn13; by id;
proc sort data=hn14; by id;
proc sort data=hn15; by id;
proc sort data=hn16; by id;
proc sort data=hn17; by id; run;

data combine; 
merge hn98 hn01 hn05 hn07 hn08 hn09 hn10 hn11 hn12 hn13 hn14 hn15 hn16 hn17;
by id;
run;

proc sort data=apc5; by id; run;
data apc6; 
merge apc5(in=a) combine;
by id;
if a;
run; /*  137260개의 관측값과 55개의 변수 */

proc freq data=apc6; tables year age; run;
proc means data=apc6;
where smk ne . ;
class year;
var age wt_itv_t wt_bhv_t wt_bhv wt_itv wt_itvex; run;
/* 1998: wt_itv_t */
/* 2001: wt_bhv_t */
/* 2005: wt_bhv */
/* 2007, 2008, 2009: wt_itv */
/* 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017: wt_itvex */

/** 가중치 계산 **/
data apc7; set apc6;

if year=1998 then wt_trend=wt_itv_t;
else if year=2001 then wt_trend=wt_bhv_t;
else if year=2005 then wt_trend=wt_bhv;
else if year in(2007,2008, 2009) then wt_trend=wt_itv;
else wt_trend=wt_itvex;

/* 14개년도 */
if year=2007 then wt_trend_wt=wt_trend*0.5/13.5;
else wt_trend_wt=wt_trend*1/13.5;

birth = year-age;

run;
/*  137260개의 관측값과 58개의 변수  */

proc means data=apc7 ; where smk ne .; var year age cohort  wt_trend wt_trend_wt ; run;
proc means data=apc7; var birth cohort; run;
/* age and age_der 일치 */
/* cohort and birth 일치 */
/* 1998, 2001, 2005 까지만 연령으로 표기, 2007부터 80+으로 표기 */

proc freq data=apc7;
where sex=1;
tables birth*cohort_cat5 birth*cohort_cat10/norow nocol nopercent; run;
/* cat5 1919-1939, 40-44, 45-49, 1990-1998 */
/* cat10 1919-1939, 40-49, 50-59, 1990-1998 */

proc freq data=apc7; 
where sex=2;
tables birth*smk/nopercent norow nocol; run;

proc means data=apc7; var age; run; /* 45.3 */
proc surveymeans data=apc7 nomcar; 
weight wt_trend_wt;
strata kstrata;
cluster psu;
var age; run; /* 43.6 */

/*** birth cohort categories ***/
data apc8; set apc7;
if 1919<=birth<=1929 then birth5=1925; *midyear;
else if 1930<=birth<=1934 then birth5=1932;
else if 1935<=birth<=1939 then birth5=1937;
else if 1940<=birth<=1944 then birth5=1942;
else if 1945<=birth<=1949 then birth5=1947;
else if 1950<=birth<=1954 then birth5=1952;
else if 1955<=birth<=1959 then birth5=1957;
else if 1960<=birth<=1964 then birth5=1962;
else if 1965<=birth<=1969 then birth5=1967;
else if 1970<=birth<=1974 then birth5=1972;
else if 1975<=birth<=1979 then birth5=1977;
else if 1980<=birth<=1984 then birth5=1982;
else if 1985<=birth<=1989 then birth5=1987;
else if 1990<=birth<=1994 then birth5=1992;
else if 1995<=birth<=1999 then birth5=1997;
else birth5=.;

if 1919<=birth<=1924 then birth5r=1922; *midyear;
else if 1925<=birth<=1929 then birth5r=1927; 
else if 1930<=birth<=1934 then birth5r=1932;
else if 1935<=birth<=1939 then birth5r=1937;
else if 1940<=birth<=1944 then birth5r=1942;
else if 1945<=birth<=1949 then birth5r=1947;
else if 1950<=birth<=1954 then birth5r=1952;
else if 1955<=birth<=1959 then birth5r=1957;
else if 1960<=birth<=1964 then birth5r=1962;
else if 1965<=birth<=1969 then birth5r=1967;
else if 1970<=birth<=1974 then birth5r=1972;
else if 1975<=birth<=1979 then birth5r=1977;
else if 1980<=birth<=1984 then birth5r=1982;
else if 1985<=birth<=1989 then birth5r=1987;
else if 1990<=birth<=1994 then birth5r=1992;
else if 1995<=birth<=1999 then birth5r=1997;
else birth5r=.;

if 1919<=birth<=1929 then birth10="1925"; *midyear;
else if 1930<=birth<=1939 then birth10="1935";
else if 1940<=birth<=1949 then birth10="1945";
else if 1950<=birth<=1959 then birth10="1955";
else if 1960<=birth<=1969 then birth10="1965";
else if 1970<=birth<=1979 then birth10="1975";
else if 1980<=birth<=1989 then birth10="1985";
else if 1990<=birth<=1999 then birth10="1995";
else birth10=.;

if 19<=age<25 then agecat5=1;
else if 25<=age<30 then agecat5=2;
else if 30<=age<35 then agecat5=3;
else if 35<=age<40 then agecat5=4;
else if 40<=age<45 then agecat5=5;
else if 45<=age<50 then agecat5=6;
else if 50<=age<55 then agecat5=7;
else if 55<=age<60 then agecat5=8;
else if 60<=age<65 then agecat5=9;
else if age>=65 then agecat5=10;

if 19<=age<30 then agecat10=2;
else if 30<=age<40 then agecat10=3;
else if 40<=age<50 then agecat10=4;
else if 50<=age<60 then agecat10=5;
else if 60<=age<70 then agecat10=6;
else if age>=70 then agecat10=7;

age2=age*age;

*center around mean;
age_c=age-44;
age_c2 = age_c*age_c;

run;

proc freq data=apcfull6;
where sex=2;
tables smk year birth5; run;
/* 15 birth5, 14 year */

/* apc: 1yr A, 1yr P, 1 yr C (smk cho) */
/* apc2: 1yr A, 1yr P, 5 yr C */
/* apc3: 2yr A, 2yr P, 4 yr C (NCI) */

/* proc glimmix data=NHANES_Obesity maxopt=25000;
      class PERIOD COHORT;
      model OBESE(event='1') = AGE_C AGE_C2 SEX RACE EDUC1 EDUC2 INCOME (Lowest Quartile) INCOME (Highest Quartile) /solution CL
      dist=binary;
      random PERIOD COHORT / solution;
      covtest GLM / WALD;
      NLOPTIONS TECHNIQUE=NRRIDG;
      title "Table 7.4: HAPC-CCREM of Obesity Trends, NHANES 1971-2008";
run;*/

proc glimmix data=apc8 maxopt=25000;
where smk in(0,1);
*where sex=2;
*by sex;
      class YEAR birth5r;
      model SMK(event='1') = AGE_C AGE_C2 /solution CL
      dist=binary;
      random YEAR birth5r / solution;
      covtest GLM / WALD;
      NLOPTIONS TECHNIQUE=NRRIDG;
	  weight wt_trend_wt;
      title "Current Smoking Proportion Trends, KNHANES 1998-2017";
	  *output out=glimmixout pred( blup ilink)=PredProb pred(noblup ilink)=Predprob_pa;
run; /* logistic */

proc glimmix data=apc8 maxopt=25000;
where smk in(0,1) and sex=2;
*by sex;
      class YEAR birth5r;
      model SMK(event='1') = AGE_C AGE_C2 /solution CL
      dist=binary;
      random YEAR birth5r year*birth5r/ solution cl ;
      covtest GLM / WALD ;
      NLOPTIONS TECHNIQUE=NRRIDG;
	  weight wt_trend_wt;
      title "Current Smoking Proportion Trends, KNHANES 1998-2017";
	  *output out=glimmixout pred( blup ilink)=PredProb pred(noblup ilink)=Predprob_pa;
run; /* logistic */

proc freq data=apc8;
where smk in(0,1) and sex=2;
tables birth5r birth5 cohort_cat5;
weight wt_trend;run;

proc surveyfreq data=apc8;
where sex=2;
strata kstrata;
cluster psu;
weight wt_trend;
tables birth5r*agecat5*smk/row;
run;
proc glimmix data=apc8 maxopt=25000;
where smk in(0,1) and sex=2;
*by sex;
      class YEAR birth5r;
      model SMK(event='1') = AGE_C AGE_C2 /solution CL
      dist=binary;
      random YEAR birth5 / solution;
      covtest GLM / WALD;
      NLOPTIONS TECHNIQUE=NRRIDG;
	  weight wt_trend_wt;
      title "Current Smoking Proportion Trends, KNHANES 1998-2017";
	  *output out=glimmixout pred( blup ilink)=PredProb pred(noblup ilink)=Predprob_pa;
run; /* logistic */

proc freq data=apc8; tables birth5r*cohort_cat5/nopercent norow nocol; run;

proc freq data=apc8; 
where smk in(0,1) and sex=2;
tables birth5r cohort_cat5 birth10 cohort_cat10; run;

data apc9; set apc8;

birth5=.;

if 1919<=birth<=1939 then birth5=1939; *midyear;
else if 1940<=birth<=1944 then birth5=1942;
else if 1945<=birth<=1949 then birth5=1947;
else if 1950<=birth<=1954 then birth5=1952;
else if 1955<=birth<=1959 then birth5=1957;
else if 1960<=birth<=1964 then birth5=1962;
else if 1965<=birth<=1969 then birth5=1967;
else if 1970<=birth<=1974 then birth5=1972;
else if 1975<=birth<=1979 then birth5=1977;
else if 1980<=birth<=1984 then birth5=1982;
else if 1985<=birth<=1999 then birth5=1987;
else birth5=.;


if 1919<=birth<=1934 then birth5cat=1927; *midyear;
else if 1934<=birth<=1939 then birth5cat=1937;
else if 1940<=birth<=1944 then birth5cat=1942;
else if 1945<=birth<=1949 then birth5cat=1947;
else if 1950<=birth<=1954 then birth5cat=1952;
else if 1955<=birth<=1959 then birth5cat=1957;
else if 1960<=birth<=1964 then birth5cat=1962;
else if 1965<=birth<=1969 then birth5cat=1967;
else if 1970<=birth<=1974 then birth5cat=1972;
else if 1975<=birth<=1979 then birth5cat=1977;
else if 1980<=birth<=1984 then birth5cat=1982;
else if 1985<=birth<=1989 then birth5cat=1987;
else if 1990<=birth<=1999 then birth5cat=1995;
else birth5cat=.;

birth10=.;
if 1919<=birth<=1939 then birth10=1939; *midyear;
else if 1940<=birth<=1949 then birth10=1945;
else if 1950<=birth<=1959 then birth10=1955;
else if 1960<=birth<=1969 then birth10=1965;
else if 1970<=birth<=1979 then birth10=1975;
else if 1980<=birth<=1999 then birth10=1980;
else birth10=.;

if 1919<=birth<=1939 then birth5f=1939; *midyear;
else if 1940<=birth<=1944 then birth5f=1942;
else if 1945<=birth<=1949 then birth5f=1947;
else if 1950<=birth<=1954 then birth5f=1952;
else if 1955<=birth<=1959 then birth5f=1957;
else if 1960<=birth<=1964 then birth5f=1962;
else if 1965<=birth<=1969 then birth5f=1967;
else if 1970<=birth<=1974 then birth5f=1972;
else if 1975<=birth<=1979 then birth5f=1977;
else if 1980<=birth<=1984 then birth5f=1982;
else if 1985<=birth<=1989 then birth5f=1987;
else if 1990<=birth<=1999 then birth5f=1995;
else birth5f=.;

run;

proc freq data=apc9;
where sex=2;
weight wt_trend;
tables birth5f*cohort_cat5 /*birth5r birth5 cohort_cat5 birth10 cohort_cat10*/; run;

proc freq data=apc9;
where sex=1;
weight wt_trend;
tables birth5f/*birth5r birth5 cohort_cat5 birth10 cohort_cat10*/; run;

proc freq data=apc9;
where smk in(0,1) and sex=2;
weight wt_trend;
tables birth5f*agecat10*smk/*birth5r birth5 cohort_cat5 birth10 cohort_cat10*/; run;


proc glimmix data=apc9 maxopt=25000;
where smk in(0,1) and sex=2;
*by sex;
      class YEAR birth5f;
      model SMK(event='1') = AGE_C AGE_C2 /solution CL
      dist=binary;
      random YEAR birth5f/ solution; /* period effect vary by cohort? */
      covtest GLM / WALD;
      NLOPTIONS TECHNIQUE=NRRIDG;
	  weight wt_trend_wt;
      title "Current Smoking Proportion Trends, KNHANES 1998-2017";
	  *output out=glimmixout pred( blup ilink)=PredProb pred(noblup ilink)=Predprob_pa;
run; /* logistic */

proc freq data=apc9;
where smk in(0,1) and sex=2;
tables year*smk birth5f*smk/nopercent; run;


proc freq data=apc9;
where dr_month in(0,1) and sex=2;
weight wt_trend;
tables birth5f*agecat10*dr_month/*birth5r birth5 cohort_cat5 birth10 cohort_cat10*/; run;

proc glimmix data=apc9 maxopt=25000;
where dr_month in(0,1) and sex=1;
*by sex;
      class YEAR birth5f;
      model dr_month (event='1') = AGE_C AGE_C2 /solution CL
      dist=binary;
      random YEAR birth5f/ solution; /* period effect vary by cohort? */
      covtest GLM / WALD;
      NLOPTIONS TECHNIQUE=NRRIDG;
	  weight wt_trend_wt;
      title "Current Smoking Proportion Trends, KNHANES 1998-2017";
	  *output out=glimmixout pred( blup ilink)=PredProb pred(noblup ilink)=Predprob_pa;
run; /* logistic */

proc surveyfreq data=apc9; 
where dr_binge in(0,1) and sex=2;
weight wt_trend_wt;
tables birth5f /*birth5r birth5f*dr_binge birth5 cohort_cat10 */; run;

proc surveyfreq data=apc9; 
where pa_walk in(0,1) and sex=2;
weight wt_trend_wt;
tables birth5f /*birth5r birth5f*dr_binge birth5 cohort_cat10 */; run;

proc freq data=apc9; tables KHEI_sum2; run;

proc means data=apc9; 
where khei_sum2 ne .;
class sex;
var age khei_sum2  wt_ntr_9817 wt_trend_wt;
run;
proc mixed data=apc9 covtest cl;
where khei_sum2 ne . and sex=2;
*by sex;
      class YEAR birth5r;
      model khei_sum2 = AGE_C AGE_C2 /solution Cl;
      random YEAR birth5r/ solution; 
	  weight wt_ntr_9817;
run; 

proc contents data=apc9; run;


proc glimmix data=apc9 maxopt=25000;
where dr_binge in(0,1) and sex=2;
*by sex;
      class YEAR birth5r;
      model dr_binge (event='1') = AGE_C AGE_C2 /solution CL
      dist=binary;
      random YEAR birth5r/ solution; /* period effect vary by cohort? */
      covtest GLM / WALD;
      NLOPTIONS TECHNIQUE=NRRIDG;
	  weight wt_trend_wt;
      title "Current Smoking Proportion Trends, KNHANES 1998-2017";
	  *output out=glimmixout pred( blup ilink)=PredProb pred(noblup ilink)=Predprob_pa;
run; /* logistic */

proc glimmix data=apc9 maxopt=25000;
where pa_muscle in(0,1) and sex=2;
*by sex;
      class YEAR birth5f;
      model pa_muscle (event='1') = AGE_C AGE_C2 /solution CL
      dist=binary;
      random YEAR birth5f/ solution; /* period effect vary by cohort? */
      covtest GLM / WALD;
      NLOPTIONS TECHNIQUE=NRRIDG;
	  weight wt_trend_wt;
      title "Current Smoking Proportion Trends, KNHANES 1998-2017";
	  *output out=glimmixout pred( blup ilink)=PredProb pred(noblup ilink)=Predprob_pa;
run; /* logistic */

proc contents data=data9818; run;
data a.data9818; set data9818; run;

proc freq data=data9818; tables cancer cvd pg; run;

proc freq data=apc9; tables birth5f cohort_cat5; run;
proc means data=data9818; where pa_walk in(0,1);class year;  var age wt_bhv_0517; run;

data data9818r; set data9818;
if 19<=age<=79;
if cancer=1 then delete;
if cvd=1 then delete;
if pg=1 then delete;
run;


proc glimmix data=data9818 maxopt=25000;
where pa_walk in(0,1) and sex=1;
*by sex;
      class YEAR birth5f;
      model pa_walk (event='1') = AGE_C AGE_C2 /solution CL
      dist=binary;
      random YEAR birth5f/ solution; /* period effect vary by cohort? */
      covtest GLM / WALD;
      NLOPTIONS TECHNIQUE=NRRIDG;
	 * weight wt_trend_wt;
      title "Current Smoking Proportion Trends, KNHANES 1998-2017";
	  *output out=glimmixout pred( blup ilink)=PredProb pred(noblup ilink)=Predprob_pa;
run; /* logistic */


proc contents data=apc9; run;
proc freq data=apc9; tables dr_month; run;

proc means data=apc9;
where dr_month ne .;
class year;
var age wt_trend; run;

proc freq data=apc9; tables birth5f*cohort_cat5; run;
proc freq data=apc9;
where dr_month in(0,1) and sex=2;
weight wt_trend;
tables birth5f; run;
proc freq data=apc10;
where dr_month in(0,1) and sex=2;
weight wt_trend;
tables birth5f; run;

data apc9; set apc8;
if 19<=age<25 then agecat5=22;
else if 25<=age<30 then agecat5=27;
else if 30<=age<35 then agecat5=32;
else if 35<=age<40 then agecat5=37;
else if 40<=age<45 then agecat5=42;
else if 45<=age<50 then agecat5=47;
else if 50<=age<55 then agecat5=52;
else if 55<=age<60 then agecat5=57;
else if 60<=age<65 then agecat5=62;
else if 65<=age<70 then agecat5=67;
else if 70<=age<75 then agecat5=72;
else if 75<=age<=79 then agecat5=77;

cohortr=year-agecat5;

if 19<=age<30 then agecat10=25;
else if 30<=age<40 then agecat10=35;
else if 40<=age<50 then agecat10=45;
else if 50<=age<60 then agecat10=55;
else if 60<=age<70 then agecat10=65;
else if 70<=age<80 then agecat10=75;

cohortr10=year-agecat10;

run;

proc freq data=apc9;
tables cohortr; run;

data a.apc9; set apc9; run;

proc means data=glimmixout;
where age=44;
class year birth5r;
var predProb; run;



proc freq data=apc8; 
weight wt_trend_wt;
tables birth5r;
run;

proc surveymeans data=apcfull7 nomcar;
weight wt_trend;
strata kstrata;
cluster psu;
domain sex*year;
var smk;
run;

proc means data=apcfull7;
where sex=2;
weight wt_trend;
class year;
var smk;
run;

*with weight;
proc glimmix data=apcfull7 maxopt=25000;
where sex=2;
*by sex;
      class YEAR birth5;
      model SMK(event='1') = AGE_C AGE_C2 /solution CL
      dist=binary;
      random YEAR birth5 / solution;
      covtest GLM / WALD;
      NLOPTIONS TECHNIQUE=NRRIDG;
	  weight wt_trend;
      title "Current Smoking Proportion Trends, KNHANES 1998-2017";
run;

proc glimmix data=apcfull7 maxopt=25000;
where sex=2;
*by sex;
      class YEAR cohort_cat5;
      model SMK(event='1') = AGE_C AGE_C2 /solution CL
      dist=binary;
      random YEAR cohort_cat5 / solution;
      covtest GLM / WALD;
      NLOPTIONS TECHNIQUE=NRRIDG;
	  *weight wt_trend;
      title "Current Smoking Proportion Trends, KNHANES 1998-2017";
run;

proc glimmix data=apcfull7 maxopt=25000;
where sex=2;
*by sex;
      class YEAR birth;
      model SMK(event='1') = AGE_C AGE_C2 /solution CL
      dist=binary;
      random YEAR birth / solution;
      covtest GLM / WALD;
      NLOPTIONS TECHNIQUE=NRRIDG;
	  weight wt_trend;
      title "Current Smoking Proportion Trends, KNHANES 1998-2017";
run;

proc glimmix data=apcfull7 maxopt=25000;
where sex=2;
*by sex;
      class YEAR cohort_cat10;
      model SMK(event='1') = AGE_C AGE_C2 /solution CL
      dist=binary;
      random YEAR cohort_cat10 / solution;
      covtest GLM / WALD;
      NLOPTIONS TECHNIQUE=NRRIDG;
	  weight wt_trend;
      title "Current Smoking Proportion Trends, KNHANES 1998-2017";
run;

proc glimmix data=apcfull7 maxopt=25000;
where sex=2;
*by sex;
      class YEAR birth10;
      model SMK(event='1') = AGE_C AGE_C2 /solution CL
      dist=binary;
      random YEAR birth10 / solution;
      covtest GLM / WALD;
      NLOPTIONS TECHNIQUE=NRRIDG;
	  weight wt_trend;
	  *lsmeans birth10;
      title "Current Smoking Proportion Trends, KNHANES 1998-2017";
run;

data a.apcfull; set apcfull7;
run;

/******* start from here *****/
data apcfull6; set a.apcfull; run;

proc freq data=apcfull6; tables year ;run;

data apcfull7; set apcfull6; 
if year="2007" then wt_trend_rev=wt_trend*0.5;
else if 
proc surveyfreq data=apcfull7 nomcar;
where sex=1;
tables birth*smk;
weight wt_trend;
strata kstrata;
cluster psu;
run;

proc surveyfreq data=apcfull7 nomcar;
where sex=2;
tables birth*smk/row;
weight wt_trend;
*strata kstrata;
*cluster psu;
run;

proc freq data=apcfull7;
tables wt_trend*wt_bhv_t/norow nocol nopercent;
run;

proc surveymeans data=apcfull7 nomcar;
weight wt_trend;
strata kstrata;
cluster psu;
domain sex*birth*agecat;
var smk;
run;
proc surveymeans data=apcfull7 nomcar;
weight wt_trend;
strata kstrata;
cluster psu;
domain sex*birth10*agecat;
var smk;
run;

proc means data=apcfull7;
weight wt_trend;
where sex=2 and age=45;
class birth5;
var smk;
run;


/* why so vary by cohort interval */
/* ask Yang Yang */
/* try apc IE */
/* r package, diagnostic */
/* stata */

/**************************/
data alco; set apc;
if age>=19;
if 2005<=year<=2017 then period=year; else period=.;
if 1940<=cohort<=1998 then c=cohort; else c=.;
if 19<=age<25 then agecat=1;
else if 25<=age<30 then agecat=2;
else if 30<=age<35 then agecat=3;
else if 35<=age<40 then agecat=4;
else if 40<=age<45 then agecat=5;
else if 45<=age<50 then agecat=6;
else if 50<=age<55 then agecat=7;
else if 55<=age<60 then agecat=8;
else if 60<=age<65 then agecat=9;
else if age>=65 then agecat=10;
else agecat=.;
if period=. or c=. or agecat=. then delete;
run;
proc freq data=alco; tables cvd cancer pg; run;

proc genmod data = alco;
where sex=2;
 class c(ref="1975") agecat(ref="1") period(ref="2005") /* sex(ref="1") */;
 model dr_high_risk = c agecat period 
/ dist = poisson link = log;
 *repeated subject = id/ type = unstr;
 *weight wt2;
 *estimate 'Beta' tsex 1 -1/ exp;
lsmeans agecat ;
run; 
proc genmod data = alco;
where sex=2;
 class c(ref="1975") agecat(ref="1") period(ref="2005");
 model dr_high_risk = c agecat period
/ dist = binomial link = log;
 *repeated subject = id/ type = unstr;
 *weight wt2;
 *estimate 'Beta' tsex 1 -1/ exp;
lsmeans period /exp;
run; 

data apc1; set apc;
if cancer=1 then delete;
if cvd=1 then delete;
if pg=1 then delete;
*if 20<=age<=79; 

age2 = age**2;
age_c = age-45.7;
age_c2 = age_c**2;
if 19<=age<25 then agecat=1;
else if 25<=age<30 then agecat=2;
else if 30<=age<35 then agecat=3;
else if 35<=age<40 then agecat=4;
else if 40<=age<45 then agecat=5;
else if 45<=age<50 then agecat=6;
else if 50<=age<55 then agecat=7;
else if 55<=age<60 then agecat=8;
else if 60<=age<65 then agecat=9;
else if age>=65 then agecat=10;
else agecat=.;

if sex=1 then age_m_bs=45.2;
if sex=2 then age_m_bs=46.1;
age_c_bs=age-age_m_bs;
age_c2_bs=age_c_bs**2 ;

cohortcat5rev=int(cohort/5);

run;
proc freq data=apc1;
tables cohort*cohortcat5rev /nopercent nocol norow; run;
proc means data=apc1; *class sex; var age; run;

proc glimmix data=apc1 maxopt=25000;
      class YEAR COHORT_CAT5;
      model SMK (event='1') = AGE_c AGE_c2 /solution CL
      dist=binary;
      random YEAR COHORT_CAT5 / solution;
      covtest GLM / WALD;
      NLOPTIONS TECHNIQUE=NRRIDG;
      title "Current Smoking Proportion Trends, KNHANES 1998-2017";
run;

proc freq data=apc1;
where 20<=age<=79 and cohort_cat5 =15 and sex=2;
tables agecat*smk; run;

proc glimmix data=WORK.GG maxopt=25000;
 class c(ref="1975") agecat(ref="1") period(ref="2005");
      model dr_high_risk (event='1') = agecat /solution CL
      dist=binary;
      random period c / solution;
      covtest GLM / WALD;
      NLOPTIONS TECHNIQUE=NRRIDG;
      title "Current Smoking Proportion Trends, KNHANES 1998-2017";
run;

/***
proc import datafile="D:\SASfiles\kwcs_region.csv"
out=work.region
dbms=csv
replace;
run;

*centering;
egen age_m=mean(age_der)

egen age_av_m=mean(age_der) if sex==1
egen age_av_f=mean(age_der) if sex==2

gen age_m_bs=age_av_m if sex==1
replace age_m_bs=age_av_f if sex==2

gen age_c=age_der-age_m 
gen age_c2=age_c^2
gen age_c_bs=age_der-age_m_bs
gen age_c2_bs=(age_c_bs)^2 

*birth cohort;
gen cohort=year-age_der
recode cohort (min/1939=4)(1940/1949=5)(1950/1959=6)(1960/1969=7)(1970/1979=8)(1980/1989=9)(1990/1998=10), gen(cohort_cat10)
recode cohort (min/1939=4)(1940/1944=5)(1945/1949=6)(1950/1954=7)(1955/1959=8)(1960/1964=9)(1965/1969=10)(1970/1974=11)(1975/1979=12)(1980/1984=13)(1985/1989=14)(1990/1998=15), gen(cohort_cat5)

*period;
recode year (1998=1)(2001=2)(2005=3)(2007/2009=4)(2010/2012=5)(2013/2015=6)(2016/2017=7), gen(period_th)

*****/

********** Model ---------------------------;
proc glimmix data=apc1 maxopt=25000;
      class YEAR COHORT_CAT5;
      model SMK (event='1') = AGE_C AGE_C2 /solution CL
      dist=binary;
      random YEAR COHORT_CAT5 / solution;
      covtest GLM / WALD;
      NLOPTIONS TECHNIQUE=NRRIDG;
      title "Current Smoking Proportion Trends, KNHANES 1998-2017";
run;

proc sort data=apc1; by sex; run;

proc glimmix data=apc1 maxopt=25000;
by sex;
      class YEAR COHORT_CAT5;
      model SMK(event='1') = AGE_C_BS AGE_C2_BS /solution CL
      dist=binary;
      random YEAR COHORT_CAT5 / solution;
      covtest GLM / WALD;
      NLOPTIONS TECHNIQUE=NRRIDG;
      title "Current Smoking Proportion Trends, KNHANES 1998-2017";
run;

proc glimmix data=apc1 maxopt=25000;
by sex;
      class YEAR COHORT_CAT5;
      model SMK(event='1') = AGE_C AGE_C2 /solution CL
      dist=binary;
      random YEAR COHORT_CAT5 / solution;
      covtest GLM / WALD;
      NLOPTIONS TECHNIQUE=NRRIDG;
      title "Current Smoking Proportion Trends, KNHANES 1998-2017";
run;

proc sort data=apc1; by sex; run;
proc glimmix data=apc1 maxopt=25000;
by sex;
      class YEAR COHORTcat5rev;
      model SMK(event='1') = AGE_C AGE_C2 /solution CL
      dist=binary;
      random YEAR cohortcat5rev / solution;
      covtest GLM / WALD;
      NLOPTIONS TECHNIQUE=NRRIDG;
	  *weight weght; /* weight missing */
      title "Current Smoking Proportion Trends, KNHANES 1998-2017";
run;

proc freq data=apc1;
tables cohort*cohort_cat5 cohort*cohort_cat10/nopercent nocol norow;run;
