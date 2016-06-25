********************************************
*Old/new MSA xwalk for NCDB to IPUMS
*M. Miller, 15F
********************************************

cd "L:\Research\Resurgence\Working Files\"

clear
clear matrix

set more off

global data = "L:\Research\Resurgence\GIS\Working Files\Output\Test"
global work = "L:\Research\Resurgence\Working Files" 
global geo  = "C:\Users\mmiller\Dropbox\Research\Urban\Data\Geography" 

**Load IPUMS (large, comment out once run)
/*
use "$flp\ipums17_flp_22_65.dta"

keep year metarea met2013

duplicates drop

**for 2000 - 2010, use met2013, which matches
**pre-2000, use crosswalk.

joinby metarea using cbsaxwalk

save ipums_msalist, replace
*/
**Set up xwalk

use "$geo\cbsatocountycrosswalk.dta", clear

destring msa, gen(metarea)
replace metarea = . if length(msa) == 2
replace metarea = metarea/10

keep metarea msa* cbsa*

drop if metarea == .

duplicates drop

save cbsaxwalk.dta, replace
/*
use ipums_msalist, clear

joinby metarea using cbsaxwalk, unmatched(master)

**If missing values (where _merge == 1), do the following.

decode metarea, gen(metname)

drop if year > 1990

keep metarea metname _merge cbsa cbsaname 

duplicates drop

order metarea metname cbsa cbsaname 

export excel using "$work\missing_msa.xlsx" if _merge == 1, replace firstrow(var) nolabel
*/

clear

import excel using "$work\missing_msa_edited.xlsx", firstrow

save msa_fill, replace

use ipums_msalist, clear
xx
joinby metarea using cbsaxwalk, unmatched(master)

drop _merge

joinby metarea using msa_fill, unmatched(master)

replace cbsa     = cbsa_new if msa == "" & year < 2000
replace cbsaname = cbsaname_new if msaname == "" & year < 2000

tostring met2013, gen(met2013str)

replace cbsa     = met2013str if year > 1990
decode  met2013 , gen(met2013name)
replace cbsaname = met2013name if year > 1990 

*Some duplication, drop dups here

drop if cbsa == ""
drop _merge year

keep cbsa cbsaname

bysort cbsa: gen count = _N

duplicates drop

save msa_xwalk, replace

**Test with NCDB

use "$work\resurge_12_10.dta", clear

drop _merge

joinby cbsa using msa_xwalk, unmatched(master)

tab _merge
