************************************************************
*FLP Central City vs. Analysis - IPUMS
*First pass at %female employment and growth/gentrification
*M. Miller, 15F
************************************************************


cd "L:\Research\Resurgence\Working Files"

clear
clear matrix
clear mata

set maxvar 8000
set more off

global flp = "L:\Research\Resurgence\IPUMS"
global out = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Delayed Marriage\Dual Career HH\Output\10-23-2015"

**Preliminary Regressions of FLP on Urban Growth**

use "$flp\ipums_flp_22_65.dta", clear

keep year metarea metro datanum serial relate sex age agemarr yrmarr marst empstat presgl educ inctot valueh rent unitsstr bedrooms builtyr 
*To add: builtyr2

sort year metro datanum serial relate, stable

tostring year, gen(year_str)
tostring datanum, gen(datanum_str)
tostring serial, gen(serial_str)

gen hhid = year_str + datanum_str + serial_str

gen emp = 0
replace emp = 1 if empstat == 1

sum presgl, d

gen emp_high = 0
replace emp_high = 1 if presgl > r(p75)

gen     emp_sp = 0
replace emp_sp = 1 if hhid[_n]==hhid[_n+1] & relate == 1 & relate[_n+1] == 2 & empstat[_n+1] == 1

gen     emp_high_sp = 0
replace emp_high_sp = 1 if hhid[_n]==hhid[_n+1] & relate == 1 & relate[_n+1] == 2 & emp_high[_n+1] == 1

gen     hh_head = 0
replace hh_head = 1 if hhid[_n]!=hhid[_n-1] 

**At Least Bachelor's Degree 

gen     bach_plus = 0
replace bach_plus = 1 if educ > 10

**Age of Marriage Var

replace agemarr = age - (year - yrmarr) if year > 1980 & marst != 6
replace agemarr = . if year == 1980 & agemarr == 0

gen     ever_marry = 0
replace ever_marry = 1 if marst != 6

**Dual Earners defined at HH level!

gen     dual_earn      = 0
replace dual_earn      = 1 if empstat == 1 & emp_sp == 1
gen     dual_earn_high = 0
replace dual_earn_high = 1 if emp_high == 1 & emp_high_sp == 1

replace dual_earn      = . if relate != 1
replace dual_earn_high = . if relate != 1

**Units

tab unitsstr, gen(units)

generate units2pl  = 0
replace  units2pl  = 1 if unitsstr > 4
generate units3pl  = 0
replace  units3pl  = 1 if unitsstr > 5
generate units5pl  = 0
replace  units5pl  = 1 if unitsstr > 6
generate units10pl = 0
replace  units10pl = 1 if unitsstr > 7
generate units20pl = 0
replace  units20pl = 1 if unitsstr > 8
generate units50pl = 0
replace  units50pl = 1 if unitsstr > 9

**Units (Main, manual bin generation)

generate munit1d    = 0
replace  munit1d    = 1 if unitsstr < 4
generate munit1a    = 0
replace  munit1a    = 1 if unitsstr == 5
generate munit2_4   = 0
replace  munit2_4   = 1 if unitsstr > 5 & unitsstr < 7
generate munit5_10  = 0
replace  munit5_10  = 1 if unitsstr == 7
generate munit10_50 = 0 
replace  munit10_50 = 1 if unitsstr > 7 & unitsstr < 9
generate munit50pl  = units50pl

**Bedrooms

tab bedrooms, gen(beds)

gen bed1pl = 0
replace bed1pl = 1 if bedrooms > 1
gen bed2pl = 0
replace bed2pl = 1 if bedrooms > 2
gen bed3pl = 0
replace bed3pl = 1 if bedrooms > 3
gen bed4pl = 0
replace bed4pl = 1 if bedrooms > 4
gen bed5pl = 0
replace bed5pl = 1 if bedrooms > 5
gen bed6pl = 0
replace bed6pl = 1 if bedrooms > 6

**Beds (Main, manual bin generation)

generate mbed0   = beds1
generate mbed1   = beds2
generate mbed2   = beds3
generate mbed3   = beds4
generate mbed4pl = 0
replace  mbed4pl = 1 if bedrooms > 3 
 
**Metro 

*(many obs without central/principal city status known)

**Age of Unit
/*
gen     hu_age10 = 0
replace hu_age10 = 1 if year == 1980 & builtyr < 4
replace hu_age10 = 1 if year == 2000 & (builtyr2 == 7 | builtyr2 == 8)
replace hu_age10 = 1 if year == 2010 & builtyr2 > 8

gen     hu_age10_20 = 0 
replace hu_age10_20 = 1 if year == 1980 & builtyr == 4 
replace hu_age10_20 = 1 if year == 2000 & builtyr2 == 6 
replace hu_age10_20 = 1 if year == 2010 & (builtyr2 == 7)  

gen     hu_age20_30 = 0
replace hu_age20_30 = 1 if year == 1980 & builtyr  == 5
replace hu_age20_30 = 1 if year == 2000 & builtyr2 == 5
replace hu_age20_30 = 1 if year == 2010 & builtyr2 == 6

gen     hu_age30_40 = 0
replace hu_age30_40 = 1 if year == 1980 & builtyr  == 6
replace hu_age30_40 = 1 if year == 2000 & builtyr2 == 4
replace hu_age30_40 = 1 if year == 2010 & builtyr2 == 5
 
gen     hu_age40pl  = 0
replace hu_age40pl  = 1 if year == 1980 & builtyr  == 7 
replace hu_age40pl  = 1 if year == 2000 & builtyr2 < 3 
replace hu_age40pl  = 1 if year == 2010 & builtyr2 < 4  
 
**Occupancy

*gen     own = 0
*replace own = 1 if ownershp == 1
*/
gen hold = 1

gen cc = .
replace cc = 1 if metro == 2
replace cc = 0 if metro == 1 | metro == 3 

*Individual Stats

global x_p  "units5pl mbed4pl"

preserve

collapse (sum) bach_plus hold emp emp_high $x_p hh_head  (mean)  age agemarr inctot rent valueh, by(year metarea cc) 

rename emp      emp_tot
rename emp_high emp_high_tot

foreach v  of varlist $x_p {
replace `v' = `v'/hh_head
}

save citywide, replace

restore

collapse (sum) bach_plus hold emp emp_high, by(year metarea cc sex)

reshape clear
reshape i year metarea cc
reshape j sex
reshape xij bach_plus hold emp emp_high
reshape wide

joinby year metarea cc using citywide

drop if cc == .
keep if year == 1980 | year == 2000 | year == 2010

**Share variables

gen emp_hg = 100*(emp_high_tot/emp_tot)

gen f_hh = 100*(emp_high2/emp_high_tot)
gen f_hg = 100*(emp_high2/emp_tot)
gen f_gg = 100*(emp2/emp_tot)

gen m_hh = 100*(emp_high1/emp_high_tot)
gen m_hg = 100*(emp_high1/emp_tot)
gen m_gg = 100*(emp1/emp_tot)

label var f_gg "\% Female of All Emp"
label var f_hh "\% Female High Emp of High Emp"
label var f_hg "\% Female High Emp of All Emp" 
label var m_gg "\% Male of All Emp"
label var m_hh "\% Male High Emp of High Emp"
label var m_hg "\% Male High Emp of All Emp" 

gen bach_perc = 100*(bach_plus/hold)
gen f_b       = 100*(bach_plus2/bach_plus)
gen m_b       = 100*(bach_plus1/bach_plus)

label var f_b "% Female Bach Plus"
label var m_b "% Male Bach Plus"

gen rinc = inctot
replace rinc = rinc/0.38 if year == 1980
replace rinc = rinc/0.79 if year == 2000

gen lpop = ln(hold)
gen linc = ln(rinc)

label var linc       "Log Avg HH Income"
label var bach_perc  "\% Pop with Bachelor Deg +"
label var age        "Average Age"
label var agemarr    "Average Age First Married"
label var rent       "Average Rent"
label var mbed4pl    "4+ Bedrooms"
*label var hu_age40pl "House Age 40+ yrs"
label var units5pl   "5+ units"
 

#delimit ;
twoway (scatter rinc f_hg if year == 1980 & cc == 1) (scatter rinc f_hg if year == 2000 & cc == 1) (scatter rinc f_hg if year == 2010 & cc == 1)
(lfit rinc f_hg if year == 1980 & cc == 1) (lfit rinc f_hg if year == 2000 & cc == 1) (lfit rinc f_hg if year == 2010 & cc == 1),
name(f_hg, replace)
title("Central City Income versus FLP (High)")
xtitle("% Labor Force FLP High")
ytitle("Income (2010 dollars)")
legend(order(1 "1980" 2 "2000" 3 "2010"))	
graphregion(color(white)) bgcolor(white);
#delimit cr

#delimit ;
twoway (scatter rinc m_hg if year == 1980 & cc == 1) (scatter rinc m_hg if year == 2000 & cc == 1) (scatter rinc m_hg if year == 2010 & cc == 1)
(lfit rinc m_hg if year == 1980 & cc == 1) (lfit rinc m_hg if year == 2000 & cc == 1) (lfit rinc m_hg if year == 2010 & cc == 1),
name(m_hg, replace)
title("Central City Income versus FLP (High)")
xtitle("% Labor Force MLP High")
ytitle("Income (2010 dollars)")
legend(order(1 "1980" 2 "2000" 3 "2010"))	
graphregion(color(white)) bgcolor(white);
#delimit cr

#delimit ;
twoway (scatter rinc agemarr if year == 1980 & cc == 1) (scatter rinc agemarr if year == 2000 & cc == 1) (scatter rinc agemarr if year == 2010 & cc == 1)
(lfit rinc agemarr if year == 1980 & cc == 1) (lfit rinc agemarr if year == 2000 & cc == 1) (lfit rinc agemarr if year == 2010 & cc == 1),
name(agemarr, replace)
title("Central City Income versus Age Married")
xtitle("Age Married")
ytitle("Income (2010 dollars)")
legend(order(1 "1980" 2 "2000" 3 "2010"))	
graphregion(color(white)) bgcolor(white);
#delimit cr

graph export "$out\f_hg_trend.png", replace name(f_hg)
graph export "$out\agemarr_trend.png", replace name(agemarr)

*keep if cc == 1

replace year = 1990 if year == 1980

sort year metarea cc

gen incrat = .
replace incrat = inctot[_n]/inctot[_n-1] if cc == 1 & metarea[_n]==metarea[_n-1]

areg linc   emp_hg bach_perc age rent cc $x_p, r absorb(year)
reg  incrat  emp_hg bach_perc age rent cc $x_p, r 


*xtset metarea year, delta(10)

global x "bach_perc age rent $x_p"

eststo: reg linc f_gg $x, r
eststo: reg linc f_gg $x if cc == 1, r
eststo: reg linc f_gg $x if cc == 0, r

#delimit ;
esttab using "$out\reg_f_gg.tex", replace title("Central City Income and Female Labor Force Participation")
label r2;
#delimit cr

clear matrix

eststo: reg linc f_hg $x, r
eststo: reg linc f_hg $x if cc == 1, r
eststo: reg linc f_hg $x if cc == 0, r


eststo: reg incrat f_hg $x if cc == 1, r

xx
#delimit ;
esttab using "$out\reg_f_hg.tex", replace title("Central City Income and Female Labor Force Participation")
label r2;
#delimit cr

clear matrix

eststo: reg linc f_hh $x, r
eststo: reg linc f_hh $x if cc == 1, r
eststo: reg linc f_hh $x if cc == 0, r

#delimit ;
esttab using "$out\reg_f_hh.tex", replace title("Central City Income and Female Labor Force Participation")
label r2;
#delimit cr

eststo: areg linc f_hg f_b agemarr, r absorb(metarea)

clear matrix




