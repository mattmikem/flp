**TEMPORARY FIX FOR MET2013, MSA1990, and CBSA2010 mapping

*MSA1990 --> CBSA2010

clear

import excel using "$work\MSA1990_CBSA2010_adj.xlsx", firstrow

rename CBSA cbsa_fix
rename MSA metarea

destring metarea, replace

save m1990_cbsa2010_adj, replace

use ipums_msalist, clear

keep metarea

duplicates drop

joinby metarea using cbsaxwalk, unmatched(master)

drop _merge

joinby metarea using msa_fill, unmatched(master)

drop _merge

joinby metarea using m1990_cbsa2010_adj, unmatched(master)

replace cbsa     = cbsa_new if msa == ""
replace cbsaname = cbsaname_new if msaname == ""
replace cbsa     = cbsa_fix if _merge == 3
replace cbsaname = Name     if _merge == 3

drop if cbsa == ""

keep cbsa cbsaname

duplicates drop

sort cbsa cbsaname

duplicates drop cbsa, force

save ipums_early, replace

use "$work\resurge_12_10.dta", clear

gen hold = 1

collapse (sum) hold, by(ua_code cbsa)

gsort ua_code -hold

keep if ua_code[_n] != ua_code[_n-1]

save top_cbsa, replace

use "$work\resurge_12_10.dta", clear
drop _merge

joinby ua_code cbsa using top_cbsa, unmatched(master)

drop if _merge == 1
drop _merge

replace cbsa = "31080" if ua_code == 1

joinby cbsa using ipums_early, unmatched(master) 

tab _merge

**The above tests the match this supplies the crosswalk**

use ipums_msalist, clear

keep metarea

duplicates drop

joinby metarea using cbsaxwalk, unmatched(master)

drop _merge

joinby metarea using msa_fill, unmatched(master)

drop _merge

joinby metarea using m1990_cbsa2010_adj, unmatched(master)

replace cbsa     = cbsa_new if msa == ""
replace cbsaname = cbsaname_new if msaname == ""
replace cbsa     = cbsa_fix if _merge == 3
replace cbsaname = Name     if _merge == 3

drop if cbsa == ""

keep metarea cbsa cbsaname

duplicates drop

replace cbsa = "31100" if cbsa == "31080"

*joinby cbsa using top_cbsa, unmatched(master)
*drop _merge

save msa1990_cbsa, replace

