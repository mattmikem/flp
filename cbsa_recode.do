********************************************
*CBSA Recode in IPUMS
*M. Miller, 16X
********************************************

timer on 1

cd "L:\Research\Resurgence\Working Files"

clear
clear matrix

set more off

global work = "L:\Research\Resurgence\Working Files"  
global flp  = "L:\Research\Resurgence\IPUMS"

*use "$flp\ipums16_flp_22_65.dta", clear
use "$flp\ipums22_flps_18_65.dta", clear

replace metarea = met2013 if year > 1990

drop if metarea == .

tostring metarea, gen(cbsa_late)
replace cbsa_late = "31100" if cbsa_late == "31080"

decode metarea, gen(metarea_str)
gen state = substr(metarea_str, strpos(metarea_str, ",")+2, 2)

joinby metarea using msa1990_cbsa, unmatched(master)
drop _merge

replace cbsa = "0" if state == "ot"

replace cbsa = cbsa_late if year > 1990

egen group = group(cbsa)

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

**Marital Status

gen emarry = 0
replace emarry = 1 if marst < 6

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


save ipums_withcbsa, replace
