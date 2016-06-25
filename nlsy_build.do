*************************************************
*Build for NLSY79 Data for Duration Analysis
*M. Miller, 16W
*************************************************


cd "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Delayed Marriage\Working"

clear
clear matrix
clear mata

set maxvar 8000
set more off

global nlsy  = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Delayed Marriage\Data\NLSY"
global out   = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Delayed Marriage\Presentations"

**Build uses .ado file "cohorts"

cohorts CASEID_1979 Q1_3_A_Y_1979    MARSTAT_KEY_           SMSARES_  Q3_4_   SAMPLE_SEX_1979 nlsy79
cohorts CPUBID_XRND BIRTHDATE_Y_XRND MARSTAT_               SMSARES_  HGC_    CSEX_XRND       nlsy79ch
cohorts PUBID_1997  BDATE_Y_1997     CV_MARSTAT_COLLAPSED_  CV_MSA_   CV_HGC_ SEX_1997        nlsy97

**Bach degree for NLSY97 cohort

cohorts_supp PUBID_1997 CVC_BA_DEGREE_XRND nlsy97

use nlsy79, clear

append using nlsy79ch
append using nlsy97

gen age = year - birth_yr

drop if birth_yr == 1897

local cvar = "age"
local cv_l = 18
local cv_h = 32

drop if `cvar' <= `cv_l' | age >= `cv_h' 

joinby id source using nlsy97_supp, unmatched(master)

drop _merge

save nlsy_cohorts, replace

gen year_bach = .
gen age_bach  = .
replace year_bach = year if educ[_n] == 16 & educ[_n-1] < 16
replace age_bach  = age  if educ[_n] == 16 & educ[_n-1] < 16

gen year_mar  = . 
gen age_mar  = .
replace year_mar = year if  evermarr[_n] == 1 & evermarr[_n-1] == 0 
replace age_mar  = age if  evermarr[_n] == 1 & evermarr[_n-1] == 0 
*gen year_ch   = .
*replace year_ch   = year if 

*replace cc = cc - 1
*replace cc = -1*cc

save base, replace

keep if year_bach != . 
duplicates drop id, force

keep id source year_bach age_bach

save yb, replace

use base, clear

keep if year_mar != .  
duplicates drop id, force

keep id source year_mar age_mar

save ym, replace

use base, clear

drop year_bach year_mar age_bach age_mar

joinby id source using yb, unmatched(master)
drop _merge
joinby id source using ym, unmatched(master)

replace year_bach = year if bach_dum > 0 & bach_dum != .

gen yrs_since_bach = year - year_bach
gen yrs_since_mar  = year - year_mar

gen cohort = .
replace cohort = 0 if source == "nlsy79" 
replace cohort = 1 if source == "nlsy79ch" & birth_yr < 1980
replace cohort = 2 if source == "nlsy79ch" &  birth_yr > 1979 & birth_yr < 1985
replace cohort = 3 if source == "nlsy97"
replace cohort = . if year_bach == .

forvalues c = 0/2 {
sum age_mar if cohort == `c'
local am_`c' = r(mean)
}

#delimit ;
twoway (lpoly cc age if cohort == 0 & `cvar' >= `cv_l' & `cvar' < `cv_h', xline(`am_0')) 
(lpoly cc age if cohort == 1 & `cvar' >= `cv_l' & `cvar' < `cv_h', xline(`am_1'))
(lpoly cc age if cohort == 2 & `cvar' >= `cv_l' & `cvar' < `cv_h', xline(`am_2')), name(yb, replace)
legend(label(1 "1957-1964 (79)") label(2 "1975-1980 (79 ch)") label(3 "1980-1985 (79 ch)"));
#delimit cr

*twoway (lpoly cc yrs_since_bach if cohort == "nlsy79" & yrs_since_bach >= -2 & yrs_since_bach < 7 ) (lpolyci cc yrs_since_bach if source == "nlsy79ch" & yrs_since_bach >= -2 & yrs_since_bach < 7), name(yb, replace) xline(0)
#delimit ;
twoway (lpoly cc yrs_since_mar  if source == "nlsy79" & yrs_since_mar >= -6 & yrs_since_mar < 7 & year_bach != . & sex == 1, )  
(lpoly cc yrs_since_mar if source == "nlsy79ch" & yrs_since_mar >= -6 & yrs_since_mar < 7 & year_bach != . & sex == 1)
(lpoly cc yrs_since_mar if source == "nlsy97" & yrs_since_mar >= -6 & yrs_since_mar < 7 & year_bach != . & sex == 1), 
xline(0)
legend(order(1 "1957-1964 (79)" 2 "1975-1985 (79 ch)" 3 "1980-1985 (97)"))
graphregion(color(white)) bgcolor(white)
title("Probability of City Living around Marriage Events")
xtitle("Years Since Marriage")
ytitle("Prob Central City")
note("Limited to females with bachelor degrees, within six years of marriage." "NLSY cohorts: 79 children and 97 cohorts not statistically distinct.")
name(ysm, replace);

#delimit cr

graph export "$out\ysm.pdf", replace name(ysm) as(pdf)

*fc(none) fi(inten0) alc(blue) alp(dash)

xx
& yrs_since_bach >= -2 & yrs_since_bach < 7
stset year, id(id) failure(cc) origin(year_bach)

xx
keep if age == 26 & educ > 16

duplicates drop id, force

gen hi_ed = 1

save hi_ed, replace

use nlsy_cohorts, clear

joinby id using hi_ed, unmatched(master)

tab _merge

keep if hi_ed == 1

gen cohort = 0
replace cohort = 1 if birth_yr > 1964 & birth_yr < 1980
replace cohort = 2 if birth_yr > 1979 & birth_yr < 1989
replace cohort = . if birth_yr > 1986

drop if age < 20 | age > 34
drop if sex == 1

#delimit ;
twoway (lpoly cc age if cohort == 0) (lpoly cc age if cohort == 1) (lpoly cc age if cohort == 2)
,
name(cohort_cc, replace)
title("Residing in Central City over Life-Cycle")
subtitle("Women with a Bachelor's Degree")
xtitle("Age")
ytitle("Prob")
note("FIll IN")
legend(label(1 "1960s") label(2 "1970s") label(3 "1980s"))
graphregion(color(white)) bgcolor(white);
#delimit cr

#delimit ;
twoway (lpoly evermarr age if cohort == 0) (lpoly evermarr age if cohort == 1) (lpoly evermarr age if cohort == 2)
,
name(cohort_mar, replace)
title("Marital Status over Life-Cycle")
subtitle("Women with a Bachelor's Degree")
xtitle("Age")
ytitle("Prob")
note("FIll IN")
legend(label(1 "1960s") label(2 "1970s") label(3 "1980s"))
graphregion(color(white)) bgcolor(white);
#delimit cr

xx

(lpoly evermarr age if cohort == 0) (lpoly evermarr age if cohort == 1) (lpoly evermarr age if cohort == 2)

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
