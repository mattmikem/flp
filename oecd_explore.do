********************************************
*OECD GWG and City Explore
*M. Miller, 16X
********************************************

cd "C:\Users\Matthew\Dropbox\Research\Urban\Papers\Delayed Marriage\Working"
*cd "L:\Research\Social Skills\Working Files"

clear
clear matrix

set more off

global oecd "C:\Users\Matthew\Dropbox\Research\Urban\Papers\Delayed Marriage\Data\OECD"
global out  "C:\Users\Matthew\\Dropbox\Research\Urban\Papers\Delayed Marriage\Draft"

insheet using "$oecd\GENDER_EMP.csv", comma

drop v6 v10 unit power* flag* ref* age* ind* sex

rename time year 
rename value gwg

gen cou1 = substr(cou, 1, 2)
gen cou2 = substr(cou, 1, 1) + substr(cou, 3, 3)

save gwg, replace

clear

insheet using "$oecd\CITIES.csv", comma

gen cou = substr(metro_id, 1, 3)

replace cou = substr(cou, 1, 2) if strpos(cou, "0") != 0 | strpos(cou, "1") != 0 | strpos(cou, "2") != 0 | strpos(cou, "5") != 0

joinby cou year using gwg, unmatched(master)
rename country country0
rename gwg gwg0
drop cou1 cou2
rename cou cou1
drop _merge
joinby cou1 year using gwg, unmatched(master)
replace country0 = country if _merge == 3
replace gwg0 = gwg if _merge == 3
drop country cou gwg cou2
rename cou1 cou2
drop _merge
joinby cou2 year using gwg, unmatched(master)
replace country0 = country if _merge == 3
replace gwg0 = gwg if _merge == 3
drop cou1 country cou gwg 
rename cou2 cou
rename country0 country
rename gwg0 gwg 

keep if var == "POP_SHARE"

collapse (mean) value gwg, by(country)

label var value "Pct Urbanization"
label var gwg   "Gender Wage Gap"

#delimit ;
twoway (scatter value gwg, mlabel(country)) (lfit value gwg),
name(oecd, replace)
ytitle("Pct Urbanization")
legend(off)
note("Average across all cities in country with population over 500,000." "Pct Urbanization is percentage of national population residing in these cities.")	
graphregion(color(white)) bgcolor(white);
#delimit cr

graph export "$out\oecd_gwg.png", replace name(oecd)

xx

save cities, replace

clear


