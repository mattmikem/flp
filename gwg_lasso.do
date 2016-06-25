********************************************
*CBSA level Gender Wage Gaps
*Double Selection LASSO
*M. Miller, 16S
********************************************

timer on 1

cd "L:\Research\Resurgence\Working Files"

clear
clear matrix

set more off

global data = "L:\Research\Resurgence\GIS\Working Files\Output\Test"
global work = "L:\Research\Resurgence\Working Files"  
global flp  = "L:\Research\Resurgence\IPUMS"
global link = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Delayed Marriage\Programs"

*use "$flp\ipums16_flp_22_65.dta", clear
use "$flp\ipums22_flps_18_65.dta", clear

replace metarea = met2013 if year > 1990

keep if inlist(year, 1970, 1980, 1990, 2000, 2010)

gen lwage = ln(incwage)
				  
**High Prestige Employment

sum presgl, d

gen     emp_high = 0
replace emp_high = 1 if presgl > r(p75)

**Education (Years)

gen     educy = 0
replace educy = 3.5   if educ == 1
replace educy = 8.5   if educ == 2
replace educy = 11    if educ == 3
replace educy = 12    if educ == 4 
replace educy = 13    if educ == 5
replace educy = 14    if educ == 6
replace educy = 15    if educ == 7
replace educy = 16    if educ == 8
replace educy = 17    if educ == 9
replace educy = 18    if educ == 10
replace educy = 20    if educ == 11

**Experience

gen exp  = age - educy - 6
gen exp2 = exp*exp

**Female

gen female = 0
replace female = 1 if sex == 2

**Some negative values

gen agesq = age*age

*Removed for data completeness reasons: agemarr
*Removed for geographic concerns: sizepl

**1970 adjustment to hours worked

replace uhrswork = 7.5   if hrswork2 == 1 & year == 1970
replace uhrswork = 22.5  if hrswork2 == 2 & year == 1970
replace uhrswork = 32    if hrswork2 == 3 & year == 1970
replace uhrswork = 37.5  if hrswork2 == 4 & year == 1970
replace uhrswork = 40    if hrswork2 == 5 & year == 1970
replace uhrswork = 44.5  if hrswork2 == 6 & year == 1970
replace uhrswork = 54    if hrswork2 == 7 & year == 1970
replace uhrswork = 60    if hrswork2 == 8 & year == 1970

*bpl_* degfield_* uhrswork*

egen group = group(metarea)

quietly sum group

global J = r(max)

set matsize 1000

set more off


**Standard Mincer Regressions

mat res = J($J, 10, .) 

do "$link\var_in_j.do"

sort metarea, stable

foreach v of varlist occx_* indx_* {
by metarea: egen mean_`v' = mean(`v')
}

#delimit ;
global x_lasso = "educy exp exp2 uhrswork  race_*
                  hisp_* occx_* indx_* mean_occx_* mean_indx_*";
#delimit cr

**Variables excluded due to inconsistent inclusion: deg_field, met_stat

save temp, replace

forvalues j = 1/$J {

global yy = 0

forvalues y = 1970(10)2010 {

global yy = $yy + 1

quietly sum if year == `y' & group == `j'

disp "`y' : `j'"

if r(N) > 0 {

keep if year == `y' & group == `j'

quietly lassoShooting lwage $x_lasso, lasiter(100) verbose(0) fdisplay(0)
local ysel `r(selected)'
quietly lassoShooting female $x_lasso, lasiter(100) verbose(0) fdisplay(0)
local xse; `r(selected)'
local xysel : list xsel | ysel

quietly reg lwage female `xysel', r

mat est = e(b)
mat V   = e(V)
mat res[`j', $yy]   = est[1,1]
global yy = $yy + 1
mat res[`j', $yy] = sqrt(V[1,1])

*quietly oaxaca lwage educy age agesq if year == `y' & group == `j', by(female) pooled
*mat est = e(b)
*mat V   = vecdiag(e(V))
*mat res[`j', $yy] = est[1,5]
*global yy = $yy + 1
*mat res[`j', $yy] = sqrt(V[5,5])

}

else {

global yy = $yy + 1

}

use temp, clear

}
}

svmat res

save ipums_gwg_lasso, replace

use ipums_gwg_lasso, clear

keep res* group

sum group

global J = r(max)

drop group

gen group_id = _n

rename res1  gwg1970
rename res2  se1970
rename res3  gwg1980
rename res4  se1980
rename res5  gwg1990
rename res6  se1990
rename res7  gwg2000
rename res8  se2000
rename res9  gwg2010
rename res10 se2010

rename group_id group

keep if group <= $J

save gwg_lasso_wide, replace

reshape clear
reshape i group
reshape j year
reshape xij gwg se
reshape long

save gwg_lasso_long, replace




xx

#delimit ;

kdensity gwg1980, 
addplot(kdensity gwg1990 || 
		kdensity gwg2000 || 
		kdensity gwg2010) 
legend(order(1 "1980" 2 "1990" 3 "2000" 4 "2010") c(2) r(2))
graphregion(color(white)) bgcolor(white)
title("Gender Wage Gap Density - General Employment")
name(gwg_dens, replace);
#delimit cr 

