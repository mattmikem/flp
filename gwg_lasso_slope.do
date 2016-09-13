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

do "$link\lassoShooting.ado"

*use "$flp\ipums16_flp_22_65.dta", clear
use ipums_withcbsa, clear

keep if inlist(year, 1970, 1980, 1990, 2000, 2010)

quietly sum group

global J = r(max)

set matsize 1000

set more off

**Standard Mincer Regressions

*mat res       = J($J, 10, .) 
mat res_1970 = J($J, 7, .)
mat res_1980 = J($J, 7, .)
mat res_1990 = J($J, 7, .)
mat res_2000 = J($J, 7, .)
mat res_2010 = J($J, 7, .)
*mat res_eta   = J($J, 10, .)

do "$link\var_in_j.do"

sort metarea, stable

/*
foreach vo of varlist occx_* {
foreach vi of varlist indx_* {
gen oi_`vo'_`vi' = `vo'*`vi'
}
}
*/

foreach v of varlist occx_* indx_* {
by metarea: egen mean_`v' = mean(`v')
}

xx

#delimit ;
global x_lasso = "educy uhrswork  race_*
                  hisp_* occx_* indx_* mean_occx_* mean_indx_*";
#delimit cr

*exp exp2

*oi_*

**Variables excluded due to inconsistent inclusion: deg_field, met_stat

gen fm = female*emarry

save temp, replace

forvalues j = 1/3 {

forvalues y = 1970(10)2010 {

quietly sum if year == `y' & group == `j'

disp "`y' : `j'"

if r(N) > 0 {

keep if year == `y' & group == `j'

quietly lassoShooting lwage $x_lasso if emarry == 0 & nchild == 0, lasiter(100) verbose(0) fdisplay(0)
local ysel `r(selected)'
quietly lassoShooting female $x_lasso if emarry == 0 & nchild == 0, lasiter(100) verbose(0) fdisplay(0)
local fsel `r(selected)'
quietly lassoShooting exp $x_lasso if emarry == 0 & nchild == 0, lasiter(100) verbose(0) fdisplay(0)
local esel `r(selected)'

local ssel  : list fsel | ysel 
local sesel : list esel | ssel

reg lwage female exp exp2 `sesel' if emarry == 0 & nchild == 0, r

mat res_`y'[`j', 1]   = _b[female]
capture mat res_`y'[`j', 2] = _b[exp]
capture mat res_`y'[`j', 3] = _b[exp2]  

quietly lassoShooting lwage $x_lasso if emarry == 1 & female == 1, lasiter(100) verbose(0) fdisplay(0)
local ysel `r(selected)'
quietly lassoShooting exp   $x_lasso if emarry == 1 & female == 1, lasiter(100) verbose(0) fdisplay(0)
local esel `r(selected)'

local msel : list ysel | esel

reg lwage exp exp2 `msel' if emarry == 1 & female == 1, r

capture mat res_`y'[`j', 4] = _b[exp]
capture mat res_`y'[`j', 5] = _b[exp2]  

mat res_`y'[`j', 6] = res_`y'[`j', 4]/res_`y'[`j', 2] 
mat res_`y'[`j', 7] = res_`y'[`j', 5]/res_`y'[`j', 3]

}

else {

}

use temp, clear

}
}

svmat res_1970
svmat res_1980
svmat res_1990
svmat res_2000
svmat res_2010

*save ipums_gwg_lasso, replace

*use ipums_gwg_lasso, clear

keep res* group

sum group

global J = r(max)

drop group

gen group_id = _n

forvalues y = 1970(10)2010 {


rename res_`y'1 delta`y'
rename res_`y'2 as_eta`y'
rename res_`y'3 bs_eta`y'
rename res_`y'4 am_eta`y'
rename res_`y'5 bm_eta`y'
rename res_`y'6 a_eta`y'
rename res_`y'7 b_eta`y'

}

rename group_id group

keep if group <= $J

*save gwg_lass_wide, split
save gwg_lasso_wslope, replace

reshape clear
reshape i group
reshape j year
reshape xij gwg se delta as_eta bs_eta am_eta bm_eta a_eta b_eta
reshape long

**With just full gap, gwg_lass_long
*save gwg_lasso_long, replace
save gwg_lasso_slope, replace




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

