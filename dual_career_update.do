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
*Output folder set for 3/28 presentation
global out = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Delayed Marriage\Presentations"

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
replace bach_plus = 1 if educ > 10

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
gen nc_maemnch    = nchild - mar_emp_nchild
gen marnc_maemnch = mar_nchild - mar_emp_nchild
gen empnc_maemnch = emp_nchild - mar_emp_nchild

label var marry "(1) Single vs. Married"
label var emp   "(2) Lone vs. Dual-Earner"
label var mar_emp_nchild "(3) No Children vs. Children"

forvalues y = 1980(10)2010 {
*reg central_city emp marry nc_maemnch mar_emp mar_nchild emp_nchild mar_emp_nchild bach_plus age linc if year == `y', r
*disp _b[marry]+_b[mar_emp]
*disp _b[emp]+_b[mar_emp]
*disp _b[nchild]+_b[mar_nchild]

eststo: reg  central_city emp marry nc_maemnch mar_minempmar marnc_maemnch empnc_maemnch mar_emp_nchild bach_plus age linc if year == `y', r
eststo: areg central_city emp marry nc_maemnch mar_minempmar marnc_maemnch empnc_maemnch mar_emp_nchild bach_plus age linc if year == `y', r absorb(metarea)

*eststo: reg  central_city emp marry nchild mar_minempmar mar_minchd emp_nchild mar_emp_nchild bach_plus age linc if year == `y', r
*eststo: areg central_city emp marry nchild mar_minempmar mar_minchd emp_nchild mar_emp_nchild bach_plus age linc if year == `y', r absorb(metarea)

}

#delimit ;
esttab using "$out\reg_eg.tex", replace label r2
mtitles("1980 (OLS)" "1980 (FE)" "1990 (OLS)" "1990 (FE)" "2000 (OLS)" "2000 (FE)" "2010 (OLS)" "2010 (FE)") 
title("Probality of Living in Central City - Standard Employment Case")
order(marry emp mar_emp_nchild) keep(marry emp mar_emp_nchild) ;
#delimit cr

clear matrix

*mat TT = J(6,6,.)
/*
foreach y in 1980 1990 2000 2010 {

quietly sum ftotinc if year == `y', d

local q1 = r(p25)
local q2 = r(p50)
local q3 = r(p75)

*All

eststo: reg central_city $x_int if year == `y' , r 
if _b[marry]+_b[mar_emp] < 0 {
disp _b[marry]+_b[mar_emp] 
test marry + mar_emp = 0
}
if _b[emp]+_b[mar_emp] > 0 {
disp _b[emp]+_b[mar_emp]
test emp + mar_emp = 0
}
if _b[nchild] + _b[mar_nchild] < 0 {
disp _b[nchild] + _b[mar_nchild]
test nchild + mar_nchild = 0
}

eststo: areg central_city $x_int if year == `y', cluster(metarea) absorb(metarea)
if _b[marry]+_b[mar_emp] < 0 {
disp _b[marry]+_b[mar_emp] 
test marry + mar_emp = 0 
}
if _b[emp]+_b[mar_emp] > 0 {
disp _b[emp]+_b[mar_emp]
test emp + mar_emp = 0
}
if _b[nchild] + _b[mar_nchild] < 0 {
disp _b[nchild] + _b[mar_nchild]
test nchild + mar_nchild = 0
}

/*
*Q1 (0-25)

eststo: reg central_city $x_int if year == `y' & ftotinc < `q1' , r 
eststo: areg central_city $x_int if year == `y' & ftotinc < `q1', cluster(metarea) absorb(metarea)

*Q2 (25-50)

eststo: reg central_city $x_int if year == `y' & ftotinc >= `q1' & ftotinc < `q2' , r 
eststo: areg central_city $x_int if year == `y' & ftotinc >= `q1' & ftotinc < `q2', cluster(metarea) absorb(metarea)

*Q3 (50-75)

eststo: reg central_city $x_int if year == `y' & ftotinc >= `q2' & ftotinc < `q3' , r 
eststo: areg central_city $x_int if year == `y' & ftotinc >= `q2' & ftotinc < `q3', cluster(metarea) absorb(metarea)

*Q4 (75-100)

eststo: reg central_city $x_int if year == `y' & ftotinc >= `q3' , r 
eststo: areg central_city $x_int if year == `y' & ftotinc >= `q3', cluster(metarea) absorb(metarea)
*/
}

*esttab using "$out\reg1.csv", replace mtitles("1980 All (OLS)" "1980 All (FE)" "1980 Q1 (OLS)" "1980 Q1 (FE)" "1980 Q2 (OLS)" "1980 Q2 (FE)" "1980 Q3 (OLS)" "1980 Q3 (FE)" "1980 Q4 (OLS)" "1980 Q4 (FE)" "2000 All (OLS)" "2000 All (FE)" "2000 Q1 (OLS)" "2000 Q1 (FE)" "2000 Q2 (OLS)" "2000 Q2 (FE)" "2000 Q3 (OLS)" "2000 Q3 (FE)" "2000 Q4 (OLS)" "2000 Q4 (FE)" "2010 All (OLS)" "2010 All (FE)" "2010 Q1 (OLS)" "2010 Q1 (FE)" "2010 Q2 (OLS)" "2010 Q2 (FE)" "2010 Q3 (OLS)" "2010 Q3 (FE)" "2010 Q4 (OLS)" "2010 Q4 (FE)") 
#delimit ;
esttab using "$out\reg1.tex", replace label r2
mtitles("1980 (OLS)" "1980 (FE)" "1990 (OLS)" "1990 (FE)" "2000 (OLS)" "2000 (FE)" "2010 (OLS)" "2010 (FE)") 
title("Probality of Living in Central City")
order(emp marry nchild mar_emp mar_nchild emp_nchild mar_emp_nchild bach_plus linc age) ;
#delimit cr

clear matrix
*/
*LIMIT TO BACHELOR DEGREE ONLY

**Income quartiles by year
/*
foreach y in 1980 2000 2010 {

quietly sum ftotinc if year == `y', d

local q1 = r(p25)
local q2 = r(p50)
local q3 = r(p75)

*All

*eststo: reg central_city $x_int if year == `y' & bach_plus == 1 , r 
*eststo: areg central_city $x_int if year == `y' & bach_plus == 1, cluster(metarea) absorb(metarea)

*Q1 (0-25)

eststo: reg central_city $x_int if year == `y' & ftotinc < `q1' & bach_plus == 1 , r 
eststo: areg central_city $x_int if year == `y' & ftotinc < `q1' & bach_plus == 1, cluster(metarea) absorb(metarea)

*Q2 (25-50)

eststo: reg central_city $x_int if year == `y' & ftotinc >= `q1' & ftotinc < `q2' & bach_plus == 1 , r 
eststo: areg central_city $x_int if year == `y' & ftotinc >= `q1' & ftotinc < `q2' & bach_plus == 1, cluster(metarea) absorb(metarea)

*Q3 (50-75)

eststo: reg central_city $x_int if year == `y' & ftotinc >= `q2' & ftotinc < `q3' & bach_plus == 1, r 
eststo: areg central_city $x_int if year == `y' & ftotinc >= `q2' & ftotinc < `q3' & bach_plus == 1, cluster(metarea) absorb(metarea)

*Q4 (75-100)

eststo: reg central_city $x_int if year == `y' & ftotinc >= `q3' & bach_plus == 1, r 
eststo: areg central_city $x_int if year == `y' & ftotinc >= `q3'& bach_plus == 1, cluster(metarea) absorb(metarea)

}

esttab using "$out\reg_bach.csv", replace mtitles("1980 Q1 (OLS)" "1980 Q1 (FE)" "1980 Q2 (OLS)" "1980 Q2 (FE)" "1980 Q3 (OLS)" "1980 Q3 (FE)" "1980 Q4 (OLS)" "1980 Q4 (FE)" "2000 Q1 (OLS)" "2000 Q1 (FE)" "2000 Q2 (OLS)" "2000 Q2 (FE)" "2000 Q3 (OLS)" "2000 Q3 (FE)" "2000 Q4 (OLS)" "2000 Q4 (FE)" "2010 Q1 (OLS)" "2010 Q1 (FE)" "2010 Q2 (OLS)" "2010 Q2 (FE)" "2010 Q3 (OLS)" "2010 Q3 (FE)" "2010 Q4 (OLS)" "2010 Q4 (FE)") 
clear matrix
*/


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
 
gen mar_mehmar  = marry*emp_high - emp_high - marry
gen nch_maemch  = nchild - mar_emph_nchild
gen manc_maehch = mar_nchild - mar_emph_nchild
gen ehnc_maehch = emp_high_nchild - mar_emph_nchild

label var mar_emph_nchild "(3) No Children vs. Children"

forvalues y = 1980(10)2010 {
*reg central_city emp_high marry nchild mar_emp_high mar_nchild emp_high_nchild mar_emph_nchild bach_plus age linc if year == `y', r
*reg central_city emp_high marry nchild mar_emp_high mar_nchild emp_high_nchild mar_emph_nchild bach_plus age linc if year == `y', r
*disp _b[marry]+_b[mar_emp_high]
*disp _b[emp_high]+_b[mar_emp_high]
*disp _b[nchild]+_b[mar_nchild]

eststo: reg  central_city emp_high marry nch_maemch mar_mehmar manc_maehch ehnc_maehch mar_emph_nchild bach_plus age linc if year == `y', r
eststo: areg central_city emp_high marry nch_maemch mar_mehmar manc_maehch ehnc_maehch mar_emph_nchild bach_plus age linc if year == `y', r absorb(metarea)


*eststo: reg  central_city emp_high marry nchild mar_mehmar mar_minchd emp_high_nchild mar_emph_nchild bach_plus age linc if year == `y', r
*eststo: areg central_city emp_high marry nchild mar_mehmar mar_minchd emp_high_nchild mar_emph_nchild bach_plus age linc if year == `y', r absorb(metarea)

}

#delimit ;
esttab using "$out\reg_eh.tex", replace label r2
mtitles("1980 (OLS)" "1980 (FE)" "1990 (OLS)" "1990 (FE)" "2000 (OLS)" "2000 (FE)" "2010 (OLS)" "2010 (FE)") 
title("Probality of Living in Central City - High Employment Case")
order(marry emp_high mar_emph_nchild) keep(marry emp_high mar_emph_nchild)
addnote("High Prestige employment based on occupation in highest quartile of Siegel career prestige scale."
"Regressions include interactions of employment, marital status and number of children, in addition to"
"educational attainment, age, and income measures.")
 ;
#delimit cr

clear matrix
xx
/*
global x_int "bach_plus emp_high marry nchild mar_emp_high emp_high_nchild mar_nchild mar_emph_nchild age linc"

**Income quartiles by year

*keep if age < 28

clear matrix
clear mata

foreach y in 1980 2000 2010 {

quietly sum ftotinc if year == `y', d

local q1 = r(p25)
local q2 = r(p50)
local q3 = r(p75)

*All

eststo: reg central_city $x_int if year == `y', r 
if _b[marry]+_b[mar_emp_high] < 0 {
disp _b[marry]+_b[mar_emp_high] 
test marry + mar_emp_high = 0 
}
if _b[emp_high]+_b[mar_emp_high] > 0 {
disp _b[emp_high]+_b[mar_emp_high]
test emp_high + mar_emp_high = 0
}
if _b[nchild] + _b[mar_nchild] < 0 {
disp _b[nchild] + _b[mar_nchild]
test nchild + mar_nchild = 0
}
eststo: areg central_city $x_int if year == `y', cluster(metarea) absorb(metarea)
if _b[marry]+_b[mar_emp_high] < 0 {
disp _b[marry]+_b[mar_emp_high] 
test marry + mar_emp_high = 0 
}
if _b[emp_high]+_b[mar_emp_high] > 0 {
disp _b[emp_high]+_b[mar_emp_high]
test emp_high + mar_emp_high = 0
}
if _b[nchild] + _b[mar_nchild] < 0 {
disp _b[nchild] + _b[mar_nchild]
test nchild + mar_nchild = 0
}
/*
*Q1 (0-25)

eststo: reg central_city $x_int if year == `y' & ftotinc < `q1' , r 
eststo: areg central_city $x_int if year == `y' & ftotinc < `q1', cluster(metarea) absorb(metarea)

*Q2 (25-50)

eststo: reg central_city $x_int if year == `y' & ftotinc >= `q1' & ftotinc < `q2' , r 
eststo: areg central_city $x_int if year == `y' & ftotinc >= `q1' & ftotinc < `q2', cluster(metarea) absorb(metarea)

*Q3 (50-75)

eststo: reg central_city $x_int if year == `y' & ftotinc >= `q2' & ftotinc < `q3', r 
eststo: areg central_city $x_int if year == `y' & ftotinc >= `q2' & ftotinc < `q3', cluster(metarea) absorb(metarea)

*Q4 (75-100)

eststo: reg central_city $x_int if year == `y' & ftotinc >= `q3', r 
eststo: areg central_city $x_int if year == `y' & ftotinc >= `q3', cluster(metarea) absorb(metarea)
*/
}

*esttab using "$out\reg_highpres.csv", replace mtitles("1980 All (OLS)" "1980 All (FE)" "1980 Q1 (OLS)" "1980 Q1 (FE)" "1980 Q2 (OLS)" "1980 Q2 (FE)" "1980 Q3 (OLS)" "1980 Q3 (FE)" "1980 Q4 (OLS)" "1980 Q4 (FE)" "2000 All (OLS)" "2000 All (FE)" "2000 Q1 (OLS)" "2000 Q1 (FE)" "2000 Q2 (OLS)" "2000 Q2 (FE)" "2000 Q3 (OLS)" "2000 Q3 (FE)" "2000 Q4 (OLS)" "2000 Q4 (FE)" "2010 All (OLS)" "2010 All (FE)" "2010 Q1 (OLS)" "2010 Q1 (FE)" "2010 Q2 (OLS)" "2010 Q2 (FE)" "2010 Q3 (OLS)" "2010 Q3 (FE)" "2010 Q4 (OLS)" "2010 Q4 (FE)") 
#delimit ;
esttab using "$out\reg_highpres.tex", replace label r2
mtitles("1980 (OLS)" "1980 (FE)" "2000 (OLS)" "2000 (FE)" "2010 (OLS)" "2010 (FE)") 
order(emp_high marry nchild mar_emp_high mar_nchild emp_high_nchild mar_emph_nchild bach_plus linc age) 
title("Probality of Living in Central City (High Prestige Employment)")
note("High Prestige (HP) indicates occupation in highest quartile of Siegel career prestige scale.");
#delimit cr
*/

clear matrix

***Shock Regressions: Responses to changes in family status***

*[ADD SOME CONTROLS, show both]

use "$flp\ipums_flp_shockreg.dta", clear

clear matrix

keep if age > 18 & age < 65

global x = "hhincome bach_plus age"

**At Least Bachelor's Degree 

gen     bach_plus = 0
replace bach_plus = 1 if educ > 10

**Shocks

gen rec_marr = .
replace rec_marr = 1 if year - yrmarr < 2 & yrmarr != .
replace rec_marr = 0 if marst == 6 | marst == 4 

gen rec_sin = .
replace rec_sin = 1 if divinyr == 2 | widinyr == 2
replace rec_sin = 0 if divinyr == 1 & widinyr == 1

gen rec_div = .
replace rec_div = 1 if divinyr == 2 
replace rec_div = 0 if divinyr == 1 

gen rec_wid = .
replace rec_wid = 1 if widinyr == 2 
replace rec_wid = 0 if widinyr == 1 

gen rec_ch = .
replace rec_ch = 1 if fertyr == 2
replace rec_ch = 0 if fertyr == 1

gen rec_emp = .
replace rec_emp = 1 if (workedyr == 1 | workedyr == 2) & empstat == 1
replace rec_emp = 0 if (workedyr == 3 & empstat == 1) | ((workedyr == 1 | workedyr == 2) & empstat > 1)

gen rec_unemp = .
replace rec_unemp = 1 if (workedyr == 3 & empstat > 1)
replace rec_unemp = 0 if (workedyr == 3 & empstat == 1) | ((workedyr == 1 | workedyr == 2) & empstat > 1)

gen     city_sub = .
replace city_sub = 1 if (migtype1 == 3 & metro == 1) | (migtype1 == 3 & metro == 3) 
replace city_sub = 0 if ((migtype1 == 1 | migtype1 == 4) & (metro == 3 | metro == 1)) | (metro == 2) 

gen     sub_city = .
replace sub_city = 1 if (migtype1 == 1  | migtype1 == 4) & metro == 2
replace sub_city = 0 if (migtype1 == 3 & metro == 2) | metro != 2
 
label var city_sub  "Central City $\rightarrow$ Suburbs"  
label var sub_city  "Suburbs $\rightarrow$ Central City"
label var rec_marr  "Married within Last Year"
label var rec_sin   "Single within Last Year"
label var rec_div   "Divorced within Last Year"
label var rec_ch    "Child Birth within Last Year"
label var rec_emp   "Employed within Last Year"
label var rec_unemp "Unemployed within Last Year"
 
gen trend = year - 2008 
gen female = 0
replace female = 1 if sex == 2

gen recs_age = rec_sin*age
 
eststo: reg city_sub rec_marr $x trend if migtype1 == 3 & year > 2007 & year < 2012 & female == 1
eststo: reg sub_city rec_sin $x trend if  migtype1 == 4 & year > 2007 & year < 2012 & nchild == 0  & female == 1
*eststo: reg sub_city rec_sin recs_age $x female trend if (migtype1 == 1 | migtype1 == 4)  & year > 2007 & year < 2012 & nchild == 0
*eststo: reg sub_city rec_div $x trend if (migtype1 == 1 | migtype1 == 4)  & year > 2007 & year < 2012 & nchild == 0
*eststo: reg sub_city rec_wid $x trend if (migtype1 == 1 | migtype1 == 4)  & year > 2007 & year < 2012 & nchild == 0
eststo: reg city_sub rec_ch  $x trend if  migtype1 == 3  & year > 2007 & year < 2012 & female == 1
eststo: reg city_sub rec_unemp $x trend if migtype1 == 3 & year > 2007 & year < 2012 & female == 1

*eststo: areg city_sub rec_marr $x female trend if migtype1 == 3 & year > 2007 & year < 2012, absorb(year)
*eststo: areg sub_city rec_sin recs_age $x female trend if (migtype1 == 1 | migtype1 == 4)  & year > 2007 & year < 2012 & nchild == 0, absorb(year)
*eststo: reg sub_city rec_div $x trend if (migtype1 == 1 | migtype1 == 4)  & year > 2007 & year < 2012 & nchild == 0
*eststo: reg sub_city rec_wid $x trend if (migtype1 == 1 | migtype1 == 4)  & year > 2007 & year < 2012 & nchild == 0
*eststo: areg city_sub rec_ch  $x female trend if  migtype1 == 3  & year > 2007 & year < 2012, absorb(year)
*eststo: areg city_sub rec_unemp $x female trend if migtype1 == 3 & year > 2007 & year < 2012, absorb(year)

#delimit ;
esttab using "$out\reg_changes.tex", replace title("Migration in Response to Family Strucure and Employment Changes")
order(rec_marr rec_sin rec_ch rec_unemp) keep(rec_marr rec_sin rec_ch rec_unemp)
note("Additional controls include employment, income, education, and age." "Single within last year includes divorce and death of spouse.") 
label r2;
#delimit cr
clear matrix

gen emp = .
replace emp = 1 if empstat == 1
replace emp = 0 if empstat == 2

sum presgl, d

gen emp_high = 0
replace emp_high = 1 if empstat == 1
replace emp_high = 2 if presgl > r(p50)
replace emp_high = . if empstat > 2

tab emp_high, gen (eh_)

gen bach_emp   = bach_plus*emp
gen bach_emp_h = bach_plus*emp_high

gen bach_eh1 = bach_plus*eh_1
gen bach_eh2 = bach_plus*eh_2

label var bach_plus  "Bachelor Degree"
label var emp        "Employed"
label var emp_h      "Employed (High)"
label var bach_emp   "Bachelor Deg $\times$ Employed"
label var bach_emp_h "Bachelor Deg $\times$ Employed (High)"

eststo: reg sub_city bach_plus emp bach_emp  trend if age > 21 & age < 25 & (migtype1 == 1 | migtype1 == 4) & marst == 6
eststo: reg city_sub bach_plus emp bach_emp  trend if age > 21 & age < 25 & migtype1 == 3 & marst == 6


#delimit ;
esttab using "$out\reg_bach.tex", replace title("Migration in Response to Bachelor's Degree")
order(bach_plus emp bach_emp) keep(bach_plus emp bach_emp)
note("Limited to individuals age 22 - 24, never married.") 
label r2;
#delimit cr
clear matrix

xx
*eststo: reg sub_city bach_plus emp_high bach_emp_h trend if age > 21 & age < 26 & (migtype1 == 1 | migtype1 == 4) & marst == 6
*eststo: reg city_sub bach_plus emp_high bach_emp_h trend if age > 21 & age < 26 & migtype1 == 3 & marst == 6

*eststo: reg sub_city bach_plus eh_1 eh_2 bach_eh1 bach_eh2 trend if age > 21 & age < 26 & (migtype1 == 1 | migtype1 == 4) & marst == 6
*eststo: reg city_sub bach_plus eh_1 eh_2 bach_eh1 bach_eh2 trend if age > 21 & age < 26 & migtype1 == 3 & marst == 6


/*
probit city_sub rec_marr $x if migtype1 == 3
mfx
probit sub_city rec_div $x if (migtype1 == 1 | migtype1 == 4) 
mfx
probit city_sub rec_ch $x if  migtype1 == 3 
mfx
*/

**Trends in Composition Analysis**

use "$flp\ipums16_flp_22_65.dta", clear

replace metarea = met2013 if year > 2010

keep year metarea datanum serial relate sex age agemarr yrmarr marst empstat presgl educ inctot unitsstr bedrooms builtyr ownershp

sort year datanum serial relate, stable

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

gen hold = 1

***DISTRIBUTIONS BY YEAR**

collapse (sum) bach_plus emp emp_high ever_marry hold (mean) agemarr inctot, by(year metarea sex) 

global bach_plus "Bachelor or Adv Deg"
global emp "Employed"
global emp_high "Employed (High Prestige)"
global ever_marry "Ever Married"
global agemarr "Age Married"
global inctot "Income Ratio (Female to Male)"

foreach v of varlist bach_plus emp emp_high ever_marry {

gen `v'_rate = `v'/hold

label var `v'_rate "$`v'"

#delimit ;

kdensity `v'_rate if year == 1980 & sex == 2, 
addplot(kdensity `v'_rate if year == 1990 & sex == 2 || 
		kdensity `v'_rate if year == 2000 & sex == 2 || 
		kdensity `v'_rate if year == 2010 & sex == 2) 
legend(order(1 "1980" 2 "1990" 3 "2000" 4 "2010") c(2) r(2))
graphregion(color(white)) bgcolor(white)
title("")
xtitle("$`v'")
name(`v'_dens, replace);
#delimit cr 
}

**Could add share married...

#delimit ;
kdensity agemarr if year == 1980 & sex == 2, 
addplot(kdensity agemarr if year == 2008 & sex == 2 || 
		kdensity agemarr if year == 2010 & sex == 2 ||
		kdensity agemarr if year == 2014 & sex == 2) 
name(agemarr_dens, replace)
title("")
xtitle("$agemarr")
legend(order(1 "1980" 2 "2008" 3 "2010" "2014") c(2) r(2))	
graphregion(color(white)) bgcolor(white)
note("Age of marriage unavailable between 1980 and 2008.");
		
sort year metarea sex;
replace inctot = inctot[_n]/inctot[_n-1] if metarea[_n]==metarea[_n-1] & sex == 2;

*replace inctot = . if inctot > 1 ;
				
kdensity inctot if year == 1980 & sex == 2 & inctot < 1, 
addplot(kdensity inctot if year == 1990 & sex == 2 & inctot < 1 || 
		kdensity inctot if year == 2000 & sex == 2 & inctot < 1 || 
		kdensity inctot if year == 2010 & sex == 2 & inctot < 1) 
name(inctot_dens, replace)
title("")
xtitle("$inctot")
legend(order(1 "1980" 2 "1990" 3 "2000" 4 "2010") c(2) r(2))	
graphregion(color(white)) bgcolor(white);

#delimit ;

graph combine inctot_dens agemarr_dens bach_plus_dens emp_dens emp_high_dens ever_marry_dens, 
name(fdens, replace)
title("Variation Across MSAs - Female")
graphregion(color(white));

graph export "$out\fdens.pdf", replace as(pdf) name(fdens);
xx

foreach v of varlist bach_plus emp emp_high ever_marry {

*gen `v'_rate = `v'/hold

label var `v'_rate "$`v'"

#delimit ;

kdensity `v'_rate if year == 1980 & sex == 1, 
addplot(kdensity `v'_rate if year == 1990 & sex == 1 || 
		kdensity `v'_rate if year == 2000 & sex == 1 || 
		kdensity `v'_rate if year == 2010 & sex == 1) 
legend(order(1 "1980" 2 "1990" 3 "2000" 4 "2010") c(2) r(2))
graphregion(color(white)) bgcolor(white)
title("")
xtitle("$`v'")
name(`v'_dens, replace);
#delimit cr 
}

**Could add share married...

#delimit ;
kdensity agemarr if year == 1980 & sex == 1, 
addplot(kdensity agemarr if year == 2008 & sex == 1 || 
		kdensity agemarr if year == 2010 & sex == 1 ||
		kdensity agemarr if year == 2014 & sex == 1) 
name(agemarr_dens, replace)
title("")
xtitle("$agemarr")
legend(order(1 "1980" 2 "2008" 3 "2010" "2014") c(2) r(2))	
graphregion(color(white)) bgcolor(white)
note("Age of marriage unavailable between 1980 and 2008.");
		
graph combine inctot_dens agemarr_dens bach_plus_dens emp_dens emp_high_dens ever_marry_dens, 
name(mdens, replace)
title("Variation Across MSAs - Male")
graphregion(color(white)) bgcolor(white);

xx
graph export "$out\bach_plus_dens.pdf", replace as(pdf) name(bach_plus_dens);
graph export "$out\emp_dens.pdf", replace as(pdf) name(emp_dens);
graph export "$out\emp_high_dens.pdf", replace as(pdf) name(emp_high_dens);
graph export "$out\ever_marry_dens.pdf", replace as(pdf) name(ever_marry_dens);
graph export "$out\agemarr_dens.pdf", replace as(pdf) name(agemarr_dens);
graph export "$out\inctot_dens.pdf", replace as(pdf) name(inctot_dens);


graph export "$out\bach_plus_dens.png", replace name(bach_plus_dens);
graph export "$out\emp_dens.png", replace name(emp_dens);
graph export "$out\emp_high_dens.png", replace name(emp_high_dens);
graph export "$out\ever_marry_dens.png", replace name(ever_marry_dens);
graph export "$out\agemarr_dens.png", replace name(agemarr_dens);
graph export "$out\inctot_dens.png", replace name(inctot_dens);

#delimit cr

*Household Stats




xx






/*

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

gen     own = 0
replace own = 1 if ownershp == 1


foreach y in 1980 2000 2010 {

probit central_city $x_i if year == `y'
eststo mfx: mfx


}

esttab using "$out\reg2.csv", replace margin
clear matrix

foreach y in 1960 1980 2000 2008 2010 2013 {

sum hold if year == `y'
replace count = r(N) if year == `y'
sum hold if year == `y' & bach_plus == 1
replace bach_count = r(N) if year == `y'
sum hold if year == `y' & emp == 1
replace emp_count = r(N) if year == `y'
sum hold if year == `y' & emp_high == 1
replace emp_h_count = r(N) if year == `y'
}

*save temp, replace

**Collapse 

collapse (mean) count *_count (sum) hold bach_plus emp emp_high, by(year geotype_num)

gen bach_perc     = bach_plus/count
gen emp_perc      = emp/count
gen emp_high_perc = emp_high/count

gen bach_perc_int = bach_plus/(bach_count+hold)
gen emp_perc_int  = emp/(emp_count+hold)
gen emp_high_perc_int = emp_high/(emp_h_count+hold)

graph bar bach_perc_int,    over(geotype) over(year) name(bach, replace)
graph bar emp_perc_int,     over(geotype) over(year)  name(emp, replace)
graph bar emp_high_perc_int, over(geotype) over(year)  name(emp_high, replace)


