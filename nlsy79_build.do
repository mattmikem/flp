*************************************************
*Build for NLSY79 Data for Duration Analysis
*M. Miller, 16W
*************************************************


cd "C:\Users\Matthew\Dropbox\Research\Urban\Papers\Delayed Marriage\Working"

clear
clear matrix
clear mata

set maxvar 8000
set more off

global nlsy  = "C:\Users\Matthew\Dropbox\Research\Urban\Papers\Delayed Marriage\Data\NLSY79"
global nlsy2 = "C:\Users\Matthew\Dropbox\Research\Urban\Papers\Delayed Marriage\Data\NLSY97"
global out   = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Delayed Marriage\Dual Career HH\Output\12-09-2015"

insheet using "$nlsy\duration_1_14.csv", case delimit(",")

do "$nlsy\duration_1_14-value-labels.do"

rename Q1_3_A_Y_1979 birth_yr
rename CASEID_1979   id

keep id birth_yr SMSARES_*  MARSTAT_KEY_*

sum 

reshape clear
reshape i id birth_yr
reshape j year
reshape xij SMSARES_ MARSTAT_KEY_
reshape long

gen base = 1

replace birth_yr = 1900 + birth_yr

gen age = year - birth_yr
xx
gen marrst = 0
replace marrst = 1 if MARSTAT_ == 1
gen evermarr = 0
replace evermarr = 1 if MARSTAT > 0
replace evermarr = . if MARSTAT < 0
gen cc = 0
replace cc = 1 if SMS == 3
replace cc = . if SMS < 0 | SMS == 4

gen source = "NLSY79"

save panel, replace
clear

**NLSY79 (child)

insheet using "$nlsy\dur_chil_1_14.csv", case delimit(",")

do "$nlsy\dur_chil_1_14-value-labels.do"

rename CPUBID_XRND id
rename MPUBID_XRND mid

rename CYRB_XRND birth_yr

keep id mid birth_yr SMSARES_*  MARSTAT_*

reshape clear
reshape i id mid birth_yr
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

gen source = "NLSY79 (child)"

append using panel
save panel, replace
clear

**NLSY97

insheet using "$nlsy2\nlsy97.csv", case delimit(",")

do "$nlsy2\nlsy97-value-labels.do"

rename PUBID_1997 id

rename BDATE_Y_1997 birth_yr

keep id birth_yr CV_MSA_* CV_MARSTAT_COLLAPSED_*

reshape clear
reshape i id birth_yr
reshape j year
reshape xij CV_MSA_ CV_MARSTAT_COLLAPSED_
reshape long

gen base = 1

*replace birth_yr = 1900 + birth_yr
xx
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

gen source = "NLSY79 (child)"

append using panel
save panel, replace



generate cohort = 0
replace  cohort = 1 if birth_yr > 1959


#delimit ;
twoway (lpoly cc age if cohort == 0) (lpoly cc age if cohort == 1)
(lpoly evermarr age if cohort == 0) (lpoly evermarr age if cohort == 1) ,
name(cohort_79, replace)
title("Residing in Central City versus Marital Status over Life-Cycle")
xtitle("Age")
ytitle("Prob")
note("FIll IN")
legend(label(1 "CC: 1957 - 1959") label(2 "CC: 1960 - 1964") label(3 "Married: 1957 - 1959") label(4 "Married: 1960 - 1964"))
graphregion(color(white)) bgcolor(white);
#delimit cr

xx

collapse (sum) base cc marrst, by(cohort age)

gen pr_cc  = cc/base
gen pr_mar = marrst/base

#delimit ;
twoway (line pr_cc age if cohort == 0) (line pr_cc age if cohort == 1) 
(line pr_mar age if cohort == 0) (line pr_mar age if cohort == 1),
name(cohort_79, replace)
title("Residing in Central City versus Marital Status over Life-Cycle")
xtitle("Age")
ytitle("Prob")
note("FIll IN")
legend(label(1 "CC: 1957 - 1959") label(2 "CC: 1960 - 1964") label(3 "Married: 1957 - 1959") label(4 "Married: 1960 - 1964"))
graphregion(color(white)) bgcolor(white);
#delimit cr

*lcolor(blue blue green green)
*lpattern(solid dash solid dash) 
