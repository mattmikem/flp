********************************************
*CBSA level Gender Wage Gaps
*Basic and Blinder-Oaxaca
*M. Miller, 15F
********************************************

cd "L:\Research\Resurgence\Working Files"

clear
clear matrix

set more off

global data = "L:\Research\Resurgence\GIS\Working Files\Output\Test"
global work = "L:\Research\Resurgence\Working Files"  

use "$flp\ipums16_flp_22_65.dta", clear

replace metarea = met2013 if year > 1990

keep if inlist(year, 1980, 1990, 2000, 2010)

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

gen exp = age - educy - 6

**Female

gen female = 0
replace female = 1 if sex == 2

**Some negative values

gen agesq = age*age

egen group = group(metarea)

quietly sum group

global J = r(max)

set matsize 1000

mat res = J($J, 8, .) 
xx
global yy = 0

forvalues y = 1980(10)2010 {

global yy = $yy + 1

forvalues j = 1/$J {

quietly sum if year == `y' & group == `j'

disp "`y' : `j'"

if r(N) > 0 {

quietly reg lwage female educy age agesq if year == `y' & group == `j'
mat est = e(b)
mat V   = e(V)
mat res[`j', $yy]   = est[1,1]
global $yy = $yy + 1
mat res[`j', $yy] = sqrt(V[1,1])

*quietly oaxaca lwage educy age agesq if year == `y' & group == `j', by(female) pooled
*mat est = e(b)
*mat V   = vecdiag(e(V))
*mat res[`j', 3] = est[1,5]
*mat res[`j', 4] = sqrt(V[5,5])

}
}
}




