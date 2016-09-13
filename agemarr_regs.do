********************************************
*Age at Marriage Probit
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

*do "$link\lassoShooting.ado"

*use "$flp\ipums16_flp_22_65.dta", clear
use ipums_withcbsa, clear

keep year metro metaread city rent hhincome valueh sex age marst agemarr yrmarr higraded educ educy emp_high emarry lwage group state region trantime

replace agemarr = age - (2010 - yrmarr) if year == 2010 & yrmarr != 0 

joinby group year using gwg_lasso_long_alts, unmatched(master)

gen central_city = .
replace central_city = 1 if metro == 3
replace central_city = 0 if metro == 1 | metro == 2

gen e_delta = educy*delta
gen e_eta   = educy*a_eta
gen delta2  = delta*delta
gen a_eta2  = a_eta*a_eta
gen educy2  = educy*educy
gen del_eta = delta*a_eta

label var delta "Gender Wage Gap (Single)"
label var a_eta "Female Wage Kink"
label var educy "Years of Schooling"
label var emarry "Prob of Marriage"
label var central_city "Prob of Cen City"
label var e_delta "Gender Wage Gap $\times$ Yrs School"

xtset group

*xtreg emarry age delta a_eta educy i.year if year > 1970, fe vce(robust)
*xtreg emarry age delta a_eta educy e_delta e_eta del_eta delta2 a_eta2 educy2 i.year, fe vce(robust)

*eststo: logit emarry age delta a_eta educy i.year, robust cluster(group)
eststo: logit emarry age delta a_eta educy e_delta e_eta del_eta a_eta2 educy2 i.year if year > 1970 & group_n == 5, robust cluster(group)
eststo: margins, dydx(delta a_eta educy e_delta) post


*eststo: logit central_city age delta a_eta educy i.year, robust cluster(group)
eststo: logit central_city age delta a_eta educy e_delta e_eta a_eta2 educy2 i.year if year > 1970 & group_n == 5, robust cluster(group)
eststo: margins, dydx(delta a_eta educy e_delta) post

*if year > 1970 & group > 1 & group_n == 5

#delimit ;
esttab using "$out\agemarr_regs.tex", replace label r2
title("Marriage and City Living Probabilities as a Function of Gender Wage Gap Components")
order(delta a_eta educy)
keep(delta a_eta educy)
mtitle("Marry (Logit)" "Marry (ME)" "Central City (Logit)" "Central City (ME)")
star(+ .1 * 0.05 ** 0.01 *** 0.001)
addn(
"Logit: standard Logit parameter estimates, also the negative of the age of marriage parameters."
"ME columns indicate the marginal effect of variables on outcome (i.e. probability of marriage or living in central city.)"
"All specifications are logit estimates that include year fixed effects and cluster-robust standard errors by metro area." );
#delimit cr

 xx
