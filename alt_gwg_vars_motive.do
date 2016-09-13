********************************************
*Basic FLP measures (alt to GWG)
*
*M. Miller, 16S
********************************************

timer on 1

cd "L:\Research\Resurgence\Working Files"

clear
clear matrix

set more off

global data    = "L:\Research\Resurgence\GIS\Working Files\Output\Test"
global db_work = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Delayed Marriage\Data\Working\"
global work    = "L:\Research\Resurgence\Working Files"  
global flp     = "L:\Research\Resurgence\IPUMS"
global link    = "C:\Users\mmiller\Dropbox\Research\Urban\Papers\Delayed Marriage\Programs"

*use "$flp\ipums16_flp_22_65.dta", clear
*use "$flp\ipums22_flps_18_65.dta", clear
use ipums_withcbsa, clear

keep if age < 36 & age > 22

preserve

**Percentage of women in high prestige occupations

keep if emp_high == 1

collapse (mean) female, by(group year)

rename female fem_pct

save fhp, replace

restore 
preserve

keep if female == 1
keep if educ > 7

gen single = 0
replace single = 1 if marst > 2 

collapse (mean) single, by(group year)

rename single sing_pct

save sp, replace

restore 

collapse (mean) incwage, by(group year female)

reshape clear
reshape i group year
reshape j female
reshape xij incwage
reshape wide

gen ov_gwg = (incwage0 - incwage1)/incwage0

xx

*use gwg_lasso_long, clear
*use gwg_lasso_long, clear

joinby group year using sp, unmatched(master)
drop _merge
joinby group year using fhp, unmatched(master)
drop _merge

drop if gwg == .

bysort group: gen group_n = _N

save gwg_lasso_long_alts_mot, replace

