********************************************
*GWG and Marital Decisions
*Using lasso gwg estimates
*M. Miller, 16X
********************************************

cd "L:\Research\Resurgence\Working Files"

clear
clear matrix

set matsize 5000
set more off

global data = "L:\Research\Resurgence\GIS\Working Files\Output\Test"
global work = "L:\Research\Resurgence\Working Files"  
global reg  = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Delayed Marriage\Data\Regulations\BPEAzip1\FiftyYears_Replication1"
global out  = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Delayed Marriage\Presentations"

use ipums_gwg_lasso, clear

drop res* met_stat* indx_* occx_* tranwork_* race_* 

*joinby group year using gwg_lasso_long, unmatched(master)

**At Least Bachelor's Degree 

gen     bach_plus = 0
replace bach_plus = 1 if educ > 10

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

local c = 0

local a_y = 18
local a_o = 35

local rows = `a_o' - `a_y' + 1

forvalues y = 1980(10)2010 {

sum group if year == `y'


}

mat R = J(`rows',4,.)

forvalues a = `a_y'/`a_o' {

timer list
timer clear
local c = `c' + 1
timer on 1
disp `a'

forvalues y = 1980(10)2010 {

quietly sum group if year == `y'
local m = r(max)

preserve

foreach v of varlist marry bach_plus {

quietly reg `v' $x i.group if year == `y'
mat b = e(b)
mat b_`v'_`y' = b'

gen mu_`v'_`y' = .

forvalues g = 2/`m' {
local gg = "`g'" + ".group"
capture replace mu_`v'_`y' = _b["`gg'"] if group == `g' & year == `y'
}

}

}

gen gryr = year*10000 + group
bysort gryr: gen N = _N

keep group year N mu_*

duplicates drop

joinby group year using gwg_lasso_long

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

restore
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
