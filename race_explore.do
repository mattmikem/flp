*************************************************
*FLP Central City vs. Analysis - IPUMS
*M. Miller, 15F
*************************************************


cd "L:\Research\Resurgence\Working Files"

clear
clear matrix
clear mata

set maxvar 8000
set more off

global flp = "L:\Research\Resurgence\IPUMS"
global out = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Delayed Marriage\Output\03-09-2016"

**Household Composition and Central City (education, employment status, by geotype)

*Limit to Females, ages 22 - 35

use "$flp\ipums16_flps_fem22_35.dta", clear

drop citypop

joinby metarea year using metarea_pop, unmatched(master)

**Geographic Status

gen hold = 1
gen count = .
gen bach_count = .
gen emp_count = .
gen emp_h_count = .

gen     central_city = 0
replace central_city = 1 if metro == 2
gen     metro_not_cc = 0
replace metro_not_cc = 1 if metro == 3
gen     non_metro    = 0
replace non_metro    = 1 if metro == 1 

gen     geotype_num = .
replace geotype_num = 1 if metro == 2
replace geotype_num = 2 if metro == 3 
replace geotype_num = 3 if metro == 1


gen     geotype = "Unknown"
replace geotype = "Central City"       if metro == 2
replace geotype = "Metro, Non-Central" if metro == 3
replace geotype = "Non-Metro"          if metro == 1

**At Least Bachelor's Degree 

gen     bach_plus = 0
replace bach_plus = 1 if educ > 10 & educ != .

**FLP

gen     emp = 0
replace emp = 1 if empstat == 1
*replace emp = . if empstat == 2

**FLP (above median occupation prestige)

sum presgl if presgl != 0, d

*gen     emp_high = 0
*replace emp_high = 1 if empstat == 1 & presgl > r(p75)
*replace emp = 0 if emp_high == 1

gen     marry = 0
replace marry = 1 if marst == 1 | marst == 2

gen mar_emp      = emp*marry
*gen mar_emp_high = emp_high*marry

gen mar_nchild = marry*nchild

gen mar_emp_nchild = marry*nchild*emp

gen emp_nchild = emp*nchild

**Regressions - Prob of Living in Central City

global x     "bach_plus emp age marry nchild"
global x_int "bach_plus emp age linc marry nchild mar_emp mar_nchild emp_nchild mar_emp_nchild"

*Check LPM not affecting much (true, Probit estimates very similar to OLS)

label var central_city "Central City"
label var bach_plus "Bachelor Degree"
label var emp       "Employed"
label var age       "Age"
label var marry     "Married"
label var nchild    "Num Children"
/*
foreach y in 1980 1990 2000 2010 {

eststo: reg central_city $x if year == `y', r 
eststo: areg central_city $x if year == `y', cluster(metarea) absorb(metarea)
probit central_city $x if year == `y'
eststo mfx: mfx

esttab using "$out\lpm_`y'.tex", replace margin title("LPM versus Probit Estimates") label 
clear matrix

}
*/

*Full Spec (still need additional controls)

*keep if citypop > 10000

gen linc = ln(ftotinc)

**Income quartiles by year

label var ftotinc "Total Family Income"
label var linc "Log Family Income"
label var  bach_plus "Bachelor or Advanced Degree"
label var emp "Employed"
label var age "Age"
label var marry "Married"
label var nchild "Num Children"
label var mar_emp "Married $\times$ Employed"
label var mar_nchild "Married $\times$ Num Child"
label var emp_nchild "Employed $\times$ Num Child"
label var mar_emp_nchild "Mar $\times$ Emp $\times$ Num Child"

gen mar_minempmar = marry*emp-emp-marry
gen mar_minchd    = nchild*(marry-1)

label var marry "(1) Single vs. Married"
label var emp   "(2) Lone vs. Dual-Earner"
label var nchil "(3) No Children vs. Children"

gen white = 0
replace white = 1 if race == 1
gen black = 0
replace black = 1 if race == 2


gen     title = ""
replace title = "White" if _n == 1
replace title = "Black" if _n == 2

local j = 1

foreach r of varlist white black {

forvalues y = 1980(10)2010 {
reg central_city emp marry nchild mar_emp mar_nchild emp_nchild mar_emp_nchild bach_plus age linc if year == `y' & `r' == 1, r
disp _b[marry]+_b[mar_emp]
disp _b[emp]+_b[mar_emp]
disp _b[nchild]+_b[mar_nchild]

eststo: reg  central_city emp marry nchild mar_minempmar mar_minchd emp_nchild mar_emp_nchild bach_plus age linc if year == `y' & `r' == 1, r
eststo: areg central_city emp marry nchild mar_minempmar mar_minchd emp_nchild mar_emp_nchild bach_plus age linc if year == `y' & `r' == 1, r absorb(metarea)

}

local t = title[`j']
local title = "Probality of Living in Central City - Standard Employment Case for " +"`t'" 

#delimit ;
esttab using "$out\reg_`r'_eg.tex", replace label r2
mtitles("1980 (OLS)" "1980 (FE)" "1990 (OLS)" "1990 (FE)" "2000 (OLS)" "2000 (FE)" "2010 (OLS)" "2010 (FE)") 
title("`title'")
order(marry emp nchild) keep(marry emp nchild) ;
#delimit cr

local j = `j' + 1

clear matrix
}

*HIGH PRESTIGE EMPLOYMENT

sum presgl, d

gen emp_high = 0
replace emp_high = 1 if presgl > r(p75)

gen mar_emp_high = marry*emp_high
gen mar_emph_nchild = marry*emp_high*nchild
gen emp_high_nchild  = emp_high*nchild

label var emp_high        "Employed (High Prestige)"
label var mar_emp_high    "Married $\times$ Employed (HP)"
label var mar_emph_nchild "Married $\times$ Employed (HP) $\times$ Num Child"
label var emp_high_nchild "Employed (HP) $\times$ Num Child"
 
label var emp_high "(2) Lone vs. Dual-Earner" 
 
gen mar_mehmar = marry*emp_high - emp_high - marry

local j = 1

foreach r of varlist white black {

forvalues y = 1980(10)2010 {
reg central_city emp_high marry nchild mar_emp_high mar_nchild emp_high_nchild mar_emph_nchild bach_plus age linc if year == `y', r
*reg central_city emp_high marry nchild mar_emp_high mar_nchild emp_high_nchild mar_emph_nchild bach_plus age linc if year == `y', r
disp _b[marry]+_b[mar_emp_high]
disp _b[emp_high]+_b[mar_emp_high]
disp _b[nchild]+_b[mar_nchild]

eststo: reg  central_city emp_high marry nchild mar_mehmar mar_minchd emp_high_nchild mar_emph_nchild bach_plus age linc if year == `y' & `r' == 1, r
eststo: areg central_city emp_high marry nchild mar_mehmar mar_minchd emp_high_nchild mar_emph_nchild bach_plus age linc if year == `y' & `r' == 1, r absorb(metarea)

}

local t = title[`j']
local title = "Probality of Living in Central City - High Employment Case for " +"`t'" 

#delimit ;
esttab using "$out\reg_`r'_eh.tex", replace label r2
mtitles("1980 (OLS)" "1980 (FE)" "1990 (OLS)" "1990 (FE)" "2000 (OLS)" "2000 (FE)" "2010 (OLS)" "2010 (FE)") 
title("`title'")
order(marry emp_high nchild) keep(marry emp_high nchild)
addnote("High Prestige employment based on occupation in highest quartile of Siegel career prestige scale."
"Regressions include interactions of employment, marital status and number of children, in addition to"
"educational attainment, age, and income measures.")
 ;
#delimit cr

local j = `j' + 1

clear matrix
}
