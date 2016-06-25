*************************************************
*Build for NLSY79 Child Data for Duration Analysis
*M. Miller, 16W
*************************************************


cd "C:\Users\Matthew\Dropbox\Research\Urban\Papers\Delayed Marriage\Working"

clear
clear matrix
clear mata

set maxvar 8000
set more off

global nlsy = "C:\Users\Matthew\Dropbox\Research\Urban\Papers\Delayed Marriage\Data\NLSY79"
global out  = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Delayed Marriage\Dual Career HH\Output\12-09-2015"

insheet using "$nlsy\dur_chil_1_14.csv", case delimit(",")

do "$nlsy\dur_chil_1_14-value-labels.do"

rename CPUBID_XRND cid
rename MPUBID_XRND mid

rename CYRB_XRND birth_yr

keep cid mid birth_yr SMSARES_*  MARSTAT_*

reshape clear
reshape i cid mid birth_yr
reshape j year
reshape xij SMSARES_ MARSTAT_
reshape long

gen base = 1

*replace birth_yr = 1900 + birth_yr

gen age = year - birth_yr
replace age = . if age > 100 | age < 0

gen marrst = 0
replace marrst = 1 if MARSTAT_ == 1
gen evermarr = 0
replace evermarr = 1 if MARSTAT > 0
replace evermarr = . if MARSTAT < 0	
gen cc = 0
replace cc = 1 if SMS == 3
replace cc = . if SMS < 0 | SMS == 4

generate cohort = 0
replace  cohort = 1 if birth_yr < 1981 & birth_yr > 1974
replace  cohort = 2 if birth_yr > 1980 & birth_yr < 1991 

#delimit ;
twoway (lpoly cc age if cohort == 1 & age > 18 & age < 30) (lpoly cc age if cohort == 2 & age > 18 & age < 30)
 (lpoly evermarr age if cohort == 1 & age > 18 & age < 30) (lpoly evermarr age if cohort == 2 & age > 18 & age < 30) ,
name(cohort_79, replace)
title("Residing in Central City versus Marital Status over Life-Cycle")
xtitle("Age")
ytitle("Prob")
note("FIll IN")
legend(label(1 "CC: 1970 - 1980") label(2 "CC: 1980 - 1995") label(3 "Married: 1970 - 1980") label(4 "Married: 1980 - 1995"))
graphregion(color(white)) bgcolor(white);
#delimit cr

xx
