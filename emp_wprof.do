********************************************
*Empirical Counterpart of Wage Profile
*M. Miller, 16X
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
gen wage = incwage/1000

#delimit ;
twoway (lpoly wage age if  marst == 6 & sex == 2 & year == 1980 & age > 19 & age < 45, xline(22) lcolor(green) lpattern(solid)) 
(lpoly wage age if  marst == 6 & sex == 1 & year == 1980 & age > 19 & age < 45, lcolor(orange) lpattern(solid)) 
(lpoly wage age if  marst == 1 & sex == 2 & year == 1980 & age > 19 & age < 45, lcolor(green) lpattern(dash)) 
(lpoly wage age if  marst == 1 & sex == 1 & year == 1980 & age > 19 & age < 45, lcolor(orange) lpattern(dash)),
xtitle("Age")
ytitle("Wage ($000s)")
title("Wage Profiles by Gender and Marital Status")
name(wprof_1980, replace)
legend(order(1 "Single (Female)" 2 "Single (Male)" 3 "Married (Female)" 4 "Married (Male)"))
graphregion(color(white)) bgcolor(white);
#delimit cr



#delimit ;
twoway (lpoly incwage age if marst == 6 & sex == 2 & year == 2010 & age > 19 & age < 45, xline(28) lcolor(green) lpattern(solid)) 
(lpoly incwage age if marst == 6 & sex == 1 & year == 2010 & age > 19 & age < 45, lcolor(orange) lpattern(solid)) 
(lpoly incwage age if marst == 1 & sex == 2 & year == 2010 & age > 19 & age < 45, lcolor(green) lpattern(dash)) 
(lpoly incwage age if marst == 1 & sex == 1 & year == 2010 & age > 19 & age < 45, lcolor(orange) lpattern(dash)),
xtitle("Age")
ytitle("Wage ($000s)")
title("Wage Profiles by Gender and Marital Status")
name(wprof_2010, replace)
legend(order(1 "Single (Female)" 2 "Single (Male)" 3 "Married (Female)" 4 "Married (Male)"))
graphregion(color(white)) bgcolor(white);
#delimit cr
