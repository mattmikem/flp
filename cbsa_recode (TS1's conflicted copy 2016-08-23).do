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

tostring metarea, gen(cbsa_late)
replace cbsa_late = "31100" if cbsa_late == "31080"

decode metarea, gen(metarea_str)
gen state = substr(metarea_str, strpos(metarea_str, ",")+2, 2)

joinby metarea using msa1990_cbsa, unmatched(master)
drop _merge

replace cbsa = "0" if state == "ot"

replace cbsa = cbsa_late if year > 1990

save ipums_withcbsa, replace
