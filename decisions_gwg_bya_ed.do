********************************************
*GWG and Marital Decisions
*Using lasso gwg estimates
*M. Miller, 16X
********************************************

*cd "/u/home/m/mmiller"
cd "L:\Research\Resurgence\Working Files"

clear
clear matrix

set matsize 11000
set more off

*global data = "L:\Research\Resurgence\GIS\Working Files\Output\Test"
*global work = "L:\Research\Resurgence\Working Files"  
*global reg  = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Delayed Marriage\Data\Regulations\BPEAzip1\FiftyYears_Replication1"
*global out  = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Delayed Marriage\Presentations"
global pr = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Delayed Marriage\Programs"

do "$pr\cut_reg_eq.ado"

use ipums_withcbsa, clear

*drop res* met_stat* indx_* occx_* tranwork_* race_* 

*********UPDATE AFTER LASSO RUNS!
*joinby group year using gwg_lasso_long, unmatched(master)
**********************************

**At Least Bachelor's Degree 

gen     bach_plus = 0
replace bach_plus = 1 if educ > 9

gen     college = 0
replace college = 1 if educ > 9 
gen     hs      = 0
replace hs      = 1 if educ < 7
gen     gs      = 0
replace gs      = 1 if educ > 11

**FLP

gen     emp = 0
replace emp = 1 if empstat == 1
*replace emp = . if empstat == 2

tab race, gen(race_)

**FLP (above median occupation prestige)

sum presgl if presgl != 0, d

*gen     emp_high = 0
*replace emp_high = 1 if empstat == 1 & presgl > r(p75)
*replace emp = 0 if emp_high == 1

gen     marry = 0
replace marry = 1 if marst == 1 | marst == 2

**Shocks

gen rec_marr = .
replace rec_marr = 1 if year - yrmarr < 2 & yrmarr != .
replace rec_marr = 0 if marst == 6 | marst == 4 

*gen rec_sin = .
*replace rec_sin = 1 if divinyr == 2 | widinyr == 2
*replace rec_sin = 0 if divinyr == 1 & widinyr == 1

gen rec_div = .
replace rec_div = 1 if divinyr == 2 
replace rec_div = 0 if divinyr == 1 

*gen rec_wid = .
*replace rec_wid = 1 if widinyr == 2 
*replace rec_wid = 0 if widinyr == 1 

gen rec_ch = .
replace rec_ch = 1 if fertyr == 2
replace rec_ch = 0 if fertyr == 1

*gen rec_emp = .
*replace rec_emp = 1 if (workedyr == 1 | workedyr == 2) & empstat == 1
*replace rec_emp = 0 if (workedyr == 3 & empstat == 1) | ((workedyr == 1 | workedyr == 2) & empstat > 1)

*gen rec_unemp = .
*replace rec_unemp = 1 if (workedyr == 3 & empstat > 1)
*replace rec_unemp = 0 if (workedyr == 3 & empstat == 1) | ((workedyr == 1 | workedyr == 2) & empstat > 1)


global f_gwg = "gwg"
global x     = "exp lwage hhincome"

*local c = 0

**NOTE: the code in comments runs regressions by age group, takes 24+ hours to run!


local a_y = 22
local a_o = 22

local rows = `a_o' - `a_y' + 1

mat R = J(`rows',4,.)

forvalues y = 1980(10)2010 {

foreach v of varlist marry {

foreach ed of varlist college hs {

quietly sum group if year == `y'
local m = r(max)

disp `y'
disp "`ed'"

forvalues a = `a_y'/`a_o' {

*local c = `c' + 1
timer on `a'

capture quietly reg `v' $x i.group if year == `y' & age == `a' & `ed' == 1
*mat b = e(b)
*mat b_`v'_`y' = b'

*gen mu_`v'_`y' = .

forvalues g = 2/`m' {
local gg = "`g'" + ".group"
*capture replace mu_`v'_`y' = _b["`gg'"] if group == `g' & year == `y'
 
capture matlist R`ed'`y'
if _rc == 111 {
mat R`ed'`y' = J(1,4,.)
mat R`ed'`y'[1,1] = `y'
mat R`ed'`y'[1,2] = `g'
mat R`ed'`y'[1,3] = `a'
capture mat R`ed'`y'[1,4] = _b["`gg'"]
}

else {
mat r`ed'`y' = J(1,4,.)
mat r`ed'`y'[1,1] = `y'
mat r`ed'`y'[1,2] = `g'
mat r`ed'`y'[1,3] = `a'
capture mat r`ed'`y'[1,4] = _b["`gg'"]
mat R`ed'`y' = R`ed'`y'\r`ed'`y'
}


}

timer off `a'
timer list
timer clear

}

}

}

}

mat Rcollege = Rcollege1980
mat Rhs      = Rhs1980
*mat Rgs      = Rgs1980

forvalues y = 1980(10)2010 {
mata: Rc`y' = st_matrix("Rcollege`y'")
mata: Rh`y' = st_matrix("Rhs`y'")
*mata: Rg`y' = st_matrix("Rgs`y'")
}

mata: Rc = Rc1980\Rc1990\Rc2000\Rc2010
mata: Rh = Rh1980\Rh1990\Rh2000\Rh2010
*mata: Rg = Rg1980\Rg1990\Rg2000\Rg2010


getmata (yrc gpc agc muc)=Rc, force
getmata (yrh gph agh muh)=Rh, force
*getmata (yrg gpg agg mug)=Rg, force

*keep marry__* bach_plus__*

keep yrc - muh

duplicates drop

save mu_bya_ed, replace 
xx

*/

**Uses mu_bya 

use ipums_withcbsa, clear

bysort year group age: gen N = _N

gen     bach_plus = 0
replace bach_plus = 1 if educ > 10

*gen total = 1

gen     college = 0
replace college = 1 if educ > 9
gen     hs      = 0
replace hs      = 1 if educ < 7
*gen     gs      = 0
*replace gs      = 1 if educ > 11

keep group year age N college hs

collapse (sum) college hs, by(group year age)
*collapse (sum) bach_plus total, by(group year age)

rename college Nc
*rename bach_plus Nc
rename hs Nh
*gen Nh = total - bach_plus
*rename gs Ng

reshape clear
reshape i year group age
reshape j source, string
reshape xij N
reshape long

joinby group year using "$db_work\gwg_lasso_slope.dta"

drop as_eta bs_eta am_eta bm_eta 

save dec_a_ed_gwg, replace

use "$db_work\my_bya_ed_cat2.dta", clear

rename yrc year
rename gpc group
rename agc age

drop yr* gp* agh 

*agg 

*capture drop R* ci_*

reshape clear
reshape i year group age
reshape j source, string
reshape xij mu
reshape long

joinby year group age source using dec_a_ed_gwg

save ed_mu, replace

cut_reg_eq age mu "delta i.year" delta "c"
cut_reg_eq age mu "delta i.year" delta "h"
*cut_reg_eq age mu "delta i.year" delta "g"

*(line R1g ci_lg ci_ug R3, yaxis(2) lcolor(green green green) lpattern(solid dash dash) mcolor(green green green))

*replace R3 = _n+21 if R1c != .


#delimit ;
twoway (line R1c R3, yaxis(1) lcolor(blue blue blue) lpattern(solid dash dash) mcolor(blue blue blue))
	   
	   (line R1h R3, yaxis(1) lcolor(red red red) lpattern(solid dash dash) mcolor(red red red)),
name(gwg_ef_ed, replace)
xtitle("Age")
ytitle("GWG Effect")
legend(order(1 "College" 2 "High School"))
graphregion(color(white)) bgcolor(white);
#delimit cr

*graph export "$out\gwg_ef_ed.png", replace name(gwg_ef_ed)

xx
/*
save gwg_mu, replace

foreach v in mu_marry mu_bach_plus {

gen `v' = .
forvalues y = 1980(10)2010 {
replace `v' = `v'_`y' if year == `y'
}
}
 
reg mu_marry gwg i.year [w=N]
mat R[`c', 1] = _b[gwg]
mat V = e(V)
mat R[`c', 2] = sqrt(V[1,1])
eststo: reg mu_bach_plus gwg i.year [w=N]
mat R[`c', 3] = _b[gwg]
mat V = e(V)
mat R[`c', 4] = sqrt(V[1,1])


timer off 1

}




xx

#delimit ;
esttab using "$out\reg_gwg_ony.tex", replace label r2
title("Marriage, Fertility, and Education associations with Gender Wage Gap")
keep(gwg)
addnote("Estimates follow from two-step procedure to isolate metro-level group effect of gender wage gap."
"(1) Estimate $\hat{\mu}_{k} from: $y_{ik} = \alpha + X_{ik}\beta + \sum_{k} \mu_{k}\mathbb{I}(k)+\eta_{k}$. "
"(2) Estimate shown is $\hat{\theta}: \hat{\mu}_{k} = \pi + \theta \hat{\delta}_{k} + \omega_{k}$, weighed by pop size of $k$."
"All variables within last year come from 2010 only; others pooled with time trend from 1980 - 2010.")
 ;
#delimit cr 

clear matrix
