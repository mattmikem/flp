********************************************
*GWG and Marital Decisions
*Using lasso gwg estimates
*M. Miller, 16X
********************************************

cd "L:\Research\Resurgence\Working Files"

clear
clear matrix

set matsize 11000
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

*local c = 0

**NOTE: the code in comments runs regressions by age group, takes 24+ hours to run!

/*
local a_y = 18
local a_o = 35

*local rows = `a_o' - `a_y' + 1

*mat R = J(`rows',4,.)

forvalues y = 1980(10)2010 {

foreach v of varlist marry bach_plus {

quietly sum group if year == `y'
local m = r(max)

disp `y'
disp "`v'"

forvalues a = `a_y'/`a_o' {

*local c = `c' + 1
timer on `a'

quietly reg `v' $x i.group if year == `y' & age == `a'
*mat b = e(b)
*mat b_`v'_`y' = b'

*gen mu_`v'_`y' = .

forvalues g = 2/`m' {
local gg = "`g'" + ".group"
*capture replace mu_`v'_`y' = _b["`gg'"] if group == `g' & year == `y'
 
capture matlist R`v'`y'
if _rc == 111 {
mat R`v'`y' = J(1,4,.)
mat R`v'`y'[1,1] = `y'
mat R`v'`y'[1,2] = `g'
mat R`v'`y'[1,3] = `a'
capture mat R`v'`y'[1,4] = _b["`gg'"]
}

else {
mat r`v'`y' = J(1,4,.)
mat r`v'`y'[1,1] = `y'
mat r`v'`y'[1,2] = `g'
mat r`v'`y'[1,3] = `a'
capture mat r`v'`y'[1,4] = _b["`gg'"]
mat R`v'`y' = R`v'`y'\r`v'`y'
}


}

timer off `a'
timer list
timer clear

}

}

}

mat Rmarry     = Rmarry1980
mat Rbach_plus = Rbach_plus1980

forvalues y = 1980(10)2010 {
mata: Rm`y' = st_matrix("Rmarry`y'")
mata: Rb`y' = st_matrix("Rbach_plus`y'")
}

mata: Rm = Rm1980\Rm1990\Rm2000\Rm2010
mata: Rb = Rb1980\Rb1990\Rb2000\Rb2010

getmata (yrm gpm agm mum)=Rm, force
getmata (yrb gpb agb mub)=Rb, force

keep marry__* bach_plus__*

duplicates drop

save mu_bya, replace 
*/

**Uses mu_bya 

xx

bysort year group age: gen N = _N

keep group year age N

duplicates drop

joinby group year using gwg_lasso_long

save yg_n_gwg, replace

use mu_mb, clear

preserve

rename yr year
rename gp group
rename ag age
rename mu mu

keep year - mu

gen source = "marry"

save mu_mar, replace

restore

drop yr - mu

rename yrb year
rename gpb group
rename agb age
rename mub  mu

gen source = "bach_plus"

append using mu_mar

joinby year group age using yg_n_gwg

capture drop R* ci_*

cut_reg_eq age mu "gwg i.year" gwg "marry"
cut_reg_eq age mu "gwg i.year" gwg "bach_plus"

#delimit ;
twoway (line R1marry ci_lmarry ci_umarry R3, yaxis(1) lcolor(blue blue blue) lpattern(solid dash dash) mcolor(blue blue blue))
	   (line R1bach_plus ci_lbach_plus ci_ubach_plus R3, yaxis(2) lcolor(green green green) lpattern(solid dash dash) mcolor(green green green)),
name(gwg_ef, replace)
title("Marriage and Education Responses to GWG")
subtitle("By Age")
xtitle("Age")
ytitle("GWG Effect")
legend(off)
graphregion(color(white)) bgcolor(white);
#delimit cr

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
