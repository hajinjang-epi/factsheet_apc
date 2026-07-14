/* Birth-cohort and age-group categorization, from apc_10082019.sas (DATA apc8).
   The five-year birth-cohort bins, the 5- and 10-year age categories, and the
   squared / mean-centered age terms are reproduced unchanged from the upstream
   DATA step, followed by the author's own FREQ and MEANS checks. */
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

proc freq data=apc8; tables birth5 agecat5 agecat10; run;
proc means data=apc8; var age age_c age_c2 birth; run;
