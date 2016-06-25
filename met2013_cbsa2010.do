**TEMPORARY FIX FOR MET2013, MSA1990, and CBSA2010 mapping

*MET2013 --> CBSA2010

**Two fixes: (i) top CBSA in each ua_code, (ii) recode LA to 31080
**Match: 97%, n 52,707 (down from ~74,000)

use ipums_msalist, clear

keep met2013

duplicates drop

save ipums_late, replace

use "$work\resurge_12_10.dta", clear

gen hold = 1

collapse (sum) hold, by(ua_code ua_name cbsa)

gsort ua_code -hold

keep if ua_code[_n] != ua_code[_n-1]

bysort cbsa: gen count = _N

gsort -count cbsa -hold

gen cc_cbsa = 0
replace cc_cbsa = 1 if cbsa[_n] != cbsa[_n-1]

drop hold

save top_cbsa, replace

use "$work\resurge_12_10.dta", clear
drop _merge

joinby ua_code cbsa using top_cbsa, unmatched(master)

drop if _merge == 1

drop _merge

replace cbsa = "31080" if ua_code == 1

destring cbsa, gen(met2013)

joinby met2013 using ipums_late, unmatched(master)

tab _merge

**Above checks match, below creates the file to merge

**In this case, simply use the MET2013 codes, they match well.



