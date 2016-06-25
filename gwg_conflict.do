********************************************
*CBSA level Gender Wage Gaps
*Basic and Blinder-Oaxaca
*M. Miller, 15F
********************************************

timer on 1

cd "L:\Research\Resurgence\Working Files"

clear
clear matrix

set more off

global data = "L:\Research\Resurgence\GIS\Working Files\Output\Test"
global work = "L:\Research\Resurgence\Working Files"  
global flp  = "L:\Research\Resurgence\IPUMS"

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

gen exp  = age - educy - 6
gen exp2 = exp*exp

**Female

gen female = 0
replace female = 1 if sex == 2

**Some negative values

gen agesq = age*age

*Removed for data completeness reasons: agemarr
*Removed for geographic concerns: sizepl

egen group = group(metarea)

quietly sum group

global J = r(max)

set matsize 1000

set more off

**Standard Mincer Regressions

mat res = J($J, 8, .) 

forvalues j = 1/$J {

global yy = 0

forvalues y = 1980(10)2010 {

global yy = $yy + 1

quietly sum if year == `y' & group == `j'

disp "`y' : `j'"

if r(N) > 0 {

quietly reg lwage female educy exp exp2 uhrswork if year == `y' & group == `j'
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

}
}


svmat res

save ipums_gwg, replace

use ipums_gwg, clear

keep res* group

sum group

global J = r(max)

drop group

gen group_id = _n

rename res1 gwg1980
rename res2 se1980
rename res3 gwg1990
rename res4 se1990
rename res5 gwg2000
rename res6 se2000
rename res7 gwg2010
rename res8 se2010

rename group_id group

keep if group <= $J

save gwg_wide

reshape clear
reshape i group
reshape j year
reshape xij gwg se
reshape long

save gwg_long, replace

xx
**Full set for Lasso

#delimit ;

global x_lasso = "urban metro nchild nchlt5 female agesq
				  age marst_* marrno_* divinyr fertyr 
				  race_* hisp_* bpl_* degfield_* occ_* 
				  uhrswork tranwork_* trantime";

#delimit cr

timer off 1
disp r(t1)/60

*Urban 

replace urban = urban - 1

*Metro 

tab metro, gen(met_stat)

*Marital Status

tab marst, gen(marst_)

*Times Married

tab marrno, gen(marrno_)

*Divorced in Year

replace divinyr = 0 if divinyr == 1
replace divinyr = 1 if divinyr == 2

*Fertility in Year

replace fertyr = 0 if fertyr == 1
replace fertyr = 1 if fertyr == 2

*Race

tab race, gen(race_)

*Hispanic

tab hispan, gen(hisp_)

*Birthplace

tab bpl, gen(bpl_)	

*Degree Field

tab degfield, gen(degfield_)

*Occupation and Industry

gen occ_gen = ""
replace occ_gen =  "Management in Business, Science, and Arts" if occ2010 >=10 & occ2010<=430
replace occ_gen =  "Business Operations Specialists " if occ2010 >=500 & occ2010<=730
replace occ_gen =  "Financial Specialists " if occ2010 >=800 & occ2010<=950
replace occ_gen =  "Computer and Mathematical " if occ2010 >=1000 & occ2010<=1240
replace occ_gen =  "Architecture and Engineering " if occ2010 >=1300 & occ2010<=1540
replace occ_gen =  "Technicians " if occ2010 >=1550 & occ2010<=1560
replace occ_gen =  "Life, Physical, and Social Science " if occ2010 >=1600 & occ2010<=1980
replace occ_gen =  "Community and Social Services " if occ2010 >=2000 & occ2010<=2060
replace occ_gen =  "Legal " if occ2010 >=2100 & occ2010<=2150
replace occ_gen =  "Education, Training, and Library " if occ2010 >=2200 & occ2010<=2550
replace occ_gen =  "Arts, Design, Entertainment, Sports, and Media " if occ2010 >=2600 & occ2010<=2920
replace occ_gen =  "Healthcare Practitioners and Technicians " if occ2010 >=3000 & occ2010<=3540
replace occ_gen =  "Healthcare Support " if occ2010 >=3600 & occ2010<=3650
replace occ_gen =  "Protective Service " if occ2010 >=3700 & occ2010<=3950
replace occ_gen =  "Food Preparation and Serving " if occ2010 >=4000 & occ2010<=4150
replace occ_gen =  "Building and Grounds Cleaning and Maintenance " if occ2010 >=4200 & occ2010<=4250
replace occ_gen =  "Personal Care and Service " if occ2010 >=4300 & occ2010<=4650
replace occ_gen =  "Sales and Related " if occ2010 >=4700 & occ2010<=4965
replace occ_gen =  "Office and Administrative Support " if occ2010 >=5000 & occ2010<=5940
replace occ_gen =  "Farming, Fisheries, and Forestry " if occ2010 >=6005 & occ2010<=6130
replace occ_gen =  "Construction " if occ2010 >=6200 & occ2010<=6765
replace occ_gen =  "Extraction " if occ2010 >=6800 & occ2010<=6940
replace occ_gen =  "Installation, Maintenance, and Repair " if occ2010 >=7000 & occ2010<=7630
replace occ_gen =  "Production " if occ2010 >=7700 & occ2010<=8965
replace occ_gen =  "Transportation and Material Moving " if occ2010 >=9000 & occ2010<=9750
replace occ_gen =  "Military " if occ2010 >=9800 & occ2010<=9830
replace occ_gen =  "No Occupation " if occ2010 >=9920 & occ2010<=10000

replace occ_gen = trim(occ_gen)

tab occ_gen, gen(occ_)

*tab ind, gen(ind_)

*Transportation Type and time

tab tranwork, gen(tranwork_)



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

